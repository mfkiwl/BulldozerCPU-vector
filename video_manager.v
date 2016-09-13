`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:22:13 11/12/2015 
// Design Name: 
// Module Name:    video_manager 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module video_manager
   (
   clk, 
	reset,
	din,
	hsync,
	vsync,
	rgb,
	addr_r
   );

//=============Input Ports=============================
	input 	clk;	// Reloj del sistema
	input 	reset;	// Reset
	input	[31:0]din;
	
//=============Output Ports===========================
	output	hsync;
	output	vsync;
	output	[7:0] rgb;
	output 	[18:0]addr_r;
	
//=============Input ports Data Type===================
	wire 	clk;
	wire 	reset;
	wire	[31:0]din;
	
//=============Output Ports Data Type==================
	wire	hsync;
	wire	vsync;
	wire	[7:0] rgb;
	wire  	[18:0] addr_r;
	
//=============Internal Variables======================
   wire 	[9:0] pixel_x, pixel_y;
   //reg 		[7:0] rgb_reg;
   wire 	[7:0] rgb_next;
	
//==========Code startes Here==========================
	
	
   // instantiate vga sync circuit
   vga_sync vsync_unit(clk, hsync, vsync, pixel_x, pixel_y);

   // font generation circuit
   pixel_manager px_man(clk, reset, pixel_x, pixel_y, din, rgb_next, addr_r);

   // rgb buffer
   //always @(posedge clk)
      //if (pixel_tick)
         //rgb_reg <= rgb_next;

   // output
   assign rgb = rgb_next;

endmodule

