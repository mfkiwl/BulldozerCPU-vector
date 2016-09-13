/*
 * cpu. - five stage MIPS CPU.
 *
 * Many variables (wires) pass through several stages.
 * The naming convention used for each stage is
 * accomplished by appending the stage number (_s<num>).
 * For example the variable named "data" which is
 * in stage 2 and stage 3 would be named as follows.
 *
 * wire data_s2;
 * wire data_s3;
 *	
 * If the stage number is omitted it is assumed to
 * be at the stage at which the variable is first
 * established.
 */

`include "regr.v"
`include "im.v"
`include "regm.v"
`include "control.v"
`include "alu_8.v"
`include "alu_32.v"
`include "dm.v"

`ifndef DEBUG_CPU_STAGES
`define DEBUG_CPU_STAGES 0
`endif

module cpu(
		input wire clk, input wire [31:0] din, output wire wr_mem, output wire [18:0] mem_addr, output wire [31:0] dout);

	parameter NMEM = 20;  // number in instruction memory
	parameter IM_DATA = "im_data.txt";

	// {{{ diagnostic outputs
//	initial begin
//		if (`DEBUG_CPU_STAGES) begin
//			$display("if_pc,    if_instr, id_regrs, id_regrt, ex_alua,  ex_alub,  ex_aluctl, mem_memdata, mem_memread, mem_memwrite, wb_regdata, wb_regwrite");
//			$monitor("%x, %x, %x, %x, %x, %x, %x,         %x,    %x,           %x,            %x,   %x",
//					pc,				/* if_pc */
//					inst,			/* if_instr */
//					data1,			/* id_regrs */
//					data2,			/* id_regrt */
//					data1_s3,		/* data1_s3 */
//					alusrc_data2,	/* alusrc_data2 */
//					aluctl,			/* ex_aluctl */
//					data2_s4,		/* mem_memdata */
//					memread_s4,		/* mem_memread */
//					memwrite_s4,	/* mem_memwrite */
//					wrdata_s5,		/* wb_regdata */
//					regwrite_s5		/* wb_regwrite */
//				);
//		end
//	end
	// }}}

	// {{{ flush control
	reg flush_s1, flush_s2, flush_s3;
	wire jump_s4, zero_s4;
	 
	reg stall_s1_s2;
	always @(*) begin
		flush_s1 <= 1'b0;
		flush_s2 <= 1'b0;
		flush_s3 <= 1'b0;
		if (jump_s4) begin
			flush_s1 <= 1'b1;
			flush_s2 <= 1'b1;
			flush_s3 <= 1'b1;
		end
	end
	// }}}

	// {{{ stage 1, IF (fetch)

	reg  [31:0] pc;
	initial begin
		pc <= 32'd0;
	end

	wire [31:0] pc4;  // PC + 4
	assign pc4 = pc + 4;

	wire [31:0] jaddr_s4;
	
	always @(posedge clk) begin
		if (jump_s4 && zero_s4)
			pc <=  jaddr_s4;
		if (stall_s1_s2) 
			pc <= pc;
		else
			pc <= pc4;
	end

	// pass PC + 4 to stage 2
	wire [31:0] pc4_s2;
	regr #(.N(32)) regr_pc4_s2(.clk(clk),
						.hold(stall_s1_s2), .clear(flush_s1),
						.in(pc4), .out(pc4_s2));

	// instruction memory
	wire [31:0] inst;
	wire [31:0] inst_s2;
	im #(.NMEM(NMEM), .IM_DATA(IM_DATA))
		im1(.clk(clk), .addr(pc), .data(inst));
	regr #(.N(32)) regr_im_s2(.clk(clk),
						.hold(stall_s1_s2), .clear(flush_s1),
						.in(inst), .out(inst_s2));

	// }}}

	// {{{ stage 2, ID (decode)

	// decode instruction
	wire 		v;
	wire [4:0]  opcode;
	wire [3:0]  rd;
	wire [3:0]  rn;
	wire [3:0]  rm;
	wire 		i; 
	wire [31:0] shimm;  // shifted immediate
	//
	assign v 		 = inst_s2[27];
	assign opcode   = inst_s2[26:22];
	assign rd       = inst_s2[21:18];
	assign rn       = inst_s2[17:14];
	assign i 		= inst_s2[13];
	assign rm       = inst_s2[3:0];
	assign shimm 	= inst_s2[7:0] << inst_s2[12:8];

	// register memory
	wire [31:0] data1, data2;
	wire regwrite_s5;
	wire [3:0] wrreg_s5;
	wire [31:0]	wrdata_s5;
	regm regm1(.clk(clk), .read1(rn), .read2(rm),
			.data1(data1), .data2(data2),
			.regwrite(regwrite_s5), .wrreg(wrreg_s5),
			.wrdata(wrdata_s5));

	// pass rm to stage 3 (for forwarding)
	wire [3:0] rm_s3;
	regr #(.N(5)) regr_s2_rm(.clk(clk), .clear(1'b0), .hold(stall_s1_s2),
				.in(rm), .out(rm_s3));

	// transfer register data to stage 3
	wire [31:0]	data1_s3, data2_s3;
	regr #(.N(64)) reg_s2_mem(.clk(clk), .clear(flush_s2), .hold(stall_s1_s2),
				.in({data1, data2}),
				.out({data1_s3, data2_s3}));

	// transfer shimm, rn, and rd to stage 3
	wire [31:0] shimm_s3;
	wire [3:0] 	rn_s3;
	wire [3:0] 	rd_s3;
	regr #(.N(32)) reg_s2_shimm(.clk(clk), .clear(flush_s2), .hold(stall_s1_s2),
						.in(shimm), .out(shimm_s3));
	regr #(.N(8)) reg_s2_rt_rd(.clk(clk), .clear(flush_s2), .hold(stall_s1_s2),
						.in({rn, rd}), .out({rn_s3, rd_s3}));

	// transfer PC + 4 to stage 3
	wire [31:0] pc4_s3;
	regr #(.N(32)) reg_pc4_s2(.clk(clk), .clear(1'b0), .hold(stall_s1_s2),
						.in(pc4_s2), .out(pc4_s3));

	// control (opcode -> ...)
	wire		memread;
	wire		memwrite;
	wire		memtoreg;
	wire [1:0]	aluop;
	wire		regwrite;
	wire		alusrc;
	wire		jump_s2;
	//
	control ctl1(.opcode(opcode),
				.memread(memread),
				.memtoreg(memtoreg), .aluop(aluop),
				.memwrite(memwrite),
				.regwrite(regwrite), .jump(jump_s2));


	// transfer the control signals to stage 3
	wire		memread_s3;
	wire		memwrite_s3;
	wire		memtoreg_s3;
	wire [1:0]	aluop_s3;
	wire		regwrite_s3;
	wire		alusrc_s3;
	wire		vect_op_s3;
	// A bubble is inserted by setting all the control signals
	// to zero (stall_s1_s2).
	regr #(.N(8)) reg_s2_control(.clk(clk), .clear(stall_s1_s2), .hold(1'b0),
			.in({memread, memwrite, memtoreg, aluop, regwrite, i, v}),
			.out({memread_s3, memwrite_s3, memtoreg_s3, aluop_s3, regwrite_s3, alusrc_s3, vect_op_s3}));
					
	wire jump_s3;
	regr #(.N(1)) reg_jump_s3(.clk(clk), .clear(flush_s2), .hold(1'b0),
				.in(jump_s2),
				.out(jump_s3));
	
	wire [31:0] jaddr_s3;
	regr #(.N(32)) reg_jaddr_s3(.clk(clk), .clear(flush_s2), .hold(1'b0),
				.in(shimm), .out(jaddr_s3));

	// }}}

	// {{{ stage 3, EX (execute)

	// pass through some control signals to stage 4
	wire regwrite_s4;
	wire memtoreg_s4;
	wire memread_s4;
	wire memwrite_s4;
	regr #(.N(4)) reg_s3(.clk(clk), .clear(flush_s2), .hold(1'b0),
				.in({regwrite_s3, memtoreg_s3, memread_s3,
						memwrite_s3}),
				.out({regwrite_s4, memtoreg_s4, memread_s4,
						memwrite_s4}));

	// ALU
	// second ALU input can come from an immediate value or data
	wire [31:0] alusrc_data2;
	assign alusrc_data2 = (alusrc_s3) ? {shimm_s3[7:0], shimm_s3[7:0], shimm_s3[7:0], shimm_s3[7:0]} : data2_s3;
	

	// ALU Int
	wire [31:0]	alurslt_int;
	wire zero_s3;
	alu_32 alu_int(.ctl(aluop_s3), .a(data1_s3), .b(alusrc_data2), .out(alurslt_int),
									.zero(zero_s3));
									
	// ALU 1
	wire [7:0]	alurslt1;
	alu_8 alu_1(.ctl(aluop_s3), .a(data1_s3[7:0]), .b(alusrc_data2[7:0]), .out(alurslt1));
	
	// ALU 2
	wire [7:0]	alurslt2;
	alu_8 alu_2(.ctl(aluop_s3), .a(data1_s3[15:8]), .b(alusrc_data2[15:8]), .out(alurslt2));
	
	// ALU 3
	wire [7:0]	alurslt3;
	alu_8 alu_3(.ctl(aluop_s3), .a(data1_s3[23:16]), .b(alusrc_data2[23:16]), .out(alurslt3));
	
	// ALU 4
	wire [7:0]	alurslt4;
	alu_8 alu_4(.ctl(aluop_s3), .a(data1_s3[31:24]), .b(alusrc_data2[31:24]), .out(alurslt4));
	
	wire [31:0] alurslt;
	assign alurslt = (vect_op_s3) ? {alurslt4, alurslt3, alurslt2, alurslt1} : alurslt_int;
	
	//wire zero_s4;
	regr #(.N(1)) reg_zero_s3_s4(.clk(clk), .clear(1'b0), .hold(1'b0),
					.in(zero_s3), .out(zero_s4));

	// pass ALU result and zero to stage 4
	wire [31:0]	alurslt_s4;
	regr #(.N(32)) reg_alurslt(.clk(clk), .clear(flush_s3), .hold(1'b0),
				.in({alurslt}),
				.out({alurslt_s4}));

	// pass data2 to stage 4
	wire [31:0] data2_s4;
	regr #(.N(32)) reg_data2_s3(.clk(clk), .clear(flush_s3), .hold(1'b0),
				.in(data2_s3), .out(data2_s4));

	// write register
	wire [3:0]	wrreg_s4;
	// pass to stage 4
	regr #(.N(4)) reg_wrreg(.clk(clk), .clear(flush_s3), .hold(1'b0),
				.in(rd_s3), .out(wrreg_s4));

	//wire jump_s4;
	regr #(.N(1)) reg_jump_s4(.clk(clk), .clear(flush_s3), .hold(1'b0),
				.in(jump_s3),
				.out(jump_s4));

	//wire [31:0] jaddr_s4;
	regr #(.N(32)) reg_jaddr_s4(.clk(clk), .clear(flush_s3), .hold(1'b0),
				.in(jaddr_s3), .out(jaddr_s4));
	// }}}

	// {{{ stage 4, MEM (memory)

	// pass regwrite and memtoreg to stage 5
	//wire regwrite_s5;
	wire memtoreg_s5;
	regr #(.N(2)) reg_regwrite_s4(.clk(clk), .clear(1'b0), .hold(1'b0),
				.in({regwrite_s4, memtoreg_s4}),
				.out({regwrite_s5, memtoreg_s5}));

	// data memory
	wire [31:0] rdata;
