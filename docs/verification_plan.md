# Verification plan and observed coverage

| Requirement | Current method | Pass criterion | Status |
|---|---|---|---|
| Official wrapper compiles | Icarus/Cocotb template smoke | XML has tests and zero failures; FST exists | PASS locally |
| Host writes real instruction memory | Top-level four-nibble driver | Two distinct programs run without RTL edit | PASS locally |
| SET/OE/WAIT/JMP timing | Independent Python cycle model | PC, output, OE, run and fault agree every observed edge | PASS for tested cases |
| WAIT_PIN input handling | Top-level GPIO stimulus | Holds then responds after synchronized level | PASS for tested case |
| Reset, halt, `ena`, invalid instruction | Top-level safety tests, including active reset | Outputs released; error reported | PASS for tested cases |
| Seeded random delay programs | Fixed seed `26012027` | Four generated programs agree for 35 cycles each | PASS locally |
| Memory full and rejected overflow write | Top-level loader test | Full/error flags set; clear recovers | PASS locally |
| PC wrap, interrupted host transaction | Planned top-level tests | Defined behavior and no undefined output | NOT RUN |
| Formal safety proof | SymbiYosys/Z3 BMC depth 20 plus WAIT reachability cover | Solver PASS; reset-only initial assumption | PASS bounded locally |
| UART/SPI/I²C protocol compliance | Independent drivers/monitors and firmware | Timing and frame comparisons | NOT RUN |
| CMOS5L physical viability | Official GDS/precheck/GL action | Reports and artifacts from actual run | BLOCKED locally |

The scoreboard compares public pins only. Internal wait count is inferred through PC dwell and GPIO edges; direct internal register comparison is not claimed. Every host transaction has an eight-cycle acknowledgement timeout. The random test seed is printed in the Cocotb log. Tests use clock edges, and reset is covered during execution. Future protocol monitors must use independent transaction models rather than loopback alone.

Planned next cases: loader capacity and interrupted nibble transaction, long WAIT 4095, PC boundary behavior, multiple asynchronous event phases, invalid host command, and gate-level regression. Protocol expansion should add UART 8N1 first, SPI Mode 0 second, then open-drain I²C and a reactive command-response test; each needs an external reference model and timing bounds.
