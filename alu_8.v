`ifndef _alu_8
`define _alu_8


module alu_8(
		input		[3:0]	ctl,
		input		[7:0]	a, b,
		output reg	[7:0]	out);

	wire [8:0] sub_ab;
	wire [7:0] add_ab;
	wire 		oflow_add;
	wire 		oflow_sub;
	wire 		oflow;

	assign sub_ab = (a < b) ? {1'b1, a} - b : {1'b0, a - b};
	assign add_ab = a + b;

	always @(*) begin
		case (ctl)
			4'd0:  out <= add_ab;			/* add */
			4'd1:  out <= sub_ab[7:0];			/* sub */
			4'd2:  out <= a ^ b;				/* xor */
			4'd3:  out <= a << b;			/* lsl */
			4'd4:  out <= a >> b;			/* lsr */
			4'd5:	 out <= {a,a} >> (4'd8-b[2:0]);  /* ror */
			4'd6:	 out <= {a,a} >> (4'd8-b[2:0]);  /* rol */
			default: out <= 0;
		endcase
	end

endmodule

`endif