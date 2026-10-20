"""Cycle oracle from docs/isa.md, independent of RTL internal hierarchy."""
from dataclasses import dataclass, field


@dataclass
class CoreModel:
    program: list[int]
    pc: int = 0
    remaining: int = 0
    running: bool = True
    fault: bool = False
    out: int = 0
    oe: int = 0
    synchronized_input: int = 0
    _input_stage: int = 0

    def tick(self, external_input: int = 0, enabled: bool = True) -> None:
        old_input = self.synchronized_input
        self.synchronized_input = self._input_stage
        self._input_stage = external_input & 0xFF
        if not enabled or not self.running:
            return
        if self.pc >= len(self.program):
            self.fault = True
            self.running = False
            return
        if self.remaining:
            self.remaining -= 1
            if self.remaining == 0:
                self.pc = (self.pc + 1) & 0xF
            return
        word = self.program[self.pc]
        opcode = word >> 12
        if opcode == 1:
            self.out = word & 0xFF
            self.pc = (self.pc + 1) & 0xF
        elif opcode == 2:
            n = word & 0xFFF
            if n:
                self.remaining = n
            else:
                self.pc = (self.pc + 1) & 0xF
        elif opcode == 3:
            self.pc = word & 0xF
        elif opcode == 4:
            self.oe = word & 0xFF
            self.pc = (self.pc + 1) & 0xF
        elif opcode == 5:
            pin = word & 7
            level = (word >> 3) & 1
            if ((old_input >> pin) & 1) == level:
                self.pc = (self.pc + 1) & 0xF
        elif opcode == 15:
            self.running = False
        else:
            self.fault = True
            self.running = False
