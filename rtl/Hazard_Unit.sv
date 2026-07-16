module Hazard_Unit#(parameter DATA_WIDTH=32,
                    parameter reg_add_size=5)(
input RegWrite_status_from_wb,
input RegWrite_status_from_mem,
input [reg_add_size-1:0]Rs1E,
input [reg_add_size-1:0]Rs2E,
input [reg_add_size-1:0]write_address_mem,
input [reg_add_size-1:0]write_address_write,


input [reg_add_size-1:0]Rs1D,
input [reg_add_size-1:0]Rs2D,
input Result_src_from_exe,
input  [reg_add_size-1:0]write_address_exe,
input Pc_src_E,


output logic [1:0]ForwardAE,
output logic [1:0]ForwardBE,

output  lwStall,
output logic StallF,
output logic StallD,
output logic FlushE,
output logic FlushD
);

always_comb
begin
    if(((Rs1E==write_address_mem)&&(RegWrite_status_from_mem))&&(Rs1E!=0))
    begin
    ForwardAE=2'b10;
    end
    else if(((Rs1E==write_address_write)&&(RegWrite_status_from_wb))&&(Rs1E!=0))
    begin
    ForwardAE=2'b01;    
    end
    else
    begin
    ForwardAE=2'b00;    
    end
 
end
always_comb
begin
    if(((Rs2E==write_address_mem)&&(RegWrite_status_from_mem))&&(Rs2E!=0))
    begin
    ForwardBE=2'b10;
    end
    else if(((Rs2E==write_address_write)&&(RegWrite_status_from_wb))&&(Rs2E!=0))
    begin
    ForwardBE=2'b01;    
    end
    else
    begin
    ForwardBE=2'b00;    
    end
 
end

assign lwStall=(Result_src_from_exe&&((Rs1D==write_address_exe)||(Rs2D==write_address_exe)));
assign StallF=lwStall;
assign StallD=lwStall;
assign FlushE=lwStall||Pc_src_E;
assign FlushD=Pc_src_E;
endmodule