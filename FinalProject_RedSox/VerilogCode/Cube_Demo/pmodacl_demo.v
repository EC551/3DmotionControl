`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Josh Sackos
// 
// Create Date:    07/26/2012
// Module Name:    PmodACL_Demo
// Project Name: 	 PmodACL_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: This is a demo for the Digilent PmodACL.  The SW inputs are
//					 used to select either the x-axis, y-axis, or z-axis data for
//					 display, and RST is used to reset the demo.
//
//					 There are four main components in this module, SPIcomponent, sel_Data,
//					 ClkDiv_5Hz, and ssdCtrl.  A START signal is generated by the ClkDiv_5Hz
//					 component, this signal is used to initiate a data transfer between the
//					 PmodACL and the Nexys3.
//
//					 SPIcomponent receives the START signal, configures the PmodACL, and then
//					 receives data pertaining to all three axes.  The data is made available
//					 to the rest of the design on the xAxis, yAxis, and zAxis outputs.
//
//					 These outputs are then sent into the sel_Data component with the the status
//					 of switches SW1 and SW0 on the Nexys3. Depending on the configuration of
//					 these switches, one of the axes data will be selected for display on the
//					 seven segment display. The selected data is converted from 2's compliment
//					 to magnitude, and is then sent to the ssdCtrl where it is converted to a "g"
//					 value and displayed on the SSD with hundredths precision.
//
//					 To select an axis for display configure SW1 and SW0 on the Nexys3 as
//					 shown below.  LED LD0 will illuminate when the x-axis is selected,
//					 LD1 for y-aixs, and LD2 for z-axis.
//
//							SW1	SW0	|	SSD Output	|	LD2	|	LD1	|	LD0
//							------------------------------------------------------
//							off	off	|	x-axis		|	off	|	off	|	on
//							off	on		|	y-axis		|	off	|	on		|	off
//							on		on		|	x-axis		|	off	|	off	|	on
//							on		off	|	z-axis		|	on		|	off	|	off
//
//
//  Inputs:
//		CLK				Onboard system clock
//		RST				Resets the demo
//		SW<0>				Selects y-axis data for display
//		SW<1>				Selects z-axis data for display
//		SDI				Serial Data In
//
//  Outputs:
//		SDO				Serial Data Out
//		SCLK				Serial Clock
//		SS					Slave Select
//		AN					Anodes on SSD
//		SEG				Cathodes on SSD
//		DOT				Cathode for decimal on SSD
//		LED				LEDs on Nexys3
//
// Revision History: 
// 						Revision 0.01 - File Created (Josh Sackos)
///////////////////////////////////////////////////////////////////////////////////////////

// ====================================================================================
// 										  Define Module
// ====================================================================================
module PmodACL_Demo(
		CLK,//Input
		RST,//Input
//		SW,//Input
		SDI,//Input
		SDO,//Output
		SCLK,//Output
		SS,//Output
		AN,
		SEG,
		acc_out_x,
		acc_out_y,
		acc_out_z
);

// ====================================================================================
// 										Port Declarations
// ====================================================================================
   input        CLK;
   input        RST;
   input        SDI;
	
   output       SDO;
   output       SCLK;
   output       SS;
	
	output [9:0] acc_out_x, acc_out_y, acc_out_z;
   output [3:0] AN;
   output [6:0] SEG;
   
// ====================================================================================
// 								Parameters, Register, and Wires
// ====================================================================================
   
	//INTERNAL WIRES!!------------------------------
//	wire [9:0] acc_out_x, acc_out_y, acc_out_z;
   wire [9:0]   xAxis;		// x-axis data from PmodACL
   wire [9:0]   yAxis;		// y-axis data from PmodACL
   wire [9:0]   zAxis;		// z-axis data from PmodACL
   
//   wire [9:0]   selData;	// Data selected to display
   wire [9:0]   DOUT_x,DOUT_y,DOUT_z;
   wire         START;		// Data Transfer Request Signal
	//INTERNAL WIRES!!------------------------------

		
//  ===================================================================================
// 							  				Implementation
//  ===================================================================================
   
		//-----------------------------------------------
		//	Select Display Data and Convert to Magnitude
		//-----------------------------------------------
		sel_Data SDATA(
					.CLK(CLK),
					.RST(RST),
					.xAxis(xAxis),//input
					.yAxis(yAxis),//input
					.zAxis(zAxis),//input
					.DOUT_x(DOUT_x), //output, DOUT_x/y/z 10th bit=sign, rest is magnitude
					.DOUT_y(DOUT_y), //
					.DOUT_z(DOUT_z)  //
		);
		
		//-----------------------------------------------
		//		 			 Interfaces PmodACL
		//-----------------------------------------------
		SPIcomponent SPI(
					.CLK(CLK),
					.RST(RST),
					.START(START),
					.SDI(SDI),
					.SDO(SDO),
					.SCLK(SCLK),
					.SS(SS),
					.xAxis(xAxis),//output
					.yAxis(yAxis),//output
					.zAxis(zAxis)//output
		);
		
		
		Format_Data format_x(
							.CLK(CLK),//in
							.RST(RST),//in
							.DIN(DOUT_x),//in  10th bit=sign, rest is magnitude
							.acc_out(acc_out_x)//10-bit, MSB=sign, rest is magnitude
		);
		
		Format_Data format_y(
							.CLK(CLK),
							.RST(RST),
							.DIN(DOUT_y), //10th bit=sign, rest is magnitude
							.acc_out(acc_out_y)//10-bit, MSB=sign, rest is magnitude
		);
		
		Format_Data format_z(
							.CLK(CLK),
							.RST(RST),
							.DIN(DOUT_z), //10th bit=sign, rest is magnitude
							.acc_out(acc_out_z)//10-bit, MSB=sign, rest is magnitude
		);
		
		
		//-----------------------------------------------
		//	 Generates a 5Hz Data Transfer Request Signal
		//-----------------------------------------------
		ClkDiv_5Hz genStart(
					.CLK(CLK),
					.RST(RST),
					.CLKOUT(START)
		);
   
endmodule
