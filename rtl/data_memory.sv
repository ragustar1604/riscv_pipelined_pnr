module data_memory#(parameter DATA_WIDTH =32,
parameter DEPTH =2)
(
input clk,
input reset,
input write_enable,
input [DATA_WIDTH-1:0]write_data,
input [DATA_WIDTH-1:0]address,
output logic[DATA_WIDTH-1:0]read_data );
logic [DATA_WIDTH-1:0]data_register[DEPTH-1:0];
logic [11:0]i;

// synthesis translate_off
initial begin
    $readmemh("data_mem_initialisation.mem", data_register);//this is done to avoid x in simuation im storing some data in the 32 registrs 
end
// synthesis translate_on


always_ff@(posedge(clk))
// this is a 32-bit value, but we omit the leading zeros to avoid cluttering the figure.
begin
if(!reset)
begin
       //read_data<=0;
end
else
begin
    if (write_enable==1)
    begin
        data_register[address]<=write_data;
        //read_data<=0;
    end
end
end
assign  read_data= data_register[address[9:0]];//since depth is 1024 i dont want to have any overflow here
endmodule