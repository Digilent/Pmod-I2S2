# This script sets project and board specific settings, so that the generic create_project does not need to be modified
set proj_name "Pmod-I2S2-Cora-Z7-07S"
set brd_part "digilentinc.com:cora-z7-07s:1.0"

# Call into standard create_project script
set ::create_path [file dirname [info script]]/proj
source [file normalize [file dirname [info script]]/../scripts/create_project.tcl]
current_project $proj_name

# Set top-level verilog parameters
set_property generic {RESET_POLARITY=1 NUMBER_OF_SWITCHES=1} [current_fileset]

# Modify clk_wiz_0 IP for appropriate input clock frequency
set_property CONFIG.PRIM_IN_FREQ {125.000} [get_ips clk_wiz_0]
