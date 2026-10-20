# GitHub publication and ASIC Actions

This local repository currently has only an `upstream` remote pointing to the official Tiny Tapeout template. There is no user-owned `origin` remote and no authenticated GitHub CLI session. The `protocol-emulator-asic` name is proposed; the owner and final repository visibility must be confirmed before publishing.

After authenticating the GitHub connection or CLI, establish a public repository under the chosen owner, add it as `origin`, and push the reviewed `main` branch. The normal CLI path is:

```sh
conda activate "$PWD/.conda"
gh auth login --hostname github.com --web
gh repo create OWNER/protocol-emulator-asic --public --source . --remote origin --push
gh repo view OWNER/protocol-emulator-asic --json url,defaultBranchRef
gh workflow list --repo OWNER/protocol-emulator-asic
```

Replace `OWNER` with the confirmed account or organization. Never push to `upstream`. On first push, `.github/workflows/test.yaml`, `.github/workflows/verification.yaml`, and `.github/workflows/gds.yaml` may trigger automatically. Check each run and download its artifacts. Before interpreting physical results, verify that the run uses `ihp-sg13cmos5l`, then inspect synthesis area, routing, timing, precheck, and gate-level results. A configured workflow alone is not a PASS.

If CLI authentication is unavailable, the connected GitHub app may provide repository and Actions access. Record the repository URL and run URL in the verification report once they actually exist.
