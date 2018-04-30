To open a Vivado project after cloning this repo:
	1.  Open Vivado, in TCL console, CD into the folder of the target board (ex: arty-a7-35).
	2.  Call "source ./create_project.tcl". This will set appropriate parameters,
		then source ../scripts/create_project.tcl, then make any other necessary modifications to the project.