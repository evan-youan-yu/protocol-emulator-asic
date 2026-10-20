#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
tt_sha=d66cf179e7bc4d296362ab7e2e3b344dc3c4f665
pdk_sha=2bbec755dc67ca3db0261c3d6163e15735d66710

command -v conda >/dev/null || { echo 'Conda is required' >&2; exit 2; }
mkdir -p .physical/cache .physical/matplotlib .physical/pip-cache

if [[ ! -d .physical/tt/.git ]]; then
  git clone --branch ihp-sg13cmos5l --single-branch \
    https://github.com/TinyTapeout/tt-support-tools.git .physical/tt
  git -C .physical/tt fetch --depth 1 origin "$tt_sha"
  git -C .physical/tt checkout -q FETCH_HEAD
fi
[[ "$(git -C .physical/tt rev-parse HEAD)" == "$tt_sha" ]] || {
  echo "Support tools revision differs from pinned $tt_sha; inspect before changing it" >&2
  exit 2
}

if [[ ! -d .physical/pdk/.git ]]; then
  mkdir -p .physical/pdk
  git -C .physical/pdk init -q
fi
if [[ "$(git -C .physical/pdk rev-parse HEAD 2>/dev/null || true)" != "$pdk_sha" ]]; then
  if [[ -n "$(git -C .physical/pdk status --porcelain)" ]]; then
    echo 'Existing PDK checkout has changes; inspect before switching revisions' >&2
    exit 2
  fi
  git -C .physical/pdk fetch --depth 1 \
    https://github.com/IHP-GmbH/IHP-Open-PDK.git "$pdk_sha"
  git -C .physical/pdk checkout -q FETCH_HEAD
fi
printf 'IHP-Open-PDK %s\n' "$pdk_sha" > .physical/pdk/ihp-sg13cmos5l/SOURCES

if [[ ! -x .physical/conda/bin/python ]]; then
  conda create -y --override-channels -c conda-forge -p "$root/.physical/conda" python=3.11 pip
fi
PIP_CACHE_DIR="$root/.physical/pip-cache" \
  .physical/conda/bin/python -m pip install -r .physical/tt/requirements.txt 'librelane==3.1.0.dev3'

if [[ ! -e tt && ! -L tt ]]; then ln -s .physical/tt tt; fi
[[ "$(readlink tt)" == .physical/tt ]] || {
  echo 'tt exists but does not point to .physical/tt; inspect before changing it' >&2
  exit 2
}

export PDK_ROOT="$root/.physical/pdk" PDK=ihp-sg13cmos5l
export YOWASP_CACHE_DIR="$root/.physical/cache" MPLCONFIGDIR="$root/.physical/matplotlib"
export PATH="$root/.physical/conda/bin:$PATH"
python tt/tt_tool.py --ihp --create-user-config
if ! docker info --format '{{json .SecurityOptions}}' 2>/dev/null | grep -q rootless; then
  echo 'Rootless Docker must be ready before completing physical setup' >&2
  exit 2
fi
if ! docker image inspect ghcr.io/librelane/librelane:3.1.0.dev3 >/dev/null 2>&1; then
  docker pull ghcr.io/librelane/librelane:3.1.0.dev3
fi
scripts/doctor_physical.sh
