# CMOS5L physical flow

The authoritative flow is `.github/workflows/gds.yaml` from template `cmos5l` SHA `231f26a58b8d2efbab25bef24b29c94362a431a3`. It uses `TinyTapeout/tt-gds-action@ihp-cmos5l`, `pdk: ihp-sg13cmos5l`, and matching `precheck`, `gl_test`, and viewer actions. `src/config.json` requests a 20 ns clock period. These are configuration facts; physical results require an actual action run.

The general Tiny Tapeout [local hardening guide](https://tinytapeout.com/guides/local-hardening/) currently shows `ihp-sg13g2` for IHP. Do not copy that PDK setting into this project.

## Local CMOS5L environment

First prepare rootless Docker as described below, then run `./scripts/setup_physical.sh` from the repository root. It places a separate Conda Python 3.11 environment, Tiny Tapeout support tools, and the PDK under ignored `.physical/`, and pulls the LibreLane image. It does not modify the verified RTL `.conda` environment. All versions match the official action used by [run 39417341092](https://github.com/evan-youan-yu/protocol-emulator-asic/actions/runs/39417341092):

| Component | Pin |
|---|---|
| `tt-support-tools`, branch `ihp-sg13cmos5l` | `d66cf179e7bc4d296362ab7e2e3b344dc3c4f665` |
| `IHP-Open-PDK` | `2bbec755dc67ca3db0261c3d6163e15735d66710` |
| LibreLane | `3.1.0.dev3` |
| LibreLane image digest | `sha256:d109140b8f17fc54f4fca998beb8124f4949404ec52e339eebd2250854a18b5a` |
| PDK ID | `ihp-sg13cmos5l` |

Run `make physical-doctor` to check those pins, top module, Precheck Python modules, LibreLane image, and rootless Docker availability. Docker is needed for LibreLane's containerized EDA tools. On this Ubuntu host, open a visible desktop terminal and run `bash scripts/install_host_docker.sh`. It installs `docker.io`, `uidmap`, `slirp4netns`, `fuse-overlayfs`, and `rootlesskit` from Ubuntu packages, stops the newly installed rootful Docker service, and sets up a user-owned daemon. It writes a log to `reports/logs/install-host-docker.log`. Verify `docker info` reports `rootless` under Security Options. Do not add the user to the `docker` group, which grants root-level daemon access. See the [Docker rootless guide](https://docs.docker.com/engine/security/rootless/) for prerequisites.

`make gds-local` invokes the official `tt_tool.py --ihp --harden` with the pinned PDK and LibreLane image, then checks the final metrics and creates `tt_submission/`. Key artifacts from an earlier local run are copied to `reports/local-history/` before the new run. `make physical-report` verifies the current GDS, PDK, routed setup/hold, route/Magic DRC, LVS, and antenna reports; it fails if evidence is missing or a check fails. After hardening, `make gl-local` compiles the generated gate-level netlist against the same CMOS5L PDK and runs four Cocotb tests. `make precheck-local` uses the official Tiny Tapeout Precheck Python source and KLayout CLI from the pinned LibreLane container to check the generated GDS. The local KLayout binary is 0.30.9, so the official GitHub action remains the submission authority.

The first local hardening run completed successfully on 2026-10-20. Its standard-cell area is 38,546.9 µm², utilization 4.27152%, worst setup slack +9.5901 ns, worst hold slack +0.1070 ns, with zero final route DRC, Magic DRC, LVS, or antenna errors. Its reported metrics match the official cloud run exactly. The first local GL run on the **local** netlist passed four tests with zero failures. `make precheck-local` on the locally generated GDS passed all nine checks, including KLayout SG13CMOS5L DRC, with zero XML errors/failures.

The template's development container originally pointed at SG13G2. Its Dockerfile is now aligned with the [CMOS5L GDS action defaults](https://github.com/TinyTapeout/tt-gds-action/blob/ihp-cmos5l/action.yml): `ihp-sg13cmos5l` support tools and LibreLane `3.1.0.dev3`. That separate development container has not been built; local hardening used the pinned LibreLane container image described above.

The first official cloud run's `gds`, `precheck`, and `gl_test` jobs passed. The downloaded evidence is in ignored `reports/ci/gds/`; see [CI evidence](ci_evidence.md) for the exact metrics. The viewer originally failed because GitHub Pages was disabled. In [fresh run 39433571551](https://github.com/evan-youan-yu/protocol-emulator-asic/actions/runs/39433571551), `gds`, `gl_test`, and `viewer` passed; its `precheck` job is still running. The [public GDS viewer](https://evan-youan-yu.github.io/protocol-emulator-asic/) returned HTTP 200 after deployment. `KLayout.DRC` within LibreLane was skipped by the template config; the separate official Precheck **did** execute KLayout SG13CMOS5L DRC and passed in the first run. Negative slack or incomplete checks are failures, not tapeout readiness. Generic Yosys statistics in this repository do not measure CMOS5L cell area.
