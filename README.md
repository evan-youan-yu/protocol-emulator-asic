# Programmable Protocol Emulator ASIC

Experimental firmware-loaded GPIO sequencer for the [Jane Street Protocol Emulator ASIC Competition](https://blog.janestreet.com/protocol-emulator-asic-competition/). Based on the official Tiny Tapeout `cmos5l` template at SHA `231f26a58b8d2efbab25bef24b29c94362a431a3` (Apache-2.0). The 6×4 tile allocation and 50 MHz target are configured; physical timing and signoff are not yet verified.

## Quick start

```sh
./scripts/setup_env.sh
make doctor
make regress
make report
```

The project-local Conda environment is `.conda`. `make test` drives two distinct firmware images through the Tiny Tapeout top-level pins, checks GPIO, status and PC against a Python cycle model, and creates `test/tb.fst`. `make lint` and `make synth-smoke` run Verilator and generic Yosys. `reports/status.md` summarizes observed local evidence.

The current M1 instruction set supports SET, OE, WAIT, JMP, WAIT_PIN and HALT in a 16-word flip-flop memory. The design is an early ASIC-flow baseline, not a complete UART/SPI/I²C product. See [architecture](docs/architecture.md), [ISA](docs/isa.md), [host and pin map](docs/pin_map.md), [timing](docs/timing_contract.md), [verification](docs/verification_plan.md), and [setup](docs/setup.md).

The official CMOS5L GDS, precheck, GL test and docs workflows remain in `.github/workflows`. A project GitHub Actions run and CMOS5L PDK are required before claiming GDS, DRC/LVS or 50 MHz timing. See [physical flow](docs/physical_flow.md) and [submission checklist](docs/competition_checklist.md).
