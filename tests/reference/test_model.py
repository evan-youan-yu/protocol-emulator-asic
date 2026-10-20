from tools.assembler.isa import JMP, OE, SET, WAIT
from tools.reference_model.core import CoreModel


def test_wait_contract_and_branch():
    model = CoreModel([OE(1), SET(1), WAIT(2), SET(0), JMP(1)])
    expected = [1, 2, 2, 2, 3, 4, 1]
    for pc in expected:
        model.tick()
        assert model.pc == pc
    assert model.out == 0 and model.oe == 1


def test_unwritten_fetch_fails_safe():
    model = CoreModel([SET(1)])
    model.tick()
    assert model.pc == 1
    model.tick()
    assert model.fault and not model.running
