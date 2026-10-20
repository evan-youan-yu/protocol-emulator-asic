"""Encoding helpers for the provisional 16-bit M1 ISA."""


def SET(value: int) -> int:
    return 0x1000 | (value & 0xFF)


def WAIT(cycles: int) -> int:
    assert 0 <= cycles <= 0xFFF
    return 0x2000 | cycles


def JMP(address: int) -> int:
    assert 0 <= address < 16
    return 0x3000 | address


def OE(mask: int) -> int:
    return 0x4000 | (mask & 0xFF)


def WAIT_PIN(pin: int, level: int) -> int:
    assert 0 <= pin < 8 and level in (0, 1)
    return 0x5000 | (level << 3) | pin


HALT = 0xF000
