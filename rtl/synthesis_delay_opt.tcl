#this is Optimised for lowest possible delay so the number of cell count and area would definitely be higher we can do  synthesis for area and see whats the difference but this will optimise for speed 
#The full adder std cell hasnt been used in the design because it is not fast enoght so gate level minimisation is done int he abc -{d}and then flatten is done 
#
# 1. Ingest SystemVerilog source files
read_verilog -sv *.sv

# 2. Synthesize and eloborate the sv code 

synth -top top_wrapper -nordff
# so basically top_wrapper is the boundary into which all other modules exists something like a russion doll or tanjavur doll so the outermost doll is this top wrapper 
#this is the step in which elabortion{design to graph }, constant folding {parameters to actual hard coded buses}   and dead code elimination
#-nordff this is used to not use a complex optimised type of dff were it looks at the code and uses ff like Synchronous Reset DFF with Clock Enable), $dffsr (Set-Reset DFF), or $aldff (Asynchronous Load DFF).
# #using nordff would make sure the norrmal reset ff is being used in the design which will be a std cell in most of the library using complex ff might also
# lead to std cells that do not exist in the library 


# 3. Map architectural flip-flops to Sky130 standard cells
dfflibmap -liberty /home/ragur/sky130/sky130_fd_sc_hd__tt_025C_1v80.lib
# sequencial cells are mapped to standard cells thisi is done before comb cells because this would make sure there are no cyclic graphs in the design since the algo loosk for DAGS in the next stage 
# # also protects the clk , reset pins while optimising comb cells 


# 4. Run aggressive delay-driven mapping and ban the low-power bottleneck cell
abc -liberty /home/ragur/sky130/sky130_fd_sc_hd__tt_025C_1v80.lib -dont_use sky130_fd_sc_hd__lpflow_isobufsrc_1 -script "+strash;scorr;ifraig;retime;{D};map;"
# -liberty  abc is the DAG algo and we are giving the targeted lib here 
# -dont_use- since My goal here was to make sure latency is as low as possible im avoilding a low power buffer cell 
# strash- intermediate expression is ina and inversion form basically this would further help the optimisation down the road because the sat solvers, treebalancing all run faster in presence of one type of node 
#scorr node reduction technique basically if during working condition y is always equal to x why have 2 nodes use a singe node 
# ifraig is also related to the scorr
# #retime- retiming of the graph to optimise the delay 
# map final mapping to the standard calls

# =================== CORRECTED LATE-FLATTEN STEP ===================
# Dissolve module walls now that all gates are safely locked in place
flatten
#basically function inlining were everything is put together instead of indidual modules 
# ===================================================================
# 5. Purge dead design cells 
clean -purge
tee -o synthesis_report_delay_opt.txt stat -liberty /home/ragur/sky130/sky130_fd_sc_hd__tt_025C_1v80.lib
write_verilog synth_netlist_delay_opt.v