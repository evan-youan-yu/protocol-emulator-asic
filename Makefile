SHELL := /bin/bash
.SHELLFLAGS := -e -o pipefail -c
ROOT := $(abspath .)
ifneq ($(wildcard $(ROOT)/.conda/bin/python),)
  export PATH := $(ROOT)/.conda/bin:$(PATH)
  PYTHON := $(ROOT)/.conda/bin/python
else
  PYTHON := python3
endif
.PHONY: help doctor config-check python-check lint test synth-smoke regress formal report clean
help:
	@printf '%s\n' 'make doctor lint test synth-smoke regress formal report clean'
doctor:
	@./scripts/doctor.sh
config-check:
	@$(PYTHON) scripts/check_config.py
python-check:
	@mkdir -p reports/logs
	$(PYTHON) -m compileall -q tools scripts test
	$(PYTHON) -m pytest -q tests 2>&1 | tee reports/logs/python-test.log
lint:
	@mkdir -p reports/logs
	verilator --lint-only -Wall -Wno-fatal -Wno-DECLFILENAME --top-module tt_um_evan_youan_yu_ppe src/project.v 2>&1 | tee reports/logs/lint.log
test:
	@mkdir -p reports/logs
	$(MAKE) -C test clean
	$(MAKE) -C test 2>&1 | tee reports/logs/test.log
	$(PYTHON) scripts/check_results.py test/results.xml
	@test -s test/tb.fst
synth-smoke:
	@mkdir -p reports/logs
	yosys -Q -T -l reports/logs/synth.log -p 'read_verilog src/project.v; hierarchy -check -top tt_um_evan_youan_yu_ppe; synth -top tt_um_evan_youan_yu_ppe; check -assert; stat' >/dev/null
regress: config-check python-check lint test synth-smoke
formal:
	@mkdir -p reports/logs
	@if ! command -v sby >/dev/null; then echo 'BLOCKED: SymbiYosys not installed'; exit 2; fi
	sby -f formal/core.sby 2>&1 | tee reports/logs/formal-core.log
	sby -f formal/reach.sby 2>&1 | tee reports/logs/formal-reach.log
report:
	@$(PYTHON) scripts/report.py
clean:
	@$(MAKE) -C test clean
	@rm -rf test/tb.fst test/tb.vcd test/results.xml test/sim_build
