import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_reset(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    
    dut.reset.value = 0
   # dut.Next_instruction_flag.value = 0
    await RisingEdge(dut.clk)

    dut.reset.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    dut.read_reg1_address.value=0
    dut.read_reg2_address.value=0
    dut.wd.value=10
    dut.write_data_enable.value=1
    dut.write_address.value=1
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
   
    dut.read_reg1_address.value=1
    dut.read_reg2_address.value=0
    dut.wd.value=10
    dut.write_data_enable.value=0
    dut.write_address.value=0
    await Timer(1, unit="ns")
    print(f"read_data_1 = {dut.rd1.value}")
    print(f"read_data_2 = {dut.rd2.value}")
   
    await Timer(1, unit="ns")
    assert dut.rd1.value == 10, f"Expected 10, got {dut.rd1.value}"
   
