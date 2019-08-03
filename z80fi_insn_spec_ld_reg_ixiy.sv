// Covers the 8-bit load group LD r, (IX/IY + d) instruction.
// This must write the contents of the memory address at IX + d
// to register r.  d is zero-exteded to 16 bits.

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_reg_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] d           = z80fi_insn[23:16];
wire [1:0] insn_fixed1 = z80fi_insn[15:14];
wire [2:0] r           = z80fi_insn[13:11];
wire [2:0] insn_fixed2 = z80fi_insn[10:8];
wire [1:0] insn_fixed3 = z80fi_insn[7:6];
wire       iy          = z80fi_insn[5];
wire [4:0] insn_fixed4 = z80fi_insn[4:0];

// LD r, (IX/IY + d) instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    insn_fixed1 == 2'b01 &&
    insn_fixed2 == 3'b110 &&
    insn_fixed3 == 2'b11 &&
    insn_fixed4 == 5'b11101 &&
    r != 6;

// Once spec_valid, what is supposed to happen?
assign spec_reg1_rd = 1;
assign spec_reg2_rd = 0;
assign spec_reg_wr = 1;
assign spec_mem_rd = 1;
assign spec_mem_rd2 = 0;
assign spec_mem_wr = 0;
assign spec_mem_wr2 = 0;
assign spec_i_rd = 0;
assign spec_i_wr = 0;
assign spec_r_rd = 0;
assign spec_r_wr = 0;
assign spec_f_rd = 0;
assign spec_f_wr = 0;

// Data for 1's above.
assign spec_reg1_rnum = iy ? `REG_IY : `REG_IX;

assign spec_reg_wnum = {1'b0, r};
assign spec_reg_wdata = z80fi_mem_rdata;

assign spec_mem_raddr = z80fi_reg1_rdata + {8'b0, d};
assign spec_mem_rdata = z80fi_mem_rdata;

assign spec_pc_wdata = z80fi_pc_rdata + 3;

endmodule