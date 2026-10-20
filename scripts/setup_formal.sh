#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_dir="$root/.conda"
export PATH="$env_dir/bin:$PATH"
if [[ -x "$env_dir/bin/sby" ]]; then
  echo 'SymbiYosys already installed in Conda environment'
  exit 0
fi
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
git clone https://github.com/YosysHQ/sby.git "$scratch/sby"
git -C "$scratch/sby" checkout -q 79fc9eddca5e33a28cc2f2cd19c9825efd9a7255
make -C "$scratch/sby" install PREFIX="$env_dir"
"$env_dir/bin/sby" --version
