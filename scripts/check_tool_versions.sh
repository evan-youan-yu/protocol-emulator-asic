#!/usr/bin/env bash
set -u
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bin="$root/.conda/bin"
printf 'template_sha=%s\n' "$(git -C "$root" rev-parse upstream/cmos5l 2>/dev/null || git -C "$root" rev-parse origin/cmos5l 2>/dev/null || echo unknown)"
for tool in python iverilog verilator yosys z3 gh; do
  if [[ -x "$bin/$tool" ]]; then
    case "$tool" in
      python) "$bin/$tool" --version ;;
      iverilog) "$bin/$tool" -V 2>&1 | head -1 ;;
      verilator) "$bin/$tool" --version ;;
      yosys) "$bin/$tool" -V ;;
      z3) "$bin/$tool" --version ;;
      gh) "$bin/$tool" --version | head -1 ;;
    esac
  else
    printf '%s=MISSING\n' "$tool"
  fi
done
if [[ -x "$bin/python" ]]; then
  "$bin/python" -m pip show cocotb pytest PyYAML 2>/dev/null | grep -E '^(Name|Version):' || true
fi
