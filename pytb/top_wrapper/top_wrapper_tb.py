import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_reset(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    #await RisingEdge(dut.clk)

    dut.reset.value = 0
    await RisingEdge(dut.clk)
    dut.reset.value = 0
    
    await Timer(4, unit="ns")


    await RisingEdge(dut.clk)
    await Timer(4, unit="ns")
    dut.reset.value = 1
    await Timer(4, unit="ns")

    await RisingEdge(dut.clk)
    await Timer(4, unit="ns")
    #dut.reset.value = 0

    await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)
    #dut.reset.value = 1
    await Timer(4, unit="ns")
  

    await RisingEdge(dut.clk)
    await Timer(4, unit="ns")
    #dut.reset.value = 0
    await RisingEdge(dut.clk)
    await Timer(4, unit="ns")

    await RisingEdge(dut.clk)
    await Timer(4, unit="ns")

    await RisingEdge(dut.clk)
    await Timer(4, unit="ns")

    await RisingEdge(dut.clk)
    await Timer(4, unit="ns")


    await RisingEdge(dut.clk)
    await Timer(4, unit="ns")


    await RisingEdge(dut.clk)
    await Timer(4, unit="ns")


    await RisingEdge(dut.clk)
    await Timer(4, unit="ns")

    await RisingEdge(dut.clk)
    await Timer(4, unit="ns")

 
   
