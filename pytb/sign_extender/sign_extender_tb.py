import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_run(dut):
    #cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await Timer(5, unit="ns")
    dut.immediate_data.value=0b1000000000001111111111111
    dut.imm_cntrl.value=0
    

    await Timer(5, unit="ns")
   
    dut.immediate_data.value=0b0000000111111111111100000
    dut.imm_cntrl.value=1
    await Timer(5, unit="ns")
    dut.immediate_data.value=0b0000000111111111101100001
    dut.imm_cntrl.value=2
    await Timer(5, unit="ns")
  
    
