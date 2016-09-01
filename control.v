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
			5'b00000: begin	/* nop */
				aluop[3:0]	<= 4'b0000;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b0;
				jump		<= 1'b0;
			end
			5'b00100: begin	/* add */
				aluop[3:0]	<= 4'b0000;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
			end
			5'b00110: begin	/* cmpj */
				aluop[3:0]	<= 4'b0001;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b1;
			end
			5'b01000: begin	/* eorv */
				aluop[3:0]	<= 4'b0010;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
				
			end
			5'b01001: begin	/* subv */
				aluop[3:0]	<= 4'b0001;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
			end
			5'b01010: begin	/* addv */
				aluop[3:0]	<= 4'b0000;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;

			end
			5'b01100: begin	/* lslv */
				aluop[3:0]	<= 4'b0011;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
				
			end
			5'b01101: begin	/* lsrv */
				aluop[3:0]	<= 4'b0100;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
				
			end
			5'b01110: begin	/* rorv */
				aluop[3:0]	<= 4'b0101;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
			end
			5'b01111: begin	/* rolv */
				aluop[3:0]	<= 4'b0110;
				memread	<= 1'b0;
				memtoreg	<= 1'b0;
				memwrite	<= 1'b0;
				regwrite	<= 1'b1;
				jump		<= 1'b0;
			end
			6'b10001: begin	/* ldv */
				aluop[3:0]	<= 4'b0000;
				memread	<= 1'b1;
				memtoreg	<= 1'b1;
				memwrite	<= 1'b0;
				regwrite	<= 1'b0;
				jump		<= 1'b0;
			end
			6'b10010: begin	/* stv */
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
