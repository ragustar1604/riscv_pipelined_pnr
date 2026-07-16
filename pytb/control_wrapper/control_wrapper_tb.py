import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_reset(dut):
   


    await Timer(20, unit="ns")
    dut.instruction.value=0XFFC4A303

    await Timer(20, unit="ns")
    dut.instruction.value=0X0064A423


    await Timer(20, unit="ns")

    dut.instruction.value=0X0062E233
    await Timer(20, unit="ns")

    dut.instruction.value=0XFE420AE3

    await Timer(20, unit="ns")