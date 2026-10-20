# First GitHub Actions run

Repository: [evan-youan-yu/protocol-emulator-asic](https://github.com/evan-youan-yu/protocol-emulator-asic) (public). First pushed commit: `ad51d20a6de999dc7264afd6696af30b9e5110de`. Observed 2026-10-20 12:12 UTC. The first run uses the official `cmos5l` action branch and `pdk: ihp-sg13cmos5l` in `.github/workflows/gds.yaml`.

| Workflow | Run | Observed status | Evidence |
|---|---|---|---|
| `test` | [39417341227](https://github.com/evan-youan-yu/protocol-emulator-asic/actions/runs/39417341227) | PASS | `test-results` artifact; XML: 4 tests, 0 failures/errors/skips |
| `verification` | [39417341071](https://github.com/evan-youan-yu/protocol-emulator-asic/actions/runs/39417341071) | PASS | `verification-evidence` artifact; Python 2/2, Cocotb 4/4, formal bounded proof and cover PASS, generic Yosys 1209 cells |
| `docs` | [39417341173](https://github.com/evan-youan-yu/protocol-emulator-asic/actions/runs/39417341173) | PASS | GitHub Actions conclusion `success` |
| `gds` | [39417341092](https://github.com/evan-youan-yu/protocol-emulator-asic/actions/runs/39417341092) | RUNNING | `Build GDS` is in progress; live log reached Magic `drc(full)` after GDS streamout, but no final result or artifact yet |

The downloaded test and verification artifacts are stored locally under ignored `reports/ci/`. GDS, STA timing closure, DRC/LVS, precheck, and gate-level are **not** marked PASS until their final reports and artifacts have been inspected. The live log shows an STA step ran; it does not establish nonnegative slack or a 50 MHz timing result.
