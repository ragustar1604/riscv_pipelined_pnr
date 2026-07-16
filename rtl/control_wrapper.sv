module control_wrapper#(parameter DATA_WIDTH=32)(
input [DATA_WIDTH-1:0]instruction,
output logic [2:0]func3,
output logic func7,
//output logic op_5,
output logic invalid_instruction_cntrl,
output logic Result_src,
output logic Memwrite,
output logic ALUSrc,
output logic [1:0]imm_src,
output logic Reg_write,
output logic Branch,
output logic [2:0]alu_control,
output logic invalid_instruction
);

logic [6:0]op_code;
logic op_5;
logic [1:0]ALU_operation;
    
assign op_code=instruction[6:0];
assign func3=instruction[14:12];
assign func7=instruction[30];
assign op_5=instruction[5];
control_decoder dut(.*);
alu_decoder dutt(.*);

endmodule