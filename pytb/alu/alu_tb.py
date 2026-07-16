import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_reset(dut):


    dut.Data_1.value = 5
    dut.Data_2.value = 6
    dut.control_info.value = 0b000

    #await RisingEdge(dut.clk)
    await Timer(5, unit="ns")
    log.info(f"addition = {dut.alu_result.value}")
    dut.Data_1.value = 8
    dut.Data_2.value = 6
    dut.control_info.value = 0b001

    await Timer(5, unit="ns")
    log.info(f"subtraction = {dut.alu_result.value}")
    dut.Data_1.value = 1
    dut.Data_2.value = 3
    dut.control_info.value = 0b010

    await Timer(5, unit="ns")
    log.info(f"and gate = {dut.alu_result.value}")
    dut.Data_1.value = 5
    dut.Data_2.value = 3
    dut.control_info.value = 0b011

    await Timer(5, unit="ns")
    log.info(f"or gate= {dut.alu_result.value}")
    dut.Data_1.value = 10
    dut.Data_2.value = 6
    dut.control_info.value = 0b101

    await Timer(5, unit="ns")
    log.info(f"comparator= {dut.alu_result.value}")
    dut.Data_1.value = 5
    dut.Data_2.value = 6
    dut.control_info.value = 0b111

    await Timer(5, unit="ns")

    

  
   
