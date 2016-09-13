`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:21:54 11/12/2015 
// Design Name: 
// Module Name:    vga_sync 
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
module vga_sync(
	clk,
	h_sync, 
	v_sync,
	x, 
	y
);

//=============Input Ports=============================
	input   	clk;

//=============Output Ports===========================
	output 	h_sync;
	output	v_sync;
	output	[9:0] x;
	output	[9:0] y;

//=============Input ports Data Type===================
	wire	clk;	// Señal de reloj

//=============Output Ports Data Type==================
	wire	h_sync;	// Señal de sincronización horizontal
	wire	v_sync;	// Señal de sincronización vertical
	wire	[9:0] x;	//	Posición en X de un pixel
	wire	[9:0] y;	// Posición en Y de un pixel

//=============Internal Constants======================
	localparam H_PW   = 10'd96;  	// pulse width
	localparam H_BP   = 10'd48; 	// back porch
	localparam H_DISP = 10'd640;	// display
	localparam H_FP   = 10'd16;  	// front porch 
	localparam H_S    = H_PW + H_BP + H_DISP + H_FP; // sync pulse

	localparam V_PW   = 10'd2;  	// pulse width 
	localparam V_BP   = 10'd33; 	// back porch 
	localparam V_DISP = 10'd480; 	// display
	localparam V_FP   = 10'd10;  	// front porch
	localparam V_S    = V_PW + V_BP + V_DISP + V_FP; //sync pulse

//=============Internal Variables======================
	reg	[9:0] cont_x; 
	reg	[9:0] cont_y;
   reg	in_hs; 
	reg	in_vs;

//==========Code startes Here==========================


	wire cont_x_max = (cont_x == H_S - 1);  	// Máximo dado por el pulso de sincronización - 1
	wire cont_y_max = (cont_y == V_S - 1);   	// contador y maximo es cuando el contador x es igual  al pulso de sincronizacion - 1
    
	// Incializar contadores en 0
	initial begin
		cont_x <= 0;
		cont_y <= 0;
	end
	
	//Esto de aqui se encarga de realizar el divisor de frecuencia
 // reg[1:0] count;
 // always@(posedge clk) count <= count + 1;
 // wire en4 = (count[1:0] == 2'b11);
  //wire clk_s;
  
  // instantiate vga sync circuit
   //clk_25M clk_25_unit(clk, clk_s);
	
	//Barrido de la pantalla, se aumenta el contador en X en cada ciclo y el contador Y cada vez que se acaba una fila en X.
	always @(posedge clk) begin
		if (cont_x_max) 
		begin
		    cont_x <= 0;
		    cont_y <= cont_y + 1'b1;
		    if (cont_y_max)
		        cont_y <= 0;
		end
      else
          cont_x <= cont_x + 1'b1;
	end
	
	// Se verifica si es señal de sincronización
	always @(posedge clk) begin
		in_hs = (cont_x < H_PW);     // si cont_x es menor que retraso horizontal es true 
		in_vs = (cont_y < V_PW);     // si cont_y es menor que retraso vertical es true
	end 

	// Se asigna el resultado negado de la verificación a las señales de salida
	assign h_sync = ~in_hs;         
	assign v_sync = ~in_vs;

	// Colocar el pixel actual en las salidas
	assign x = cont_x - (H_PW + H_BP);  
	assign y = cont_y - (V_PW + V_BP); 

endmodule



