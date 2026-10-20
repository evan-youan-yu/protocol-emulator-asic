# Reproduce locally

Requirements: Linux, Git, Conda and internet access for initial package download. From the repository root:

```sh
./scripts/setup_env.sh
conda activate "$PWD/.conda"
make doctor
make regress
make report
```

`setup_env.sh` creates a project-local Conda environment with Python 3.11, Icarus, Verilator, Yosys, Z3 and Make, then installs the official Cocotb 2.0.1 and pytest 8.4.2 pins. It installs SymbiYosys from pinned source commit `79fc9eddca5e33a28cc2f2cd19c9825efd9a7255` into that environment. It is safe to rerun. The shell need not remain activated for root Make targets because they prefer `.conda/bin` automatically. The FST waveform is `test/tb.fst`; use GTKWave or Surfer if installed. `make clean` removes only generated test outputs and preserves evidence logs.

`make doctor` reports the RTL tools. `make formal` runs a 20-cycle bounded proof and a 50-cycle reachability cover. For physical design on Ubuntu, first run `bash scripts/install_host_docker.sh` in a visible system terminal so you can enter a sudo password there. Then run `./scripts/setup_physical.sh` and `make physical-doctor`; setup creates a separate Conda environment, installs the pinned CMOS5L PDK and downloads the pinned LibreLane image. `make gds-local` runs the official hardening flow, archives key evidence from any previous run, checks final metrics, and builds `tt_submission/`. Then run `make gl-local`, `make precheck-local`, `make physical-report`, and `make report`. See [physical_flow.md](physical_flow.md) for exact pins and status.

The Conda environment also contains GitHub CLI (`gh`). See [GitHub setup](github_setup.md) for publication and Actions steps. Authentication is a separate user action; installing `gh` does not grant account access.
