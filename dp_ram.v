`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:16:44 11/12/2015 
// Design Name: 
// Module Name:    dp_ram 
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
module dp_ram
   #(parameter ADDR_WIDTH = 19,
               DATA_WIDTH = 32
   )
   (
    clk,
    w,
    addr_a, 
    addr_b,
    din_a,
    dout_a, 
    dout_b
   );


//=============Input Ports=============================
	input 	clk;	// Reloj del sistema
	input 	w;	
	input	[ADDR_WIDTH-1:0] addr_a;
	input	[ADDR_WIDTH-1:0] addr_b;
	input	[DATA_WIDTH-1:0] din_a;
	
//=============Output Ports===========================
	output 	[DATA_WIDTH-1:0] dout_a;
	output	[DATA_WIDTH-1:0] dout_b;	
	
//=============Input ports Data Type===================
	wire 	clk;
	wire 	w;
	wire	[ADDR_WIDTH-1:0] addr_a;
	wire	[ADDR_WIDTH-1:0] addr_b;
	wire	[DATA_WIDTH-1:0] din_a;
	
//=============Output Ports Data Type==================
	wire 	[DATA_WIDTH-1:0] dout_a;
	wire	[DATA_WIDTH-1:0] dout_b;
	
//=============Internal Variables======================
	reg 	[DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0];
   reg 	[ADDR_WIDTH-1:0] addr_a_reg, addr_b_reg;
	
//==========Code startes Here==========================
	
	always @(negedge clk)
	begin
		if (w)begin  // write operation
				ram[addr_a] <= din_a;
		end
		addr_a_reg <= addr_a;
	end
	
	always @(posedge clk)
	begin
		addr_b_reg <= addr_b;
	end

	// two read operations
	assign dout_a = ram[addr_a_reg];
	assign dout_b = ram[addr_b_reg];

endmodule