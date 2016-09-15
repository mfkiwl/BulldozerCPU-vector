`ifndef _control
`define _control

module control(
		input  wire	[4:0]	opcode,
		output reg [3:0]	aluop,
		output reg			memread, memwrite, memtoreg,
		output reg			regwrite,
		output reg			jump);

	always @(*) begin
		/* defaults */
		aluop[3:0]	<= 2'b10;
		memread		<= 1'b0;
		memtoreg	<= 1'b0;
		memwrite	<= 1'b0;
		regwrite	<= 1'b1;
		jump		<= 1'b0;

		case (opcode)
			5'd0: begin	/* nop */
				aluop[3:0]	<= 4'b0000;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b0;
				jump		<= 1'b0;
			end
			5'd4: begin	/* add */
				aluop[3:0]	<= 4'b0000;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
			end
			5'd6: begin	/* cmpj */
				aluop[3:0]	<= 4'b0001;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b1;
			end
			5'd2: begin	/* eor */
				aluop[3:0]	<= 4'b0010;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
				
			end
			5'd3: begin	/* sub */
				aluop[3:0]	<= 4'b0001;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
			end
			5'd7: begin	/* lsl */
				aluop[3:0]	<= 4'b0011;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
				
			end
			5'd8: begin	/* lsrv */
				aluop[3:0]	<= 4'b0100;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
				
			end
			5'd09: begin	/* rorv */
				aluop[3:0]	<= 4'b0101;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
			end
			5'd10: begin	/* rolv */
				aluop[3:0]	<= 4'b0110;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
			end
			5'd12: begin	/* ldv */
				aluop[3:0]	<= 4'b0000;
				memread	<= 1'b1;
				memtoreg	<= 1'b1;
				memwrite	<= 1'b0;
				regwrite	<= 1'b0;
				jump		<= 1'b0;
			end
			5'd13: begin	/* stv */
				aluop[3:0]	<= 4'b0000;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b1;
				regwrite	<= 1'b0;
				jump		<= 1'b0;
			end
			default: begin
				aluop[3:0]	<= 4'b0000;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b0;
			end
		endcase
	end
endmodule

`endif
