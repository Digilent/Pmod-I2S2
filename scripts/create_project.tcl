# Run this script to create the Vivado project files in the ../proj directory relative to this script
# If ::create_path global variable is set, the project is created under that path instead of the working dir

# This version of this script expects that brd_part has previously been set.
# This does not currently handle IPI flow.

if {[file exists $::create_path] == 0} {
	file mkdir $::create_path
}
set dest_dir $::create_path

puts "INFO: Creating new project in $dest_dir"
cd $dest_dir

# Extract the board's board_name (simplified name) and part0 (FPGA) part number from the board file
set board_obj [get_boards -filter "NAME == $brd_part"]
set board_name [get_property board_name $board_obj]
set part [get_property part_name [get_board_components -of_objects $board_obj -filter "NAME =~ *part0*"]]

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir [file dirname [info script]]/..
set repo_dir $origin_dir/repo

# # Set the board repo
# # Uncomment if distributing board files with project in the "repo/board_files" folder.
# # This is currently untested. It intends to also keep any existing board repo paths, since this is a global Vivado setting (not project specific.
# # Ideally, if the project is closed, and then a new project is created (without closing Vivado), this should still be able to see a board repo specified in init.tcl.
#set_param board.repoPaths "[file normalize "$repo_dir/board_files"]"

# Create project
create_project $proj_name $dest_dir

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects $proj_name]
set_property "default_lib" "xil_defaultlib" $obj
set_property "part" $part $obj
set_property "board_part" $brd_part $obj
set_property "simulator_language" "Mixed" $obj
set_property "target_language" "VHDL" $obj

# Uncomment the following 3 lines to greatly increase build speed while working with IP cores (and/or block diagrams)
set_property "corecontainer.enable" "0" $obj
set_property "ip_cache_permissions" "read write" $obj
set_property "ip_output_repo" "[file normalize "$repo_dir/cache"]" $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" "[file normalize $repo_dir]" $obj

# Refresh IP Repositories
update_ip_catalog -rebuild

# Gather sources from shared and board-specific directories
foreach src_dir [list $origin_dir/shared/src $origin_dir/$board_name/src] {
	# Add conventional sources
	import_files -quiet $src_dir/hdl

	# Add IPs
	# TODO: handle IP containers files
	import_files -quiet [glob -nocomplain $src_dir/ip/*/*.xci]

	# Add constraints
	import_files -fileset constrs_1 -quiet $src_dir/constraints
}

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
	create_run -name synth_1 -part $part -flow {Vivado Synthesis 2017} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
	set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
	set_property flow "Vivado Synthesis 2017" [get_runs synth_1]
}
set obj [get_runs synth_1]
set_property "part" $part $obj
set_property "steps.synth_design.args.flatten_hierarchy" "none" $obj
set_property "steps.synth_design.args.directive" "RuntimeOptimized" $obj
set_property "steps.synth_design.args.fsm_extraction" "off" $obj

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part $part -flow {Vivado Implementation 2017} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2017" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property "part" $part $obj
set_property "steps.opt_design.args.directive" "RuntimeOptimized" $obj
set_property "steps.place_design.args.directive" "RuntimeOptimized" $obj
set_property "steps.route_design.args.directive" "RuntimeOptimized" $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

# Update the clk_wiz_0 IP for the current version and board
set old_vlnv [expr {[get_property VLNV [get_ipdefs -filter VLNV=~*:clk_wiz:*]] != [get_property IPDEF [get_ips clk_wiz_0]]}]
set wrong_board [expr {$brd_part != [get_property BOARD [get_ips clk_wiz_0]]}]
if {$old_vlnv || $wrong_board} {
	report_ip_status -name ip_status 
	upgrade_ip -vlnv [get_ipdefs -filter VLNV=~*:clk_wiz:*] [get_ips clk_wiz_0]
	export_ip_user_files -of_objects [get_ips clk_wiz_0] -no_script -sync -force -quiet
}

puts "INFO: Project created:$proj_name"
