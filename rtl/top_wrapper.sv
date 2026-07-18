module top_wrapper#(
parameter DATA_WIDTH =32,
parameter ADDR_WIDTH =32,
parameter CONTROL_BITS=3,
parameter number_of_elements=2000,
parameter total_num_reg=32,
parameter reg_add_size=5,
parameter DEPTH =1024)(
    input clk,
    input reset
);

//Fetch stage variables 
//PC
//branch condition is added below same sign extender will be increased for this introducing a new control signal


//logic Next_instruction_flag;
logic [DATA_WIDTH-1:0]Pc;
logic [DATA_WIDTH-1:0]Pc_plus_4;
 Program_counter dut(.*);
//Instruction memory 
logic  [ADDR_WIDTH-1:0] address_in_pc;
logic [DATA_WIDTH-1:0]instruction_out;
assign address_in_pc=Pc;
//logic  [DATA_WIDTH-1:0]current_pc_fetch_stage;
logic  [DATA_WIDTH-1:0]current_pc_decode;
always_ff @( posedge(clk) ) 
begin
    if(!reset)
    begin
        Pc<=0;
    end
    else
    begin
        if(StallF)
        Pc<=Pc;
        else
        begin
        if(Pc_src==1)
        begin
            Pc<=Pc_target;
        end
        else
        begin
            Pc<=Pc+4;  
        end
        end
    end
end
//change made for pipelining 
logic [DATA_WIDTH-1:0]instruction_out_reg;
always_ff @( posedge(clk))
begin
    if(!reset)
    begin
        instruction_out_reg<=32'b0;
        current_pc_decode<=0;
    end
    else
    begin
        if(StallD)
        begin
             instruction_out_reg<=instruction_out_reg;
            current_pc_decode<=current_pc_decode;//first register
        end
        else if(FlushD)
        begin
            instruction_out_reg<=32'b0;
            current_pc_decode<=0;
        end
        else
        begin
            instruction_out_reg<=instruction_out;
            current_pc_decode<=address_in_pc;//first register
        end
     
    end
end
//this will be the first register right after decode stage 
//Pc+4 needs to forwarded to execute stage only incase of jal instruction which is not implimented in thsi design so need not be forwaredd
instruction_memory dutt(.*);

//Decode stage 
//Register file related variables
logic [reg_add_size-1:0]read_reg1_address;
logic [reg_add_size-1:0]read_reg2_address;
logic [DATA_WIDTH-1:0]wd;
logic write_data_enable;
logic [reg_add_size-1:0]write_address;
logic  [DATA_WIDTH-1:0]rd1;
logic  [DATA_WIDTH-1:0]rd2;

//sign extender related variables
logic  [DATA_WIDTH-1:0]extended_data;
logic [1:0]imm_cntrl;
logic [24:0]immediate_data;
//changes made for pipeline _decode
logic  [DATA_WIDTH-1:0]rd1_reg;
logic  [DATA_WIDTH-1:0]rd2_reg;
//logic  [DATA_WIDTH-1:0]current_pc_decode_stage;
logic  [DATA_WIDTH-1:0]current_pc_exe;
logic Reg_write_e;
logic Result_src_e;
logic Memwrite_e;
logic Branch_e;
logic [2:0]alu_control_e;
logic ALUSrc_e;
logic invalid_instruction_e;
logic [reg_add_size-1:0]read_address_1_D;
logic [reg_add_size-1:0]read_address_2_D;
logic [reg_add_size-1:0]read_address_1_reg_e;
logic [reg_add_size-1:0]read_address_2_reg_e;
logic [reg_add_size-1:0]write_address_feedback;
logic [reg_add_size-1:0]write_address_e;
//logic [1:0]imm_cntrl_reg;
logic  [DATA_WIDTH-1:0]extended_data_reg;
always_ff@(posedge(clk))
begin
    if (!reset)
    begin
        rd1_reg<=0;
        rd2_reg<=0;
        current_pc_exe<=0;
        extended_data_reg<=0;
        Reg_write_e<=0;
        Result_src_e<=0;
        Memwrite_e<=0;
        Branch_e<=0;
        alu_control_e<=0;
        ALUSrc_e<=0;
        invalid_instruction_e<=0;
        read_address_1_reg_e<=0;
        read_address_2_reg_e<=0;
        write_address_e<=0;
    end
    else 
    begin
        if (FlushE)
        begin
            rd1_reg<=0;
            rd2_reg<=0;
            current_pc_exe<=0;
            extended_data_reg<=0;
            Reg_write_e<=0;
            Result_src_e<=0;
            Memwrite_e<=0;
            Branch_e<=0;
            alu_control_e<=0;
            ALUSrc_e<=0;
            invalid_instruction_e<=0;
            read_address_1_reg_e<=0;
            read_address_2_reg_e<=0;
            write_address_e<=0;
        end
        else
        begin
            rd1_reg<=rd1;
            rd2_reg<=rd2;
            current_pc_exe<=current_pc_decode;//second register
            extended_data_reg<=extended_data;
            Reg_write_e<=Reg_write;
            Result_src_e<=Result_src;
            Memwrite_e<=Memwrite;
            Branch_e<=Branch;
            alu_control_e<=alu_control;
            ALUSrc_e<=ALUSrc;
            invalid_instruction_e<=invalid_instruction;
            read_address_1_reg_e<=read_address_1_D;
            read_address_2_reg_e<=read_address_2_D;
            write_address_e<=instruction_out_reg[11:7];
        end
    end
