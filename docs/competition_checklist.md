# Submission checklist

| Item | Status | Evidence / remaining work |
|---|---|---|
| Open-source CMOS5L template | PASS local | SHA recorded in `docs/references.md` |
| `info.yaml` 6×4 tiles and standard wrapper | PASS | Official precheck run 39417341092 |
| Post-fabrication program loading | PASS RTL | Host-nibble loader tested with two programs; silicon unverified |
| Owner-specific top module and author | CONFIGURED | GitHub account `evan-youan-yu`; name and owner should be confirmed for final submission |
| RTL, lint, generic synthesis | PASS local | `reports/status.md` and logs |
| Bounded formal safety and WAIT reachability | PASS local | `reports/logs/formal-*.log`; not an unbounded proof |
| User-owned public GitHub repository and Actions | PASS | Public `evan-youan-yu/protocol-emulator-asic`; `test`, `verification`, `docs` first runs passed |
| GDS, STA, DRC/LVS, precheck, gate-level | PASS cloud | Official run 39417341092; inspected final metrics, Precheck report, and GL XML |
| 50 MHz timing | PASS cloud/local | Routed 20 ns constraint, worst setup slack +9.5901 ns; three corners checked |
| Complete local GDS flow | PASS | Pinned CMOS5L hardening, routed STA, Magic DRC, LVS, antenna and GDS; metrics match cloud run |
| Local GL test | PASS | Four Cocotb tests on locally generated gate-level netlist, zero failures |
| Local Tiny Tapeout Precheck | PASS | `make precheck-local` passed all nine checks on the locally generated GDS |
| UART, SPI, I²C firmware and independent checking | NOT RUN | Future milestones |
| Competition submission | NOT RUN | Deadline 2027-01-18; submission form pending |
