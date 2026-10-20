#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
top=tt_um_evan_youan_yu_ppe
gds="${1:-$root/tt_submission/$top.gds}"
[[ -s "$gds" ]] || { echo "GDS missing: $gds" >&2; exit 2; }
[[ -x "$root/.physical/conda/bin/python" ]] || { echo 'Physical Conda environment missing' >&2; exit 2; }
export PATH="$root/scripts:$root/.physical/conda/bin:$PATH"
export PDK_ROOT="$root/.physical/pdk" PDK=ihp-sg13cmos5l
export YOWASP_CACHE_DIR="$root/.physical/cache" MPLCONFIGDIR="$root/.physical/matplotlib"
mkdir -p "$root/.physical/tt/precheck/reports" "$root/reports/logs" "$root/reports/local-precheck"
if [[ -f "$root/reports/local-precheck/results.xml" ]]; then
  archive="$root/reports/local-history/precheck-$(date -u +%Y%m%dT%H%M%SZ)"
  mkdir -p "$archive"
  cp -a "$root/reports/local-precheck" "$archive/"
fi
rm -f "$root/.physical/tt/precheck/reports/results.xml" "$root/reports/local-precheck/results.xml"
printf '%s\n' "${gds#"$root"/}" > "$root/reports/local-precheck/source.txt"
(
  cd "$root/.physical/tt/precheck"
  python precheck.py --gds "$gds" --tech ihp-sg13cmos5l
) 2>&1 | tee "$root/reports/logs/local-precheck.log"
cp "$root/.physical/tt/precheck/reports"/* "$root/reports/local-precheck/"
"$root/.conda/bin/python" "$root/scripts/check_results.py" "$root/reports/local-precheck/results.xml"
