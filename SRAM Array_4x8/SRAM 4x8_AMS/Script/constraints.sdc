# ==============================================
# Simple Timing Constraints for SRAM Tile
# ==============================================

# Clock definition
create_clock -name clk -period 10 [get_ports clk]
set_clock_uncertainty -setup 0.1 [get_clocks clk]

# Input delays
set_input_delay -clock clk -max 2.0 [get_ports {we re addr[*] din[*]}]
set_input_delay -clock clk -min 0.5 [get_ports {we re addr[*] din[*]}]

set_input_delay -clock clk -max 1.0 [get_ports rst]
set_input_delay -clock clk -min 0.2 [get_ports rst]

# Output delays
set_output_delay -clock clk -max 2.0 [get_ports dout[*]]
set_output_delay -clock clk -min 0.5 [get_ports dout[*]]

# Load capacitance
set_load 0.05 [all_outputs]

# Maximum transition
set_max_transition 0.5 [current_design]
