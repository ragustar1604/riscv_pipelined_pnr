# 1. Ingest SystemVerilog source files
read_verilog -sv *.sv

# 2. Synthesize and flatten the design hierarchy to open up cross-module optimization
synth -top top_wrapper -nordff

# 3. Map architectural flip-flops to Sky130 standard cells
dfflibmap -liberty /home/ragur/sky130/sky130_fd_sc_hd__tt_025C_1v80.lib

# 4. Run aggressive delay-driven mapping and ban the low-power bottleneck cell
abc -liberty  /home/ragur/sky130/sky130_fd_sc_hd__tt_025C_1v80.lib -dont_use sky130_fd_sc_hd__lpflow_isobufsrc_1 -script +strash;scorr;ifraig;retime;{D};abc;-g;vbt;

# 5. Purge dead design artifacts and dump the clean netlist
clean -purge
tee -o synthesis_report.txt stat -liberty /home/ragur/sky130/sky130_fd_sc_hd__tt_025C_1v80.lib
write_verilog synth_netlist.v