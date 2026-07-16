module branch_alu #(parameter DATA_WIDTH =32,
parameter ADDR_WIDTH =32,
parameter CONTROL_BITS=3,
parameter number_of_elements=20,
parameter total_num_reg=32,
parameter reg_add_size=5,
parameter DEPTH =1024)(
input [DATA_WIDTH-1:0]Next_Pc,
input [DATA_WIDTH-1:0]Imm_ext,
output logic [DATA_WIDTH-1:0]Pc_target);

assign Pc_target=(Next_Pc+Imm_ext);//since the Pc is already in the byte notion the imm_data will also assume each instruction is of 4 bytes so we can directly add the pc and later we will use the >>2 in instruction mem module to reach the next instruction 
endmodule