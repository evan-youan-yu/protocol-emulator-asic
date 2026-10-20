# Timing contract (M1)

The project declares a 50 MHz, 20 ns target in `info.yaml` and the official physical configuration. This is a design target, not a measured frequency. RTL simulation may use a different period without changing edge counts.

- All architectural updates occur at `clk` rising edges; `rst_n=0` resets asynchronously.
- The host request passes two flip-flops before command acceptance. The host holds the other `ui_in` bits until acknowledgement changes. A command can take at least two active edges; software waits for acknowledgement instead of assuming a fixed duration.
- GPIO input passes two flip-flops. `WAIT_PIN` observes the synchronized level; input-to-PC response depends on phase and is typically two or three active edges. No short pulse capture or external-clock protocol is promised.
- `WAIT N` holds PC on the issue edge and N subsequent edges, advancing it on the last of those N edges. Thus `WAIT 1` occupies two edges. `WAIT 0` occupies one.
- `SET` updates pins following its issue edge if `OE` has enabled them. A `JMP` uses one edge. `ena=0` pauses the core and makes OE zero combinationally.
- The timer is 12 bits, matching the WAIT operand. The longest encoded delay is 4095 waiting edges. There is no free-running timer or timer rollover in M1.

Physical setup/hold and routed event deadlines remain unverified until CMOS5L timing reports exist.
