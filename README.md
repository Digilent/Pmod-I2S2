This project is a demonstration of the Pmod I2S2. It creates a pass-through from Line-In to the Line-Out jack. The audio data coming through this passthrough is scaled by the number of switches on the FPGA that are closed. All switches open means that the data stream will be muted. All switches closed means that the data stream will be at full volume. The audio volume scales linearly between these two points.

In order to use this demo, a [Pmod I2S2](reference.digilentinc.com/reference/pmod/pmod-i2s2/start) and one of the Digilent FPGA development boards presented in the table below are required. In addition, headphones or speakers and an audio input source (such as a personal computer) are also required.

WARNING!!! This project is only supported in the 2017.4 version of Vivado.

The table below describes how inputs and outputs to this demo are connected, depending on the development board used:

| Board       | I2S2 Pmod Connector | Volume Input | Reset        |
| ----------- | ------------------- | ------------ | ------------ |
| [Arty A7-35](https://reference.digilentinc.com/reference/programmable-logic/arty/start)  | JA                  | SW3-SW0      | RESET Button |
| [Arty A7-100](https://reference.digilentinc.com/reference/programmable-logic/arty/start) | JA                  | SW3-SW0      | RESET Button |
| [Arty S7-25](https://reference.digilentinc.com/reference/programmable-logic/arty-s7/start)  | JA                  | SW3-SW0      | RESET Button |
| [Arty S7-50](https://reference.digilentinc.com/reference/programmable-logic/arty-s7/start)  | JA                  | SW3-SW0      | RESET Button |
| [Cora Z7-07S](https://reference.digilentinc.com/reference/programmable-logic/cora-z7/start) | JA                  | BTN0         | BTN1         |
| [Cora Z7-10](https://reference.digilentinc.com/reference/programmable-logic/cora-z7/start)  | JA                  | BTN0         | BTN1         |
| [Cmod S7-25](https://reference.digilentinc.com/reference/programmable-logic/cmod-s7/start)  | JA                  | BTN0         | BTN1         |

This project is formatted a little differently than the standard Digilent Github project.

In order to program the project onto an FPGA:

1. 	Download the latest release ZIP (not the source ZIP) for the target FPGA board from the repo's [releases page](https://github.com/artvvb/Pmod-I2S2/releases).

2. 	Extract and open the downloaded ZIP. Double click on "I2S2.xpr". This will launch an archived version of the project, in which a bitstream has already been generated.

3. 	Open the Vivado Hardware Manager, select "Open Target", and find the target board.

4.  Program top.bit onto the target.
	
In order to open a Vivado project after cloning this repo:

1.  Open Vivado, in the TCL console at the bottom of the window, CD into the folder of the target board (ex: arty-a7-35).

2.  Call "source ./create_project.tcl". This will set appropriate parameters, then source ../scripts/create_project.tcl, then make any other necessary modifications to the project.
