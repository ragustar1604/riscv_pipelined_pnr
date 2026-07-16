/*
this module is expected to take in the 32 bit instruction from the memory and 
The single-cycle processor’s control unit computes the control signals 
based on op, funct3, and funct7. 
*/
module control_decoder #(parameter DATA_WIDTH = 32)(
    input [6:0]op_code,
   // input clk,
 //   input reset,
    output logic invalid_instruction_cntrl,
    output logic Result_src,
    output logic Memwrite,
    output logic ALUSrc,
    output logic [1:0]imm_src,
    output logic Reg_write,
    output logic Branch,
    output logic [1:0]ALU_operation);
    

    //assign op_code=instruction[6:0];
   
    always_comb
    begin
              
        if(op_code==7'b0000011)
        begin
            invalid_instruction_cntrl=0;
            Reg_write=1;
            imm_src=2'b00;
            ALUSrc=1;
            Memwrite=0;
            Result_src=1;
            Branch=0;
            ALU_operation=2'b00;
        end
        else if(op_code==7'b0100011)
        begin
            invalid_instruction_cntrl=0;
            Reg_write=0;
            imm_src=2'b01;
            ALUSrc=1;
            Memwrite=1;
            Result_src=1;//Result_src doesnt matter wat value it has im assigning value only to avoid a latch 
            Branch=0;
            ALU_operation=2'b00;

        end
        else if(op_code==7'b0110011)
        begin
            invalid_instruction_cntrl=0;
            Reg_write=1;
            imm_src=2'b00;//doesnt matter wat value it has im assigning value only to avoid a latch
            ALUSrc=0;
            Memwrite=0;
            Result_src=0;
            Branch=0;
            ALU_operation=2'b10;
        end
        else if(op_code==7'b1100011)
        begin
            invalid_instruction_cntrl=0;
            Reg_write=0;
            imm_src=2'b10;
            ALUSrc=0;
            Memwrite=0;
            Result_src=1;//doesnt matter wat value it has im assigning value only to avoid a latch 
            Branch=1;
            ALU_operation=2'b01;

        end
        else
        begin
            invalid_instruction_cntrl=1;
            Reg_write=0;
            imm_src=2'b00;
            ALUSrc=0;
            Memwrite=0;
            Result_src=0;//doesnt matter wat value it has im assigning value only to avoid a latch 
            Branch=0;
            ALU_operation=2'b00;
        end
    end

    endmodule