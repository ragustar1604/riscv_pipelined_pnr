module sign_extender(
    input [24:0]immediate_data,
    input logic [1:0]imm_cntrl,
    output logic [31:0]extended_data);
    logic sign_bit;
  
   //can be always_comb but iverilog doesnt suport it properly so maybe i will have to try this with verilator 15/6/26
    always@(*)
    begin
        if (imm_cntrl==0)
        begin
            //load operation 
            sign_bit=immediate_data[24];
            extended_data = {{20{sign_bit}}, immediate_data[24:13]};
        end
        else if(imm_cntrl==1)
        begin
            // store operation
            sign_bit=immediate_data[24];
            extended_data={{20{sign_bit}}, immediate_data[24:18],immediate_data[4:0]};
        end
        else
        begin
        sign_bit=immediate_data[24];
        extended_data={{20{sign_bit}},immediate_data[0], immediate_data[23:18],immediate_data[4:1],1'b0};
        end
    end
endmodule
/*
// Instr31:25,11:7.
7+5=12;

*/