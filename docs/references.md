# References checked 2026-10-20

- [Jane Street competition announcement](https://blog.janestreet.com/protocol-emulator-asic-competition/): process, current 6×4 maximum, reprogrammability, deadline.
- [Official Tiny Tapeout CMOS5L template](https://github.com/TinyTapeout/ttihp-verilog-template/tree/cmos5l): cloned at `231f26a58b8d2efbab25bef24b29c94362a431a3`, Apache-2.0 LICENSE. Source of wrapper, Cocotb entry, GDS/precheck/GL workflows.
- [Tiny Tapeout local hardening guide](https://tinytapeout.com/guides/local-hardening/): local workflow concepts only; its IHP example selects SG13G2 and is unsuitable without CMOS5L adaptation.
- [Official CMOS5L GDS action](https://github.com/TinyTapeout/tt-gds-action/tree/ihp-cmos5l): source of LibreLane version, support-tools branch and physical workflow.
- [Official CMOS5L PDK install script](https://github.com/TinyTapeout/tt-gds-action/blob/ihp-cmos5l/install_sg13cmos5l.sh): source of IHP-Open-PDK revision `2bbec755dc67ca3db0261c3d6163e15735d66710`.
- [Docker rootless guide](https://docs.docker.com/engine/security/rootless/): host prerequisites and user-owned Docker daemon setup.

Other suggested participant repositories have not been incorporated. Their licenses, PDKs, CI state, and silicon claims still require separate review before borrowing any implementation.
