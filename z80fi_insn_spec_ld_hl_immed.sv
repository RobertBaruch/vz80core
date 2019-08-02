// Covers the 8-bit load group LD (HL), n instruction.
// This must write n to the memory address stored in HL.

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_hl_immed(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] n           = z80fi_insn[15:8];
wire [7:0] insn_fixed1 = z80fi_insn[7:0];

// LD (HL), n instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    insn_fixed1 == 8'b00110110;

// Once spec_valid, what is supposed to happen?
assign spec_reg1_rd = 1;
assign spec_reg2_rd = 0;
assign spec_reg_wr = 0;
assign spec_mem_rd = 0;
assign spec_mem_rd2 = 0;
assign spec_mem_wr = 1;
assign spec_mem_wr2 = 0;

// Data for 1's above.
assign spec_reg1_rnum = `REG_HL;

assign spec_mem_waddr = z80fi_reg1_rdata;
assign spec_mem_wdata = n;

assign spec_pc_wdata = z80fi_pc_rdata + 2;

endmodule