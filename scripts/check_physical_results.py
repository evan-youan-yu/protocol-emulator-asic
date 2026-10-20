#!/usr/bin/env python3
"""Check actual LibreLane CMOS5L final artifacts and print a compact report."""

import json
import sys
from pathlib import Path


def main() -> int:
    run = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("runs/wokwi")
    metrics_path = run / "final/metrics.json"
    pdk_path = run / "pdk.json"
    flow_path = run / "flow.log"
    if not all(p.is_file() for p in (metrics_path, pdk_path, flow_path)):
        print(f"BLOCKED: final metrics, PDK manifest or flow log missing in {run}")
        return 2
    metrics = json.loads(metrics_path.read_text())
    pdk = json.loads(pdk_path.read_text())
    checks = {
        "CMOS5L PDK": pdk.get("PDK") == "ihp-sg13cmos5l",
        "PDK revision": pdk.get("PDK_VERSION")
        == "2bbec755dc67ca3db0261c3d6163e15735d66710",
        "LibreLane revision": pdk.get("FLOW_VERSION") == "3.1.0.dev3",
        "Flow complete": "Flow complete." in flow_path.read_text(errors="replace"),
        "Setup slack": metrics.get("timing__setup__ws", -1) >= 0,
        "Hold slack": metrics.get("timing__hold__ws", -1) >= 0,
        "Route DRC": metrics.get("route__drc_errors", -1) == 0,
        "Magic DRC": metrics.get("magic__drc_error__count", -1) == 0,
        "LVS": metrics.get("design__lvs_error__count", -1) == 0,
        "Antenna": metrics.get("route__antenna_violation__count", -1) == 0,
    }
    gds_files = list((run / "final/gds").glob("*.gds"))
    checks["GDS artifact"] = len(gds_files) == 1 and gds_files[0].stat().st_size > 0
    for name, passed in checks.items():
        print(f"{name:20} {'PASS' if passed else 'FAIL'}")
    print(f"Standard-cell area: {metrics.get('design__instance__area__stdcell')} um^2")
    print(f"Standard-cell count: {metrics.get('design__instance__count__stdcell')}")
    print(f"Utilization: {metrics.get('design__instance__utilization__stdcell')}")
    print(f"Worst setup slack: {metrics.get('timing__setup__ws')} ns")
    print(f"Worst hold slack: {metrics.get('timing__hold__ws')} ns")
    print(f"Evidence: {run.resolve()}")
    return 0 if all(checks.values()) else 1


if __name__ == "__main__":
    sys.exit(main())
