module bulldozer
   (
   clk, 
	reset,
	hsync,
	vsync,
	rgb_out,
	blank,
	v_clk
   );
	
//=============Input Ports=============================
	input 	clk;	// Reloj del sistema
	input 	reset;	// Reset
	
//=============Output Ports===========================
	output	hsync;
	output	vsync;
	output	[23:0] rgb_out;
	output	blank;
	output	v_clk;
	
//=============Input ports Data Type===================
	wire 	clk;
	wire 	reset;
	
//=============Output Ports Data Type==================
	wire	hsync;
	wire	vsync;
	wire	[23:0] rgb_out;
	wire	blank;
	wire	v_clk;
	
//=============Internal Variables======================

	wire  	[16:0] addr_a;
	wire  	[31:0] din_a;
	wire 		[31:0] dout_a;
	reg	  	[16:0] addr_b;
	wire   	[31:0] dout_b;
	wire 		mem_wr;
	wire		clk_25;
	reg		[7:0]rgb;
	wire		[9:0]x_pos;
	wire		[9:0]y_pos;
	
//==========Code startes Here==========================

	clk_25M video_clk(.clk(clk), .clk_s(clk_25));
	
	dp_ram bull_mem(.clk(clk), .w(mem_wr), .addr_a(addr_a), .addr_b(addr_b), 
						.din_a(din_a), .dout_a(dout_a), .dout_b(dout_b));
						

	cpu bull_cpu(.clk(clk), .din(dout_a), .wr_mem(mem_wr), .mem_addr(addr_a), .dout(din_a));
	
	vga_driver bull_vga(.clk27(clk_25), .rst27(reset), .r(rgb), .g(rgb), .b(rgb), .current_x(x_pos), .current_y(y_pos), .request(), 
						.vga_r(rgb_out[23:16]), .vga_g(rgb_out[15:8]), .vga_b(rgb_out[7:0]), .vga_hs(hsync), .vga_vs(vsync), .vga_blank(blank), .vga_clock(v_clk));
	
	always @(posedge clk_25)
	begin	
		if(y_pos >= 9'd479 && x_pos >= 9'd159)
				begin
					addr_b <= 17'd0;
				end
		case (x_pos[1:0])
			2'b00: rgb  <= dout_b[7:0];
			2'b01: rgb  <= dout_b[15:8];	
			2'b10: rgb  <= dout_b[23:16];
			2'b11: 
			begin 
				rgb  <= dout_b[31:24];
				addr_b <= addr_b + 17'd1;
			end	
			default:  rgb  <= 8'd255;
		endcase
	end

endmodule
