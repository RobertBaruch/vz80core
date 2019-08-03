// Covers the 8-bit load group LD (HL), r instruction.
// This must write the contents of register r to the memory
// address stored in HL.

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_hl_reg(
    `Z80FI_INSN_SPEC_IO
);

wire [4:0] insn_fixed1 = z80fi_insn[7:3];
wire [2:0] r           = z80fi_insn[2:0];

// LD (HL), n instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    insn_fixed1 == 5'b01110 &&
    r != 6;

// Once spec_valid, what is supposed to happen?
assign spec_reg1_rd = 1;
assign spec_reg2_rd = 1;
assign spec_reg_wr = 0;
assign spec_mem_rd = 0;
assign spec_mem_rd2 = 0;
assign spec_mem_wr = 1;
assign spec_mem_wr2 = 0;
assign spec_i_rd = 0;
assign spec_i_wr = 0;
assign spec_r_rd = 0;
assign spec_r_wr = 0;
assign spec_f_rd = 0;
assign spec_f_wr = 0;

// Data for 1's above.
assign spec_reg1_rnum = `REG_HL;
assign spec_reg2_rnum = {1'b0, r};

assign spec_mem_waddr = z80fi_reg1_rdata;
assign spec_mem_wdata = z80fi_reg2_rdata[7:0];

assign spec_pc_wdata = z80fi_pc_rdata + 1;

endmodule