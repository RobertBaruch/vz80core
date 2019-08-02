// Covers the 8-bit load group LD (IX/IY + d), n instruction.
// This must write the contents of the memory address at IX + d
// with the immediate byte n.  d is zero-exteded to 16 bits.

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_ixiy_immed(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] n           = z80fi_insn[31:24];
wire [7:0] d           = z80fi_insn[23:16];
wire [7:0] insn_fixed1 = z80fi_insn[15:8];
wire [1:0] insn_fixed2 = z80fi_insn[7:6];
wire       iy          = z80fi_insn[5];
wire [4:0] insn_fixed3 = z80fi_insn[4:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 4 &&
    insn_fixed1 == 8'h36 &&
    insn_fixed2 == 2'b11 &&
    insn_fixed3 == 5'b11101;

// Once spec_valid, what is supposed to happen?
assign spec_reg1_rd = 1;
assign spec_reg2_rd = 0;
assign spec_reg_wr = 0;
assign spec_mem_rd = 0;
assign spec_mem_rd2 = 0;
assign spec_mem_wr = 1;
assign spec_mem_wr2 = 0;

// Data for 1's above.
assign spec_reg1_rnum = iy ? `REG_IY : `REG_IX;

assign spec_mem_waddr = z80fi_reg1_rdata + {8'b0, d};
assign spec_mem_wdata = n;

assign spec_pc_wdata = z80fi_pc_rdata + 4;

endmodule