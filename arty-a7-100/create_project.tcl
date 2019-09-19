# This script sets project and board specific settings, so that the generic create_project does not need to be modified
set proj_name "PmodI2S2"
set brd_part "digilentinc.com:arty-a7-100:1.0"

# Call into standard create_project script
set ::create_path [file dirname [info script]]/proj
if {[file exists $::create_path] == 0} {
	file mkdir $::create_path
}
source [file normalize [file dirname [info script]]/../scripts/create_project.tcl]

# Set top-level verilog parameters
set_property generic {NUMBER_OF_SWITCHES=4 RESET_POLARITY=0} [current_fileset]

# Make modifications to the project for the chosen board
# Modify clk_wiz_0 IP for appropriate input clock frequency
set old_vlnv [expr {[get_property VLNV [get_ipdefs -filter VLNV=~*:clk_wiz:*]] != [get_property IPDEF [get_ips clk_wiz_0]]}]
set wrong_board [expr {$brd_part != [get_property BOARD [get_ips clk_wiz_0]]}]
if {$old_vlnv || $wrong_board} {
	report_ip_status -name ip_status 
	upgrade_ip -vlnv [get_ipdefs -filter VLNV=~*:clk_wiz:*] [get_ips clk_wiz_0]
	export_ip_user_files -of_objects [get_ips clk_wiz_0] -no_script -sync -force -quiet
}

set_property CONFIG.PRIM_IN_FREQ {100.000} [get_ips clk_wiz_0]
