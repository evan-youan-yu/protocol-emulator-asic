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
if [[ -x "$bin/gh" ]]; then
  echo 'GitHub CLI         INSTALLED'
  if "$bin/gh" auth status >/dev/null 2>&1; then
    echo 'GitHub login       AUTHENTICATED'
  else
    echo 'GitHub login       NOT AUTHENTICATED'
  fi
else
  echo 'GitHub CLI         MISSING'
fi
if command -v gtkwave >/dev/null; then
  echo 'GTKWave            INSTALLED'
else
  echo 'GTKWave            MISSING (optional waveform viewer)'
fi
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
if command -v docker >/dev/null; then
  echo 'Docker CLI         INSTALLED'
else
  echo 'Docker CLI         MISSING (physical flow)'
fi
if command -v openroad >/dev/null; then
  echo 'OpenROAD host      INSTALLED'
else
  echo 'OpenROAD host      NOT INSTALLED (provided by LibreLane container)'
fi
if [[ -x "$bin/sby" && -x "$bin/z3" ]]; then
  echo 'Formal tools       INSTALLED (SymbiYosys and Z3)'
else
  echo 'Formal tools       MISSING'
  bad=1
fi
physical_pdk_root="${PDK_ROOT:-$root/.physical/pdk}"
if [[ -d "${physical_pdk_root}/ihp-sg13cmos5l" ]]; then
  echo 'CMOS5L PDK        INSTALLED'
else
  echo 'CMOS5L PDK        NOT VERIFIED'
fi
"$root/scripts/check_tool_versions.sh"
exit "$bad"
