import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_run(dut):
   

   
        await Timer(5, unit="ns")
        dut.func3.value=0
        dut.ALU_operation.value=0b00
        dut.func7.value=0
        dut.op_5.value=0

        await Timer(5, unit="ns")

        dut.func3.value=0
        dut.ALU_operation.value=0b01
        dut.func7.value=0
        dut.op_5.value=0
        await Timer(5, unit="ns")

        dut.func3.value=0
        dut.ALU_operation.value=0b10
        dut.func7.value=1
        dut.op_5.value=1
        await Timer(5, unit="ns")

        dut.func3.value=0
        dut.ALU_operation.value=0b10
        dut.func7.value=0
        dut.op_5.value=1
        await Timer(5, unit="ns")

        dut.func3.value=2
        dut.ALU_operation.value=0b10
        dut.func7.value=0
        dut.op_5.value=1
        await Timer(5, unit="ns")

        dut.func3.value=0b110
        dut.ALU_operation.value=0b10
        dut.func7.value=0
        dut.op_5.value=1
        await Timer(5, unit="ns")

        dut.func3.value=0b111
        dut.ALU_operation.value=0b10
        dut.func7.value=0
        dut.op_5.value=1
        await Timer(5, unit="ns")

        dut.func3.value=0
        dut.ALU_operation.value=0b11
        dut.func7.value=0
        dut.op_5.value=0
        await Timer(5, unit="ns")

   
