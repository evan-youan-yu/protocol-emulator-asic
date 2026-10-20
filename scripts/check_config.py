#!/usr/bin/env python3
"""Static cross-check of official CMOS5L integration and top-module mapping."""
from pathlib import Path
import yaml

root = Path(__file__).resolve().parent.parent
info = yaml.safe_load((root / 'info.yaml').read_text())['project']
top = info['top_module']
assert top.startswith('tt_um_')
assert info['tiles'] == '6x4'
assert top in (root / 'src/project.v').read_text()
assert top in (root / 'test/tb.v').read_text()
for source in info['source_files']:
    assert (root / 'src' / source).is_file(), source
gds = (root / '.github/workflows/gds.yaml').read_text()
for needle in (
    'TinyTapeout/tt-gds-action@ihp-cmos5l',
    'pdk: ihp-sg13cmos5l',
    'tt-gds-action/precheck@ihp-cmos5l',
    'tt-gds-action/gl_test@ihp-cmos5l',
):
    assert needle in gds, needle
test = (root / '.github/workflows/test.yaml').read_text()
assert 'cocotb_tools.check_results' in test
assert 'ihp-sg13g2' not in gds
container = (root / '.devcontainer/Dockerfile').read_text()
for needle in (
    'ENV PDK=ihp-sg13cmos5l',
    'ARG TT_SUPPORT_TOOLS_BRANCH=ihp-sg13cmos5l',
    'librelane==3.1.0.dev3',
):
    assert needle in container, needle
assert 'ihp-sg13g2' not in container
print(f'PASS config top={top} tiles=6x4 pdk=ihp-sg13cmos5l')
