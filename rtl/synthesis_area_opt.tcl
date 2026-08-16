# 1. Ingest SystemVerilog source files
read_verilog -sv *.sv

# 2. Synthesize hierarchy keeping submodules separate to prevent pruning
synth -top top_wrapper -nordff

# 3. Map architectural flip-flops to Sky130 standard cells
dfflibmap -liberty /home/ragur/sky130/sky130_fd_sc_hd__tt_025C_1v80.lib

# =================== AUTOMATED AREA MAPPING ===================
# 4. Standard area-driven mapping pass. Without the custom delay script,
# ABC will naturally group logic into physical full-adders to shrink the chip size.
abc -liberty /home/ragur/sky130/sky130_fd_sc_hd__tt_025C_1v80.lib -dont_use sky130_fd_sc_hd__lpflow_isobufsrc_1
# ==============================================================

# 5. Dissolve module walls now that all gates are safely locked in place
flatten

# 6. Purge dead design artifacts left behind by flattening
clean -purge

# 7. Generate and save the comprehensive gate statistics file
tee -o synthesis_report_area_opt.txt stat -liberty /home/ragur/sky130/sky130_fd_sc_hd__tt_025C_1v80.lib

# 8. Write the clean, flat structural netlist for OpenROAD
write_verilog synth_netlist.v