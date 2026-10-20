# Architecture baseline

`ui_in` host request + nibble → synchronized request → loader → 16 × 16-bit flip-flop instruction memory. A single program counter and decoder issue one instruction per active edge. `WAIT` uses a 12-bit down counter; `WAIT_PIN` reads a synchronized GPIO input. `SET` and `OE` update separate output value and output-enable registers. `uio` is the firmware GPIO bank. `uo_out` exposes acknowledgement, run/error/full status and PC.

The single clock is `clk`. `rst_n` asynchronously clears architectural state and program valid bits. Host requests and GPIO inputs each use two flip-flop synchronizers. The host data bus uses a stable-until-ack bundled-data contract; it has no independent data synchronizers. A host command takes priority over an instruction for one edge, so programming during active execution changes timing. Firmware should be stopped for reloading. `ena=0` pauses execution and releases outputs.

This core is an experimental M1 baseline. It has no RAM macro, FIFO, autonomous event engine, external clock, readback, protocol firmware, or proven throughput. The instruction memory and loader are sized to exercise the full RTL-to-GDS path before expanding the architecture.
