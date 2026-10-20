"""M1 system tests. All stimulus enters through Tiny Tapeout top-level pins."""
import random

import cocotb
from cocotb.clock import Clock

from helpers import Bench
from tools.assembler.isa import JMP, OE, SET, WAIT, WAIT_PIN
from tools.reference_model.core import CoreModel


async def start(dut):
    bench = Bench(dut)
    cocotb.start_soon(Clock(dut.clk, 20, unit='ns').start())
    await bench.reset()
    return bench


@cocotb.test()
async def reprogram_two_protocols(dut):
    bench = await start(dut)
    square = [OE(1), SET(1), WAIT(2), SET(0), WAIT(2), JMP(1)]
    await bench.load(square)
    await bench.command(1)
    model = CoreModel(square)
    observed = set()
    for _ in range(40):
        await bench.edge()
        model.tick()
        bench.compare(model)
        observed.add(int(dut.uio_out.value) & 1)
    assert observed == {0, 1}, f'waveform did not toggle at cycle={bench.cycle}'

    await bench.command(2)
    assert int(dut.uio_oe.value) == 0
    reactive = [OE(1), WAIT_PIN(1, 1), SET(1), WAIT(2), SET(0), JMP(1)]
    await bench.load(reactive)
    await bench.command(1)
    model = CoreModel(reactive)
    for _ in range(8):
        await bench.edge()
        model.tick(0)
        bench.compare(model)
    assert model.pc == 1 and int(dut.uio_out.value) == 0
    dut.uio_in.value = 2
    saw_response = False
    for _ in range(16):
        await bench.edge()
        model.tick(2)
        bench.compare(model)
        saw_response |= (int(dut.uio_out.value) & 1) != 0
    assert saw_response, f'no event response at cycle={bench.cycle}'


@cocotb.test()
async def safety_and_invalid_program(dut):
    bench = await start(dut)
    await bench.command(1)
    assert (int(dut.uo_out.value) >> 5) & 1, 'starting empty memory must fault'
    await bench.load([OE(0xFF), SET(0xAA), JMP(1)])
    assert ((int(dut.uo_out.value) >> 5) & 1) == 0, 'clear command must clear fault'
    await bench.command(1)
    for _ in range(5):
        await bench.edge()
    assert int(dut.uio_oe.value) == 0xFF
    dut.ena.value = 0
    await bench.edge()
    assert int(dut.uio_oe.value) == 0
    pc = int(dut.uo_out.value) & 15
    for _ in range(4):
        await bench.edge()
    assert (int(dut.uo_out.value) & 15) == pc, 'ena=0 must pause PC'
    dut.ena.value = 1
    await bench.command(2)
    assert int(dut.uio_oe.value) == 0
    await bench.load([0x0000])
    await bench.command(1)
    await bench.edge()
    assert ((int(dut.uo_out.value) >> 5) & 1) and int(dut.uio_oe.value) == 0
    dut.rst_n.value = 0
    await bench.edge()
    assert int(dut.uio_oe.value) == 0 and int(dut.uo_out.value) == 0


@cocotb.test()
async def loader_capacity_and_active_reset(dut):
    bench = await start(dut)
    await bench.load([JMP(0)] * 16)
    assert (int(dut.uo_out.value) >> 4) & 1, 'full flag must set after word 15'
    await bench.command(0, 0xa)
    assert (int(dut.uo_out.value) >> 5) & 1, 'write past end must report error'
    await bench.command(3)
    assert int(dut.uo_out.value) & 0x30 == 0, 'clear must release full/error flags'
    await bench.load([OE(1), SET(1), JMP(1)])
    await bench.command(1)
    for _ in range(5):
        await bench.edge()
    assert int(dut.uio_oe.value) == 1 and int(dut.uio_out.value) == 1
    dut.rst_n.value = 0
    await bench.edge()
    assert int(dut.uio_oe.value) == 0 and int(dut.uo_out.value) == 0


@cocotb.test()
async def seeded_wait_cycle_comparison(dut):
    bench = await start(dut)
    seed = 26012027
    rng = random.Random(seed)
    for trial in range(4):
        delay = rng.randrange(0, 9)
        word = rng.randrange(0, 256)
        program = [OE(0xFF), SET(word), WAIT(delay), SET(word ^ 0xFF), JMP(1)]
        await bench.load(program)
        await bench.command(1)
        model = CoreModel(program)
        for _ in range(35):
            await bench.edge()
            model.tick()
            bench.compare(model)
        await bench.command(2)
    dut._log.info('seed=%d passed 4 randomized programs', seed)
