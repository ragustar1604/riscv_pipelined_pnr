module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/Register_file.fst");
    $dumpvars(0, Register_file);
end
endmodule
