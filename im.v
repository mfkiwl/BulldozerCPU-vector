/*
 * im.v - instruction memory
 *
 * Given a 32-bit address the data is latched and driven
 * on the rising edge of the clock.
 *
 * Currently it supports 7 address bits resulting in
 * 128 bytes of memory.  The lowest two bits are assumed
 * to be byte indexes and ignored.  Bits 8 down to 2
 * are used to construct the address.
 *
 * The memory is initialized using the Verilog $readmemh
 * (read memory in hex format, ascii) operation. 
 * The file to read from can be configured using .IM_DATA
 * parameter and it defaults to "im_data.txt".
 * The number of memory records can be specified using the
 * .NMEM parameter.  This should be the same as the number
 * of lines in the file (wc -l im_data.txt).
 */

`ifndef _im
`define _im

module im (
   input [11:0] addr,
   input clk, 
   output reg [31:0] data
);

   reg [31:0] inst_mem[(2**12)-1:0];
   initial // Read the memory contents in the file
           // inst_init.txt. 
   begin
      $readmemh("inst_init.txt", inst_mem);
   end
	
   always @ (posedge clk)
   begin
      data <= inst_mem[addr];
   end
endmodule

`endif