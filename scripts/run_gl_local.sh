#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
top=tt_um_evan_youan_yu_ppe
netlist="${1:-$root/tt_submission/$top.v}"
[[ -s "$netlist" ]] || { echo "Gate-level netlist missing: $netlist" >&2; exit 2; }
[[ -d "$root/.physical/pdk/ihp-sg13cmos5l" ]] || { echo 'CMOS5L PDK missing' >&2; exit 2; }
export PATH="$root/.conda/bin:$PATH"
export PDK_ROOT="$root/.physical/pdk" PDK=ihp-sg13cmos5l
mkdir -p "$root/reports/logs"
if [[ -f "$root/reports/local-gl/results.xml" ]]; then
  archive="$root/reports/local-history/gl-$(date -u +%Y%m%dT%H%M%SZ)"
  mkdir -p "$archive"
  cp -a "$root/reports/local-gl" "$archive/"
fi
cp "$netlist" "$root/test/gate_level_netlist.v"
(
  cd "$root/test"
  make clean
  GATES=yes make
) 2>&1 | tee "$root/reports/logs/local-gl.log"
"$root/.conda/bin/python" "$root/scripts/check_results.py" "$root/test/results.xml"
test -s "$root/test/tb.fst"
mkdir -p "$root/reports/local-gl"
cp "$root/test/results.xml" "$root/test/tb.fst" "$root/reports/local-gl/"
printf '%s\n' "${netlist#"$root"/}" > "$root/reports/local-gl/source.txt"