//dm dm1(.clk(clk), .addr(alurslt_s4), .rd(memread_s4), .wr(memwrite_s4),
	//		.wdata(data2_s4), .rdata(rdata));
			
	assign rdata = din;
	assign wr_mem = memwrite_s4;
	assign mem_addr = alurslt_s4;
	assign dout = data2_s4;
			
	// pass read data to stage 5
	wire [31:0] rdata_s5;
	regr #(.N(32)) reg_rdata_s4(.clk(clk), .clear(1'b0), .hold(1'b0),
				.in(rdata),
				.out(rdata_s5));

	// pass alurslt to stage 5
	wire [31:0] alurslt_s5;
	regr #(.N(32)) reg_alurslt_s4(.clk(clk), .clear(1'b0), .hold(1'b0),
				.in(alurslt_s4),
				.out(alurslt_s5));

	// pass wrreg to stage 5
	//wire [3:0] wrreg_s5;
	regr #(.N(4)) reg_wrreg_s4(.clk(clk), .clear(1'b0), .hold(1'b0),
				.in(wrreg_s4),
				.out(wrreg_s5));
	// }}}
			
	// {{{ stage 5, WB (write back)

	//wire [31:0]	wrdata_s5;
	assign wrdata_s5 = (memtoreg_s5 == 1'b1) ? rdata_s5 : alurslt_s5;

	// }}}

	// {{{ load use data hazard detection, signal stall

	/* If an operation in stage 4 (MEM) loads from memory (e.g. lw)
	 * and the operation in stage 3 (EX) depends on this value,
	 * a stall must be performed.  The memory read cannot 
	 * be forwarded because memory access is too slow.  It can
	 * be forwarded from stage 5 (WB) after a stall.
	 *
	 *   lw $1, 16($10)  ; I-type, rt_s3 = $1, memread_s3 = 1
	 *   sw $1, 32($12)  ; I-type, rt_s2 = $1, memread_s2 = 0
	 *
	 *   lw $1, 16($3)  ; I-type, rt_s3 = $1, memread_s3 = 1
	 *   sw $2, 32($1)  ; I-type, rt_s2 = $2, rs_s2 = $1, memread_s2 = 0
	 *
	 *   lw  $1, 16($3)  ; I-type, rt_s3 = $1, memread_s3 = 1
	 *   add $2, $1, $1  ; R-type, rs_s2 = $1, rt_s2 = $1, memread_s2 = 0
	 */
	//reg stall_s1_s2;
	always @(*) begin
		if (memread_s3 == 1'b1 && ((rn == rn_s3) || (rm == rn_s3)) ) begin
			stall_s1_s2 <= 1'b1;  // perform a stall
		end else
			stall_s1_s2 <= 1'b0;  // no stall
	end
	// }}}

endmodule

// vim:foldmethod=marker
