# M1 instruction set

This is a provisional 16-bit, 16-word baseline. It is not a final competition ISA. Program words are loaded through the host nibble protocol in [pin_map.md](pin_map.md).

| Opcode `[15:12]` | Mnemonic | Operand | Rising-edge behavior |
|---|---|---|---|
| `1` | `SET value` | `[7:0]` output value | Update output register; PC + 1 |
| `2` | `WAIT N` | `[11:0]` count | N=0: PC + 1. N>0: hold PC for N following edges, then PC + 1 |
| `3` | `JMP addr` | `[3:0]` address | Set PC to address |
| `4` | `OE mask` | `[7:0]` output enable mask | Update OE register; PC + 1 |
| `5` | `WAIT_PIN pin,level` | `[2:0]` pin, `[3]` level | PC + 1 only when synchronized input equals level |
| `F` | `HALT` | none | Stop and release GPIO |

All other opcodes cause a sticky error and halt. An unwritten program word does the same. Operands outside the documented bit fields are reserved and ignored in this baseline. Sequential PC increment wraps from 15 to 0; programs should use an explicit `JMP` or `HALT` to avoid accidental wrap.

One instruction is fetched and committed on a rising edge. `SET`, `OE`, and `JMP` each use one active edge. `WAIT N` uses its issue edge plus N waiting edges; the PC advances on the last waiting edge. `WAIT_PIN` tests the two-flop synchronized input on each active edge. A successful test advances PC on that edge. The next instruction executes on the next edge. `HALT` and error release `uio_oe` immediately after their committing edge.

Start resets PC, wait state, output value, and OE, but preserves program memory. Halt preserves memory and PC. Clear/reload stops execution and invalidates the complete memory; it does not require reset. `ena=0` pauses PC/timer and releases outputs, while the input synchronizers continue sampling. System reset invalidates all program words. Firmware cannot read back memory in M1.
