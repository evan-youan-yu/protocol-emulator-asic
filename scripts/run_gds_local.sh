#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

if [[ -f runs/wokwi/final/metrics.json ]]; then
  stamp="$(date -u +%Y%m%dT%H%M%SZ)-$(git rev-parse --short HEAD)"
  archive="$root/reports/local-history/$stamp"
  mkdir -p "$archive"
  cp -a runs/wokwi/final/metrics.json runs/wokwi/final/commit_id.json \
    runs/wokwi/pdk.json runs/wokwi/flow.log "$archive/"
  cp -a runs/wokwi/final/gds "$archive/"
  if [[ -d tt_submission ]]; then cp -a tt_submission "$archive/"; fi
  if [[ -d reports/local-gl ]]; then cp -a reports/local-gl "$archive/"; fi
  if [[ -d reports/local-precheck ]]; then cp -a reports/local-precheck "$archive/"; fi
  if [[ -f reports/logs/local-gds.log ]]; then cp -a reports/logs/local-gds.log "$archive/"; fi
  echo "Previous local GDS evidence saved in $archive"
fi

export PDK_ROOT="$root/.physical/pdk" PDK=ihp-sg13cmos5l
export YOWASP_CACHE_DIR="$root/.physical/cache" MPLCONFIGDIR="$root/.physical/matplotlib"
export PATH="$root/.physical/conda/bin:$PATH"
mkdir -p reports/logs
python tt/tt_tool.py --ihp --harden 2>&1 | tee reports/logs/local-gds.log
"$root/.conda/bin/python" scripts/check_physical_results.py runs/wokwi
python tt/tt_tool.py --ihp --create-tt-submission
