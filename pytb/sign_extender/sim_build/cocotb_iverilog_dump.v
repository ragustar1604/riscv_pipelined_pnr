module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/sign_extender.fst");
    $dumpvars(0, sign_extender);
end
endmodule
