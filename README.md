This project is a demonstration of the Pmod I2S2. It creates a pass-through from Line-In to the Line-Out jack. The audio data coming through this passthrough is scaled by the number of switches on the FPGA that are closed. All switches open means that the data stream will be muted. All switches closed means that the data stream will be at full volume. The audio volume scales linearly between these two points.

In order to use this demo, a [Pmod I2S2](reference.digilentinc.com/reference/pmod/pmod-i2s2/start) and one of the Digilent FPGA development boards presented in the table below are required. In addition, headphones or speakers and an audio input source (such as a personal computer) are also required. 

This project is supported in versions of Vivado >= 2017.4. Releases are currently provided only for 2017.4 and 2018.2.

The table below describes how inputs and outputs to this demo are connected, depending on the development board used:

| Board (Resource Center Link) | I2S2 Pmod Connector | Volume Input | Reset        |
| ---------------------------- | ------------------- | ------------ | ------------ |
| [Arty A7-35](https://reference.digilentinc.com/reference/programmable-logic/arty/start)     | JA                  | SW3-SW0      | RESET Button |
| [Arty A7-100](https://reference.digilentinc.com/reference/programmable-logic/arty/start)    | JA                  | SW3-SW0      | RESET Button |
| [Arty S7-25](https://reference.digilentinc.com/reference/programmable-logic/arty-s7/start)  | JA                  | SW3-SW0      | RESET Button |
| [Arty S7-50](https://reference.digilentinc.com/reference/programmable-logic/arty-s7/start)  | JA                  | SW3-SW0      | RESET Button |
| [Cora Z7-07S](https://reference.digilentinc.com/reference/programmable-logic/cora-z7/start) | JA                  | BTN0         | BTN1         |
| [Cora Z7-10](https://reference.digilentinc.com/reference/programmable-logic/cora-z7/start)  | JA                  | BTN0         | BTN1         |
| [Cmod S7-25](https://reference.digilentinc.com/reference/programmable-logic/cmod-s7/start)  | JA                  | BTN0         | BTN1         |

This project is formatted a little differently than the standard Digilent Github project.

In order to program the project onto an FPGA:

- Download the latest release ZIP (not the source ZIP) for the target FPGA board from the repo's [releases page](https://github.com/Digilent/Pmod-I2S2/releases).
- Extract and open the downloaded ZIP. Double click on "I2S2.xpr". This will launch an archived version of the project, in which a bitstream has already been generated.
- Open the Vivado Hardware Manager, select "Open Target", and find the target board.
- Program top.bit onto the target. This file can be found within the PmodI2S2/PmodI2S2.runs/impl_1 folder.
	
In order to open a Vivado project after cloning this repo:
- Open Vivado, in the TCL console at the bottom of the window, CD into the folder of the target board (ex: arty-a7-35).
- Call "source ./create_project.tcl". This will create the project for the selected board by combining shared sources with board-specific settings and sources.
