"""Top-level host driver and cycle scoreboard for RTL and GL tests."""
from cocotb.triggers import RisingEdge, Timer


class Bench:
    def __init__(self, dut):
        self.dut = dut
        self.req = 0
        self.cycle = 0

    async def edge(self):
        await RisingEdge(self.dut.clk)
        await Timer(1, unit='ns')
        self.cycle += 1

    async def reset(self):
        d = self.dut
        d.ena.value = 1
        d.ui_in.value = 0
        d.uio_in.value = 0
        d.rst_n.value = 0
        for _ in range(3):
            await self.edge()
        assert int(d.uio_oe.value) == 0
        d.rst_n.value = 1
        await self.edge()

    async def command(self, cmd, nibble=0):
        self.req ^= 1
        self.dut.ui_in.value = (self.req << 7) | (cmd << 4) | nibble
        for _ in range(8):
            await self.edge()
            if (int(self.dut.uo_out.value) >> 7) == self.req:
                return
        raise AssertionError(f'host timeout cycle={self.cycle} cmd={cmd} pc={int(self.dut.uo_out.value)&15}')

    async def load(self, words):
        assert len(words) <= 16
        await self.command(3)
        for word in words:
            for shift in (0, 4, 8, 12):
                await self.command(0, (word >> shift) & 15)

    def compare(self, model, enabled=True):
        d = self.dut
        status = int(d.uo_out.value)
        actual = (status & 15, (status >> 6) & 1, (status >> 5) & 1,
                  int(d.uio_out.value), int(d.uio_oe.value))
        expected = (model.pc, int(model.running), int(model.fault),
                    model.out, model.oe if enabled and model.running else 0)
        word = f'{model.program[model.pc]:#06x}' if model.pc < len(model.program) else 'unwritten'
        assert actual == expected, (f'cycle={self.cycle} pc={model.pc} '
                                    f'word={word} '
                                    f'wait={model.remaining} expected={expected} actual={actual}')
