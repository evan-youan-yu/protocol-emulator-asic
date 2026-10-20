# Pin map (M1 baseline)

The eight `uio` pins belong to firmware GPIO. Host programming uses only dedicated inputs and outputs, so reloading never depends on executing firmware.

| Pin | Direction | Purpose | Reset / inactive |
|---|---|---|---|
| `ui_in[7]` | input | Host request toggle | host drives 0 |
| `ui_in[6:4]` | input | Host command | stable through acknowledgement |
| `ui_in[3:0]` | input | Host payload nibble | stable through acknowledgement |
| `uo_out[7]` | output | Acknowledgement toggle, equals accepted request | 0 |
| `uo_out[6]` | output | Running flag | 0 |
| `uo_out[5]` | output | Sticky error flag | 0 |
| `uo_out[4]` | output | Loader full flag | 0 |
| `uo_out[3:0]` | output | Current PC, debug only | 0 |
| `uio[7:0]` | bidirectional | Firmware controlled GPIO | output enable 0 |
| `ena` | input | TT project select; pauses execution and releases GPIO when low | outputs released |
| `clk`, `rst_n` | inputs | Single system clock, active-low asynchronous reset | reset asserted |

Host command codes: `0` loads one nibble, `1` starts program at PC 0, `2` halts, and `3` clears the program memory valid bits and loader position. Other commands set the error flag. Four nibbles, least significant first, make one 16-bit instruction. Memory contains 16 instructions. After the final slot, loader full becomes 1 and further writes set error until command 3. Command 3 is the required first command before each new firmware image. Command 1 is rejected if instruction zero is unwritten.

For each transaction, keep command and nibble stable, toggle `ui_in[7]`, then wait until `uo_out[7]` matches it before changing data. The request passes through two flip-flops. The multibit data is sampled only after that delay and must remain stable until acknowledgement. The host must remain clocked and `ena=1` for progress. This is a bundled-data handshake, not a general asynchronous bus. The external `uio_in` GPIO levels pass through a separate two-flop synchronizer; pulse capture shorter than two cycles is not guaranteed. No external clock is supported in M1.

`uio_oe` is active high. Reset, halt, an unwritten instruction, and `ena=0` release every GPIO. Firmware can drive a GPIO only after executing `OE` to set its output-enable bit. Open-drain use requires firmware to keep `uio_out` low and switch only `uio_oe`; the board supplies the pull-up. Electrical open-drain behavior and I²C timing have not yet been validated.
