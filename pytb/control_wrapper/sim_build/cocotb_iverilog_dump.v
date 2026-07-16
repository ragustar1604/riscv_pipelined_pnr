module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/control_wrapper.fst");
    $dumpvars(0, control_wrapper);
end
endmodule
