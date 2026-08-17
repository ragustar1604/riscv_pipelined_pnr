# 1. Load the OpenROAD reference tech layers
read_lef /home/ragur/OpenROAD/test/sky130hd/sky130hd.tlef

# 2. Append the standard cell layout macros
read_lef /home/ragur/OpenROAD/test/sky130hd/sky130_fd_sc_hd.lef

# 3. Load the liberty timing cell rules
read_liberty /home/ragur/sky130/sky130_fd_sc_hd__tt_025C_1v80.lib

# 4. Ingest your gate-level netlist (With the 54,900 live cells!)
read_verilog ../rtl/synth_netlist_area_opt.v

# 5. Build and link the complete database
link_design top_wrapper

# 6. Load timing constraints
read_sdc constraints.sdc
# =================== OPTIMIZATION INSERTION ===================
# Prevent the tool from using low-power isolation cells for speed paths
set_dont_use {sky130_fd_sc_hd__lpflow_*}
# 2. NEW: Provide a default routing metal layer for pre-layout RC wire estimations
set_wire_rc -layer met3
# Insert buffer trees and upsize gates to fix massive fanout delays
repair_design
# ==============================================================
# 3. NEW: Sniper tool to fix the remaining -1.71 ns setup violation
repair_timing -setup
# ============================================================
# =================== CORRECTED DIAGNOSTICS ===================

puts "\n>>> DIAGNOSTIC: ACTIVE TIMING CLOCKS <<<"
report_clock_properties

puts "\n>>> DIAGNOSTIC: NETLIST PORT COUNT <<<"
puts "Total top-level ports found: [llength [get_ports *]]"

puts "\n>>> DIAGNOSTIC: LINKED CELL INSTANCES <<<"
puts "Total gate instances linked: [llength [get_cells *]]"

# =================== TIMING REPORT ===================

puts "\n>>> CRITICAL PATH TIMING REPORT <<<"
# report_checks -path_delay max -format full
# =================== TIMING DIAGNOSTICS ===================
puts "\n>>> WRITING TIMING REPORT TO FILE <<<"
tee -file worst_slack.rpt {report_worst_slack -max}

# This line handles both displaying and saving the report
tee -file timing_report.rpt { report_checks -path_delay max -format full }

tee -file timing_report_top10.rpt {
    report_checks -path_delay max -endpoint_count 10 -group_count 10 -format full
}
exit