module Program_counter#(parameter DATA_WIDTH=32)(
input clk,
input reset,
input Pc_src,
output logic [DATA_WIDTH-1:0]Pc_plus_4);

//logic Next_instruction_flag_internal;
logic [DATA_WIDTH-1:0] internalpc;
//assign Next_instruction_flag_internal=Next_instruction_flag;
assign Pc_plus_4=internalpc;
always_ff @( posedge(clk) ) 
begin
if(!reset)
    begin
        internalpc<=0;
    end
    else
    begin
        internalpc<=internalpc+4;
    end
end

endmodule