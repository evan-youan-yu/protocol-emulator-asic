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

`make doctor` reports local tools and whether physical tools and `PDK_ROOT/ihp-sg13cmos5l` are available. `make formal` runs a 20-cycle bounded proof and a 50-cycle reachability cover; `make gds` is intentionally absent until a validated CMOS5L local flow exists. To run the official physical jobs, connect this repository to a user-owned GitHub repository with Actions enabled, then run `gds.yaml` and collect its artifacts as described in [physical_flow.md](physical_flow.md).
