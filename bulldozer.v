module bulldozer
   (
   clk, 
	reset,
	hsync,
	vsync,
	rgb
   );
	
//=============Input Ports=============================
	input 	clk;	// Reloj del sistema
	input 	reset;	// Reset
	
//=============Output Ports===========================
	output	hsync;
	output	vsync;
	output	[7:0] rgb;
	
//=============Input ports Data Type===================
	wire 	clk;
	wire 	reset;
	
//=============Output Ports Data Type==================
	wire	hsync;
	wire	vsync;
	wire	[7:0] rgb;
	
//=============Internal Variables======================

	wire    [18:0] addr_a;
	wire    [31:0] din_a;
	wire    [31:0] dout_a;
	wire    [18:0] addr_b;
	wire    [31:0] dout_b;
	wire 		mem_wr;
	
//==========Code startes Here==========================

	cpu bull_cpu(.clk(clk), .din(dout_a), .wr_mem(mem_wr), .mem_addr(addr_a), .dout(din_a));
	video_manager bull_vga(.clk(clk), .reset(reset), .din(dout_b), 
						.hsync(hsync), .vsync(vsync), .rgb(rgb), .addr_r(addr_b));
						
	dp_ram bull_mem(.clk(clk), .w(mem_wr), .addr_a(addr_a), .addr_b(addr_b), 
						.din_a(din_a), .dout_a(dout_a), .dout_b(dout_b));

endmodule
