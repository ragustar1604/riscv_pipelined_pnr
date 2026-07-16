module alu#(
parameter DATA_WIDTH =32,CONTROL_BITS=3)(
input [DATA_WIDTH-1:0]Data_1,
input [DATA_WIDTH-1:0]Data_2,
input [CONTROL_BITS-1:0]control_info,
output logic [DATA_WIDTH-1:0]alu_result,
output logic zero_value_flag );
//zero flag might become a latch should try to drive  it in all the the signals
always_comb begin : load_address_calculation
    if(control_info==3'b000)
    begin
        //addition 
        alu_result=Data_1+Data_2;
        zero_value_flag=0;
    end
    else if(control_info==3'b001)
    begin
        //subtraction
        alu_result=Data_1-Data_2;
       zero_value_flag= alu_result==0?1:0;

    end
    else
    begin
        zero_value_flag=0;
    if(control_info==3'b010)
    begin
        //and gate bit wise 
         alu_result=Data_1&Data_2;
    end
     else if(control_info==3'b011)
    begin
        //or gate bitwise
         alu_result=Data_1|Data_2;
    end
    else if(control_info==3'b101)
    begin
        if (Data_1>Data_2)
        begin
        alu_result=1;
        end
        else
        alu_result=0;
    end
    else 
    begin
         alu_result=32'hDEADBEEF;
    end
    end

    
end
endmodule