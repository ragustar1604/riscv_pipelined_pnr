/*
this will act as the main memory 
takes the pc value gives the coresspoding instruction out 
this is a isntant no latency read ideally will not be the case 
this along with Program_counter will be the fetch stage of the pipeline

*/

module instruction_memory #(
parameter DATA_WIDTH =32,
parameter ADDR_WIDTH =32,
parameter number_of_elements=2000)
(input [ADDR_WIDTH-1:0] address_in_pc,
output logic [DATA_WIDTH-1:0]instruction_out);
// synthesis translate_off
initial begin
    $readmemh("sample_instruction.mem", address_space);
end
// synthesis translate_on

logic [DATA_WIDTH-1:0]address_space[0:number_of_elements-1];

assign instruction_out=address_space[address_in_pc>>2];

endmodule
