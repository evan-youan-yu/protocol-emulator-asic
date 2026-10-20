# GitHub publication and ASIC Actions

The public repository is [evan-youan-yu/protocol-emulator-asic](https://github.com/evan-youan-yu/protocol-emulator-asic). `origin` points there; `upstream` remains the official Tiny Tapeout template. GitHub CLI is installed in the project Conda environment. Authenticate a new machine separately with `gh auth login --hostname github.com --web`.

To inspect or rerun the official workflows:

```sh
conda activate "$PWD/.conda"
gh workflow list --repo evan-youan-yu/protocol-emulator-asic
gh run list --repo evan-youan-yu/protocol-emulator-asic
gh workflow run gds.yaml --repo evan-youan-yu/protocol-emulator-asic
```

The initial push at `ad51d20` triggered `test`, `verification`, `docs`, and `gds` workflows. The first three completed successfully. The `gds` [run 39417341092](https://github.com/evan-youan-yu/protocol-emulator-asic/actions/runs/39417341092) must be inspected separately for GDS, precheck, gate-level, and physical reports. Before interpreting physical results, verify that the run uses `ihp-sg13cmos5l`, then inspect synthesis area, routing, timing, precheck, and gate-level results. A configured workflow alone is not a PASS.

Do not push to `upstream`. Downloaded CI artifacts belong in the ignored `reports/ci/` directory. GitHub CLI authentication may appear unavailable inside a network-restricted sandbox even when the host session is authenticated; verify with `gh auth status` in a terminal with GitHub access.
