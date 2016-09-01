`ifndef _alu
`define _alu


module alu_32(
		input		[3:0]	ctl,
		input		[31:0]	a, b,
		output reg	[31:0]	out,
		output				zero);

	wire [32:0] sub_ab;
	wire [31:0] add_ab;
	wire 		oflow_add;
	wire 		oflow_sub;
	wire 		oflow;

	assign zero = (0 == out);

	assign sub_ab = (a < b) ? {1'b1, a} - b : {1'b0, a - b};
	assign add_ab = a + b;

	// overflow occurs (with 2s complement numbers) when
	// the operands have the same sign, but the sign of the result is
	// different.  The actual sign is the opposite of the result.
	// It is also dependent on whether addition or subtraction is performed.
	assign oflow_add = (a[31] == b[31] && add_ab[31] != a[31]) ? 1'b1 : 1'b0;
	assign oflow_sub = (a[31] == b[31] && sub_ab[31] != a[31]) ? 1'b1 : 1'b0;

	assign oflow = (ctl == 4'b0000) ? oflow_add : oflow_sub;

	always @(*) begin
		case (ctl)
			4'd0:  out <= add_ab;			/* add */
			4'd1:  out <= sub_ab[31:0];			/* sub */
			4'd2:  out <= a ^ b;				/* xor */
			4'd3:  out <= a << b;			/* lsl */
			4'd4:  out <= a >> b;			/* lsr */
			4'd5:	 out <= {a,a} >> (6'd32-b[4:0]);  /* ror */
			4'd6:	 out <= {a,a} >> (6'd32-b[4:0]);  /* rol */
			default: out <= 0;
		endcase
	end

endmodule

`endif
