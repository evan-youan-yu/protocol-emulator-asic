# Early safety properties

`make formal` invokes SymbiYosys when installed. The bounded proof depth is 20 clocks and uses Z3. Properties in `src/project.v` assert GPIO release during reset/inactive/halt, PC hold while WAIT is counting, PC hold while halted, and no loader valid-bit change on a write attempted after memory is full. Inputs are unconstrained; no assumptions suppress possible host activity. The properties only cover these local invariants, not eventual response, full memory contents, or timing closure.

The first sampled clock is constrained to reset low; all host and GPIO inputs remain unconstrained thereafter. `core.sby` checks safety to depth 20; `reach.sby` seeks an actual reachable WAIT state to depth 50. This is bounded evidence and does not establish unbounded correctness.
