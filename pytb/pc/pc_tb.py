import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_reset(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    
    dut.reset.value = 0
    dut.Next_instruction_flag.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    
    assert dut.Pc.value == 0, f"Expected 0, got {dut.Pc.value}"

@cocotb.test()
async def test_increment(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    
    dut.reset.value = 0
    dut.Next_instruction_flag.value = 0
    await RisingEdge(dut.clk)
    
    dut.reset.value = 1
    dut.Next_instruction_flag.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")

    for expected in [4, 8, 12, 16, 20]:
        assert dut.Pc.value == expected, f"Expected {expected}, got {dut.Pc.value}"
        await RisingEdge(dut.clk)
        await Timer(1, unit="ns")