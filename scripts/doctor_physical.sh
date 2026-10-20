#!/usr/bin/env bash
set -u
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bad=0
expect() {
  local name="$1" actual="$2" expected="$3"
  if [[ "$actual" == "$expected" ]]; then printf '%-20s PASS %s\n' "$name" "$actual";
  else printf '%-20s MISMATCH expected %s, got %s\n' "$name" "$expected" "$actual"; bad=1; fi
}
expect 'Support tools SHA' "$(git -C "$root/.physical/tt" rev-parse HEAD 2>/dev/null || echo MISSING)" d66cf179e7bc4d296362ab7e2e3b344dc3c4f665
expect 'Support tools link' "$(readlink "$root/tt" 2>/dev/null || echo MISSING)" .physical/tt
expect 'PDK SHA' "$(git -C "$root/.physical/pdk" rev-parse HEAD 2>/dev/null || echo MISSING)" 2bbec755dc67ca3db0261c3d6163e15735d66710
expect 'PDK ID' "$(test -d "$root/.physical/pdk/ihp-sg13cmos5l" && echo ihp-sg13cmos5l || echo MISSING)" ihp-sg13cmos5l
if [[ -x "$root/.physical/conda/bin/python" ]]; then
  actual="$($root/.physical/conda/bin/python -m librelane --version 2>/dev/null | head -1)"
else actual=MISSING; fi
expect 'LibreLane' "$actual" 'LibreLane v3.1.0.dev3'
expect 'TT top module' "$(test -f "$root/src/user_config.json" && "$root/.physical/conda/bin/python" -c 'import json,sys;print(json.load(open(sys.argv[1]))["DESIGN_NAME"])' "$root/src/user_config.json" 2>/dev/null || echo MISSING)" tt_um_evan_youan_yu_ppe
if "$root/.physical/conda/bin/python" -c 'import gdstk, klayout.db' >/dev/null 2>&1; then
  echo 'Precheck Python      PASS gdstk and KLayout API'
else
  echo 'Precheck Python      MISSING dependencies'
  bad=1
fi
if command -v docker >/dev/null 2>&1; then
  if docker info --format '{{json .SecurityOptions}}' 2>/dev/null | grep -q 'rootless'; then
    echo 'Docker daemon        PASS rootless'
  else
    echo 'Docker daemon        BLOCKED: no reachable rootless daemon'
    bad=1
  fi
  if docker image inspect ghcr.io/librelane/librelane:3.1.0.dev3 >/dev/null 2>&1; then
    echo 'LibreLane image      PASS 3.1.0.dev3'
    expect 'Image digest' "$(docker image inspect ghcr.io/librelane/librelane:3.1.0.dev3 --format '{{index .RepoDigests 0}}' 2>/dev/null || echo MISSING)" 'ghcr.io/librelane/librelane@sha256:d109140b8f17fc54f4fca998beb8124f4949404ec52e339eebd2250854a18b5a'
  else
    echo 'LibreLane image      MISSING'
    bad=1
  fi
else
  echo 'Docker CLI           MISSING'
  bad=1
fi
exit "$bad"