end
//changes made for pipeline _decode
//assign immediate_data=instruction_out[31:7];
//assign read_reg1_address=instruction_out[19:15];;
assign immediate_data=instruction_out_reg[31:7];
assign read_reg1_address=instruction_out_reg[19:15];;
//for Hazard Management
assign read_address_1_D=instruction_out_reg[19:15];
assign read_address_2_D=instruction_out_reg[24:20];
//
Register_file dutttt(.*);
sign_extender duttt(.*);
//write back stage 
//ALU related variables 
logic [DATA_WIDTH-1:0]Data_1;
logic [DATA_WIDTH-1:0]Data_2;
logic [CONTROL_BITS-1:0]control_info;
logic [DATA_WIDTH-1:0]alu_result;
logic zero_value_flag ;
logic  [DATA_WIDTH-1:0]intermediate_data2 ;// this is added to handle data_hazard
alu ins(.*);
logic ALUSrc_for_mux;//related to the controller 
       //insterting a mux to select btw which data should enter the alu                                                        //alu data 1 and data 2 has been moved inside harazd unit description in the top wrapper for easier access and modification
assign Data_2=ALUSrc_for_mux==1?extended_data_reg:intermediate_data2;    //
                                                    //writing the address to the data memory
                                                                          //data memory related variables 
                                                                  // write_enable will be given by the control logic  i have deleted the write enable signal will see what to do with it 
logic write_enable;
logic [DATA_WIDTH-1:0]write_data;
logic [DATA_WIDTH-1:0]address;
logic[DATA_WIDTH-1:0]read_data; 
data_memory data_dut(.*);
assign address=alu_result_reg_1;

//write back to the register 
//write data is controlled by load and also an alu so amux is introduced 
logic Source_of_result;
assign wd=Source_of_result===1?read_data_reg:alu_result_reg_2;
//assign write_address=instruction_out[11:7];

assign write_address=write_address_feedback;
//end of this pc should be incremented by 4
//store instruction
assign read_reg2_address=instruction_out_reg[24:20];
//assign read_reg2_address=instruction_out[24:20];
//3rd register for memory write stage
logic [DATA_WIDTH-1:0]write_data_reg;
logic [DATA_WIDTH-1:0]alu_result_reg_1;
logic Reg_write_m;
logic Result_src_m;
logic Memwrite_m;
logic invalid_instruction_m;
logic [reg_add_size-1:0]write_address_m;
always_ff@(posedge(clk))
begin
if (!reset)
    begin
        write_data_reg<=0;
        alu_result_reg_1<=0;
        Reg_write_m<=0;
        Result_src_m<=0;
        Memwrite_m<=0;
        invalid_instruction_m<=0;
        write_address_m<=0;
    end
    else
    begin
        write_data_reg<=rd2_reg;
        alu_result_reg_1<=alu_result;
        Reg_write_m<=Reg_write_e;
        Result_src_m<=Result_src_e;
        Memwrite_m<=Memwrite_e;
        invalid_instruction_m<=invalid_instruction_e;
        write_address_m<=write_address_e;

    end
end

