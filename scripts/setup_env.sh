#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
env_dir="$root/.conda"
export PATH="$env_dir/bin:$PATH"
command -v conda >/dev/null || { echo 'conda is required' >&2; exit 1; }
if [[ ! -x "$env_dir/bin/python" ]]; then
  conda create -y --override-channels -c conda-forge -p "$env_dir" python=3.11 pip make iverilog verilator yosys z3-solver
fi
"$env_dir/bin/python" -m pip install -r "$root/test/requirements.txt" PyYAML==6.0.3 click==8.3.0
if [[ ! -x "$env_dir/bin/z3" ]]; then
  conda install -y --override-channels -c conda-forge -p "$env_dir" z3-solver
fi
"$root/scripts/setup_formal.sh"
"$root/scripts/check_tool_versions.sh"
