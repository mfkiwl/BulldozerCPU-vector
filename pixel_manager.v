`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:20:55 11/12/2015 
// Design Name: 
// Module Name:    pixel_manager 
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
module pixel_manager
   (
	clk,
	reset,
	pixel_x, 
	pixel_y,
	din,
	px_rgb,
	addr_r
   );

//=============Input Ports=============================
	input	clk;	// Reloj del sistema
	input	reset;	// Reset
	input	[9:0] pixel_x; 
	input	[9:0] pixel_y;
	input   [31:0] din;
	
//=============Output Ports===========================
	output  [7:0] px_rgb;
	output  [18:0] addr_r;
	
//=============Input ports Data Type===================
	wire 	clk;
	wire 	reset;
	wire	[9:0] pixel_x; 
	wire	[9:0] pixel_y;
	wire    [31:0] din;
	
//=============Output Ports Data Type==================
	reg     [7:0] px_rgb;
	wire    [18:0] addr_r;
	
//=============Internal Variables======================
	
	
//==========Code startes Here==========================

  
   	//wire [18:0] pxl_addr;
	assign addr_r = {9'b0, pixel_x[9:3] + pixel_y};


	always @*
	begin	
		case (pixel_x[1:0])
			2'b00: px_rgb  <= din[7:0];
			2'b01: px_rgb  <= din[15:8];	
			2'b01: px_rgb  <= din[23:16];
			2'b01: px_rgb  <= din[31:24];	
			default:  px_rgb  <= 8'd0;
		endcase
		//px_rgb = font_rgb;
	end
	
endmodule


