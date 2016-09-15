`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:06:35 11/14/2015 
// Design Name: 
// Module Name:    clk_25M 
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
module clk_25M(
	clk, 
	clk_s
	);
	
//=============Input Ports=============================
	input 	clk;	// Reloj del sistema
	
	
//=============Output Ports===========================
	output 	clk_s;	// Reloj de salida
	
//=============Input ports Data Type===================
	wire 	clk;
	
	
//=============Output Ports Data Type==================
	reg 	clk_s;
	
//=============Internal Variables======================
	reg 	[1:0] cnt = 2'd2;
	
//==========Code startes Here==========================
	always @(posedge clk)
		if(clk_s)
			cnt <= 2'd2;
		else
			cnt <= cnt - 2'd1;
	
	// Condici�n de finalizaci�n
	always @(*)
		clk_s <= (cnt == 2'd1);
		
endmodule
