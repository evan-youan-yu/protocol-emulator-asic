#!/usr/bin/env python3
"""Summarize observed local evidence; never infer physical PASS from configuration."""
from datetime import datetime, timezone
from pathlib import Path
import os
import re
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent.parent


def cmd(*args):
    try:
        return subprocess.check_output(args, cwd=ROOT, text=True, stderr=subprocess.DEVNULL).strip()
    except (FileNotFoundError, subprocess.CalledProcessError):
        return 'unavailable'


def status(name, success_marker):
    log = ROOT / 'reports/logs' / name
    if not log.is_file():
        return 'NOT RUN'
    data = log.read_text(errors='replace')
    return 'PASS' if success_marker in data else 'FAIL or INCOMPLETE'


xml = ROOT / 'test/results.xml'
synth_text = (ROOT / 'reports/logs/synth.log').read_text(errors='replace') if (ROOT / 'reports/logs/synth.log').exists() else ''
cell_counts = re.findall(r'^\s*(\d+) cells$', synth_text, re.MULTILINE)
cell_count = cell_counts[-1] if cell_counts else 'unknown'
if xml.exists():
    parsed = ET.parse(xml).getroot()
    count = len(parsed.findall('.//testcase'))
    failures = len(parsed.findall('.//failure')) + len(parsed.findall('.//error'))
    skipped = len(parsed.findall('.//skipped'))
    test_result = f'PASS ({count} tests)' if count and not failures and not skipped else f'FAIL ({count} tests, {failures} failures, {skipped} skipped)'
else:
    test_result = 'NOT RUN'

sha = cmd('git', 'rev-parse', 'HEAD')
upstream = cmd('git', 'rev-parse', 'upstream/cmos5l')
if upstream == 'unavailable':
    upstream = cmd('git', 'rev-parse', 'origin/cmos5l')
dirty = cmd('git', 'status', '--porcelain') != ''
origin = cmd('git', 'config', '--get', 'remote.origin.url')
gh_bin = str(ROOT / '.conda/bin/gh')
gh_auth = subprocess.run([gh_bin, 'auth', 'status'], cwd=ROOT, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0 if Path(gh_bin).exists() else False
ci_snapshot = ROOT / 'docs/ci_evidence.md'
lines = [
    '# Local verification status',
    '',
    f'Generated: {datetime.now(timezone.utc).isoformat()}',
    f'Template SHA: `{upstream}`',
    f'Current commit: `{sha}`; working tree changed: `{dirty}`',
    f'GitHub origin: `{origin}`; CLI auth check in this shell: `{gh_auth}`',
    f'OS: `{next((line.split("=", 1)[1].strip().strip(chr(34)) for line in Path("/etc/os-release").read_text().splitlines() if line.startswith("PRETTY_NAME=")), cmd("uname", "-srm"))}`',
    '',
    '| Check | Status | Evidence |',
    '|---|---|---|',
    f'| Template RTL/Cocotb | {status("template-test.log", "TESTS=1 PASS=1 FAIL=0")} | `reports/logs/template-test.log` |',
    f'| Python reference tests | {status("python-test.log", "2 passed")} | `reports/logs/python-test.log` |',
    f'| M1 RTL/Cocotb | {test_result} | `test/results.xml`, `reports/logs/test.log`, `test/tb.fst` |',
    f'| Verilator lint | {status("lint.log", "V e r i l a t i o n   R e p o r t")} | `reports/logs/lint.log` |',
    f'| Generic Yosys synthesis | {status("synth.log", "Found and reported 0 problems.")} | `reports/logs/synth.log` |',
    f'| Formal safety BMC depth 20 | {status("formal-core.log", "DONE (PASS")} | `reports/logs/formal-core.log` |',
    f'| Formal WAIT reachability cover | {status("formal-reach.log", "DONE (PASS")} | `reports/logs/formal-reach.log` |',
    f'| Project GitHub Actions | {"RECORDED" if ci_snapshot.exists() else "NOT RUN"} | {"docs/ci_evidence.md is a timestamped CI snapshot" if ci_snapshot.exists() else "No CI evidence snapshot"} |',
    f'| GDS / STA / DRC / LVS / Precheck / GL test | {"SEE CI SNAPSHOT" if ci_snapshot.exists() else "NOT RUN"} | {"docs/ci_evidence.md; inspect live GitHub run for current status" if ci_snapshot.exists() else "No physical reports recorded"} |',
    '',
    'Generic cell count is not a CMOS5L area estimate. The 50 MHz target remains unverified.',
    f'Yosys generic synthesis reported {cell_count} cells in the latest M1 run. Check the synthesis log for memory mapping and warnings.',
    '',
    '## Tool versions',
    '',
    f'- Conda: `{cmd("conda", "--version")}`',
    f'- Python: `{cmd(str(ROOT / ".conda/bin/python"), "--version")}`',
    f'- Icarus: `{cmd(str(ROOT / ".conda/bin/iverilog"), "-V").splitlines()[0]}`',
    f'- Verilator: `{cmd(str(ROOT / ".conda/bin/verilator"), "--version")}`',
    f'- Yosys: `{cmd(str(ROOT / ".conda/bin/yosys"), "-V")}`',
    f'- Z3: `{cmd(str(ROOT / ".conda/bin/z3"), "--version")}`',
    f'- SymbiYosys source: `79fc9eddca5e33a28cc2f2cd19c9825efd9a7255`',
    f'- GitHub CLI: `{cmd(gh_bin, "--version").splitlines()[0]}`',
    f'- GTKWave: `{cmd("dpkg-query", "-W", "-f=${Version}", "gtkwave")}`; DISPLAY configured: `{bool(os.environ.get("DISPLAY"))}`; GUI launch: `NOT VERIFIED`',
]
report = ROOT / 'reports/status.md'
report.write_text('\n'.join(lines) + '\n')
print(report)
