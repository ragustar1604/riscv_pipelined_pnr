module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/top_wrapper.fst");
    $dumpvars(0, top_wrapper);
end
endmodule
