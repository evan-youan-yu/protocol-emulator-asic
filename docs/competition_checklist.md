# Submission checklist

| Item | Status | Evidence / remaining work |
|---|---|---|
| Open-source CMOS5L template | PASS local | SHA recorded in `docs/references.md` |
| `info.yaml` 6×4 tiles and standard wrapper | CONFIGURED | Official precheck not run |
| Post-fabrication program loading | PASS RTL | Host-nibble loader tested with two programs; silicon unverified |
| Owner-specific top module and author | CONFIGURED | GitHub account `evan-youan-yu`; name and owner should be confirmed for final submission |
| RTL, lint, generic synthesis | PASS local | `reports/status.md` and logs |
| Bounded formal safety and WAIT reachability | PASS local | `reports/logs/formal-*.log`; not an unbounded proof |
| User-owned public GitHub repository and Actions | PASS | Public `evan-youan-yu/protocol-emulator-asic`; `test`, `verification`, `docs` first runs passed |
| GDS, STA, DRC/LVS, precheck, gate-level | RUNNING | Official GDS run 39417341092; inspect final jobs and reports |
| 50 MHz timing | NOT VERIFIED | Requires routed timing report |
| UART, SPI, I²C firmware and independent checking | NOT RUN | Future milestones |
| Competition submission | NOT RUN | Deadline 2027-01-18; submission form pending |
