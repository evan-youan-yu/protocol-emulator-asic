#!/usr/bin/env python3
"""Fail when a Cocotb JUnit XML file is absent or contains failed tests."""
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

path = Path(sys.argv[1] if len(sys.argv) > 1 else 'test/results.xml')
if not path.is_file():
    raise SystemExit(f'BLOCKED: missing {path}')
root = ET.parse(path).getroot()
cases = root.findall('.//testcase')
failures = root.findall('.//failure') + root.findall('.//error')
skipped = root.findall('.//skipped')
print(f'{path}: tests={len(cases)} failures_or_errors={len(failures)} skipped={len(skipped)}')
if not cases or failures or skipped:
    raise SystemExit(1)
