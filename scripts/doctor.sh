#!/usr/bin/env bash
set -u
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bin="$root/.conda/bin"
bad=0
check() {
  local name="$1" path="$2"
  if [[ -x "$path" ]]; then printf '%-18s INSTALLED %s\n' "$name" "$path";
  else printf '%-18s MISSING\n' "$name"; bad=1; fi
}
check conda "$(command -v conda || echo /nonexistent)"
for tool in python iverilog verilator yosys make; do check "$tool" "$bin/$tool"; done
if [[ -x "$bin/python" ]]; then
  if ! "$bin/python" - <<'PY'
import importlib.metadata as m
import sys
bad = False
for name, expected in [('cocotb','2.0.1'),('pytest','8.4.2'),('PyYAML','6.0.3')]:
    try:
        got=m.version(name)
        print(f'{name:18} {"INSTALLED" if got==expected else "VERSION MISMATCH"} {got} (expected {expected})')
        bad |= got != expected
    except m.PackageNotFoundError:
        print(f'{name:18} MISSING')
        bad = True
sys.exit(1 if bad else 0)
PY
  then bad=1; fi
fi
for tool in docker openroad; do
  if command -v "$tool" >/dev/null; then printf '%-18s INSTALLED\n' "$tool";
  else printf '%-18s MISSING (optional physical flow)\n' "$tool"; fi
done
if [[ -x "$bin/sby" && -x "$bin/z3" ]]; then
  echo 'Formal tools       INSTALLED (SymbiYosys and Z3)'
else
  echo 'Formal tools       MISSING'
  bad=1
fi
if [[ -n "${PDK_ROOT:-}" && -d "${PDK_ROOT}/ihp-sg13cmos5l" ]]; then
  echo 'CMOS5L PDK        INSTALLED'
else
  echo 'CMOS5L PDK        NOT VERIFIED'
fi
"$root/scripts/check_tool_versions.sh"
exit "$bad"
