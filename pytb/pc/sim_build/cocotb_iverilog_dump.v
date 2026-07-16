module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/Program_counter.fst");
    $dumpvars(0, Program_counter);
end
endmodule