//3rd register for memory write stage
//write enable should be given by the controller module 
assign write_data=write_data_reg;
//end of this pc should be incremented by 4
//R type instruction 
//only control signal will change for these operations 
logic[DATA_WIDTH-1:0]Imm_ext;
logic [DATA_WIDTH-1:0]Pc_target;
logic [DATA_WIDTH-1:0]Next_Pc;
//4th register for write back stage 
logic[DATA_WIDTH-1:0]read_data_reg; 
logic [DATA_WIDTH-1:0]alu_result_reg_2;
logic Reg_write_w;
logic Result_src_w;
logic invalid_instruction_w;
logic [reg_add_size-1:0]write_address_w;
always_ff@(posedge(clk))
begin
    if(!reset)
    begin
        alu_result_reg_2<=0;
        read_data_reg<=0;
        Reg_write_w<=0;
        Result_src_w<=0;
        invalid_instruction_w<=0;
        write_address_w<=0;
    end
    else
    begin
         alu_result_reg_2<=alu_result_reg_1;
        read_data_reg<=read_data;  
        Reg_write_w<= Reg_write_m;
        Result_src_w<=Result_src_m;
        invalid_instruction_w<=invalid_instruction_m;
        write_address_w<=write_address_m;

    end
end
assign write_address_feedback=write_address_w;
//4th register for write back stage 
branch_alu dutttrt(.*);
assign Imm_ext=extended_data_reg;
assign Next_Pc=current_pc_exe;
//control unit 
logic [DATA_WIDTH-1:0]instruction;
logic [2:0]func3;
logic func7;
//output logic op_5,
logic invalid_instruction_cntrl;
logic Result_src;
logic Memwrite;
logic ALUSrc;
logic [1:0]imm_src;
logic Reg_write;
logic Branch;
logic [2:0]alu_control;
logic invalid_instruction;
//
assign instruction=instruction_out_reg;
logic Pc_src;
control_wrapper durtet(.*);
//control transfer section
//PC requires a mux setup using branch condition and zero flag from alu
//ALU
assign control_info=alu_control_e;
//Register_file
assign Source_of_result=Result_src_w;
assign write_data_enable=Reg_write_w;
assign  ALUSrc_for_mux=ALUSrc_e;
assign imm_cntrl=imm_src;
assign write_enable=Memwrite_m;
assign Pc_src=zero_value_flag&Branch_e;
///HAZARD UNIT 
logic RegWrite_status_from_wb;
logic RegWrite_status_from_mem;
logic [reg_add_size-1:0]Rs1E;
logic [reg_add_size-1:0]Rs2E;
logic [reg_add_size-1:0]write_address_mem;
logic [reg_add_size-1:0]write_address_write;   
logic [1:0]ForwardAE;
logic [1:0]ForwardBE;

assign Rs1E=read_address_1_reg_e;
assign Rs2E=read_address_2_reg_e;
assign RegWrite_status_from_wb=Reg_write_w;
assign RegWrite_status_from_mem=Reg_write_m;
assign write_address_write=write_address_w;
assign write_address_mem=write_address_m;

assign Data_1=(ForwardAE==2'b10)?alu_result_reg_1:(ForwardAE==2'b01)?wd:rd1_reg;

assign intermediate_data2=(ForwardBE==2'b10)?alu_result_reg_1:(ForwardBE==2'b01)?wd:rd2_reg;
Hazard_Unit dexter(.*);
//load Hazard
logic [reg_add_size-1:0]Rs1D;
logic [reg_add_size-1:0]Rs2D;
logic Result_src_from_exe;
logic [reg_add_size-1:0]write_address_exe;
logic lwStall;
logic StallF;
logic StallD;
logic FlushE;
logic FlushD;
logic Pc_src_E;


assign write_address_exe=write_address_e;
assign Result_src_from_exe=Result_src_e;
assign Rs1D=read_address_1_D;
assign Rs2D=read_address_2_D;
assign Pc_src_E=Pc_src;
///HAZARD UNIT 

// TEMPORARY DEBUGGING BLOCK - Remove after finding the loop
initial begin
    #1; 
end

always @(*) begin
    $display("[TIME 0 LOOP DETECTED] PC: %h | Next_PC: %h | PC_Src: %b | Instruction: %h", 
             Pc, Next_Pc, Pc_src, instruction_out_reg);
end

endmodule


/////////////////////////////////////////////////////

