// LD SP, HL
//
// Copies HL into SP.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_sp_hl(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 16'hF9;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG1_RD | `SPEC_REG_WR;

// Data for 1's above.
assign spec_reg1_rnum = `REG_HL;

assign spec_reg_wnum = `REG_SP;
assign spec_reg_wdata = z80fi_reg1_rdata;

assign spec_pc_wdata = z80fi_pc_rdata + 1;

endmodule