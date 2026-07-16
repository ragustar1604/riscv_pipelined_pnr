module alu_decoder(
    input [2:0]func3,
    input [1:0]ALU_operation,
    input func7,
    input op_5,
    output logic [2:0]alu_control,
    output logic invalid_instruction);
     logic [1:0]net_func;
    assign net_func={op_5,func7};
   always_comb
   begin
    case(ALU_operation)
    2'b00:
    begin
          invalid_instruction=0;
        alu_control=000;
    end
    2'b01:
    begin
         invalid_instruction=0;
          alu_control=001;
    end
    2'b10:
    begin
         invalid_instruction=0;
        case(func3)
        3'b000:
        begin
            if(net_func==2'b11)
            begin
                    alu_control=001;
            end
            else
            begin
                    alu_control=000;
            end
        end
         3'b010:
                    alu_control=101;
         3'b110:
                    alu_control=011;
         3'b111:
                    alu_control=010;
        default: alu_control = 3'b000;
        endcase

    end
   2'b11:
    begin
    invalid_instruction=1;
    alu_control=3'b111;
    end
    endcase
   end
endmodule 