# CMOS5L physical flow

The authoritative flow is `.github/workflows/gds.yaml` from template `cmos5l` SHA `231f26a58b8d2efbab25bef24b29c94362a431a3`. It uses `TinyTapeout/tt-gds-action@ihp-cmos5l`, `pdk: ihp-sg13cmos5l`, and matching `precheck`, `gl_test`, and viewer actions. `src/config.json` requests a 20 ns clock period. These are configuration facts; physical results require an actual action run.

The general Tiny Tapeout [local hardening guide](https://tinytapeout.com/guides/local-hardening/) currently shows `ihp-sg13g2` for IHP. Do not copy that PDK setting into this project. A local command should be added only after pinning a CMOS5L-compatible support-tools revision, LibreLane version, PDK revision, container runtime, and validating it against the official action. No `make gds` target is supplied yet.

On a GitHub repository, enable Actions and run the existing `gds` workflow. Retain the run URL, action version, PDK revision, mapped cell/area report, utilization, setup and hold slack, critical path, routing, DRC/LVS/antenna status, precheck output, GDS artifact, and GL test XML. Negative slack or incomplete checks are failures, not tapeout readiness. Generic Yosys statistics in this repository do not measure CMOS5L cell area.
