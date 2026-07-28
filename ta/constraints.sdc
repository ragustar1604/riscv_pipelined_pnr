# 1. Define a Virtual Clock (used to model external board propagation delays)
create_clock -name clk_v -period 10.0

# 2. Define the primary physical hardware clock port
create_clock -name clk -period 10.0 [get_ports clk]

# 3. Model clock uncertainty 
set_clock_uncertainty 0.25 [get_clocks clk]

# 4. Model IO constraints cleanly relative to the virtual reference clock
set_input_delay -clock clk_v 2.0 [all_inputs]
set_output_delay -clock clk_v 2.0 [all_outputs]