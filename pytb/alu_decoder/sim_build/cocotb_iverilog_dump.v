module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/alu_decoder.fst");
    $dumpvars(0, alu_decoder);
end
endmodule
