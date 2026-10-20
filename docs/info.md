## How it works

This experimental programmable protocol engine accepts 16-bit instructions as four nibbles over a dedicated Tiny Tapeout host handshake. A 16-word sequencer can set GPIO values, control output enable, wait for clock cycles or a synchronized input level, branch and halt. Firmware can be replaced by first issuing the halt and clear commands. The GPIO pins are released during reset, halt or deselection.

## How to test

Run `./scripts/setup_env.sh`, then `make test` from the repository root. The Cocotb testbench loads two different programs through top-level pins and checks their waveforms and cycle behavior. Read `docs/pin_map.md` for host transactions and `docs/isa.md` for instruction encoding.

## External hardware

A clock and reset source are required. The host controller must keep request data stable until acknowledgement. External pull-ups are required for future open-drain use. No real hardware protocol has been validated yet.
