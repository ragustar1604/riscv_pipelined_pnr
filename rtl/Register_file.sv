/*
optimisatiion can add consturcts to reinitialise the registers only during simulation instead of assigning them zeros
*/
module Register_file #(parameter DATA_WIDTH=32,
parameter total_num_reg=32,
parameter reg_add_size=5)
(
input clk,
input reset,
input [reg_add_size-1:0]read_reg1_address,
input [reg_add_size-1:0]read_reg2_address,
input [DATA_WIDTH-1:0]wd,
input write_data_enable,
input [reg_add_size-1:0]write_address,
output logic [DATA_WIDTH-1:0]rd1,
output logic [DATA_WIDTH-1:0]rd2
);
logic [31:0]register_file[0:DATA_WIDTH-1];

// synthesis translate_off
initial begin
    $readmemh("register_file_initialisation.mem", register_file);//this is done to avoid x in simuation im storing some data in the 32 registrs 
end
// synthesis translate_on

always_ff @(posedge(clk))
begin
if(!reset)
begin

end
else
begin
if(write_data_enable &&(write_address!=32'b0))
begin
register_file[write_address]<=wd;
end

end
end
//making this change to accomodate wb of some instruction and id of some instruction being the same cycle so read happens after the write 
assign rd1 = (read_reg1_address == 0) ? 32'b0 :
             (write_data_enable && (write_address == read_reg1_address)) ? wd :
             register_file[read_reg1_address];

assign rd2 = (read_reg1_address == 0) ? 32'b0 :
             (write_data_enable && (write_address == read_reg2_address)) ? wd :
             register_file[read_reg2_address];

//assign  rd1 =register_file[read_reg1_address];
//assign  rd2 =register_file[read_reg2_address];
endmodule