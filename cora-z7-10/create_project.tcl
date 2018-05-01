# This script sets project and board specific settings, so that the generic create_project does not need to be modified
set proj_name "PmodI2S2"
set brd_part "digilentinc.com:cora-z7-10:1.0"

# Call into standard create_project script
source ../scripts/create_project.tcl

# Set top-level verilog parameters
set_property generic {RESET_POLARITY=1 NUMBER_OF_SWITCHES=1} [current_fileset]

# Make modifications to the project for the chosen board
# Modify clk_wiz_0 IP for appropriate input clock frequency
report_ip_status -name ip_status 
upgrade_ip -vlnv xilinx.com:ip:clk_wiz:5.4 [get_ips clk_wiz_0]
export_ip_user_files -of_objects [get_ips clk_wiz_0] -no_script -sync -force -quiet
set_property CONFIG.PRIM_IN_FREQ {125.000} [get_ips clk_wiz_0]
