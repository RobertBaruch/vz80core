// Covers the 8-bit load group LD r, r' instructions.
// This must read register r' and write its value to
// register r.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_reg_reg(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] insn_rreg  = z80fi_insn[2:0];
wire [2:0] insn_wreg  = z80fi_insn[5:3];

// LD r, r' instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b01?????? &&
    insn_rreg != 6 &&
    insn_wreg != 6;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_BC | `SPEC_REG_DE |
    `SPEC_REG_HL | `SPEC_REG_A;

wire [7:0] n =
    (insn_rreg == `REG_A) ? z80fi_reg_a_in :
    (insn_rreg == `REG_B) ? z80fi_reg_b_in :
    (insn_rreg == `REG_C) ? z80fi_reg_c_in :
    (insn_rreg == `REG_D) ? z80fi_reg_d_in :
    (insn_rreg == `REG_E) ? z80fi_reg_e_in :
    (insn_rreg == `REG_H) ? z80fi_reg_h_in :
    (insn_rreg == `REG_L) ? z80fi_reg_l_in : 0;
assign spec_reg_a_out = (insn_wreg == `REG_A) ? n : z80fi_reg_a_in;
assign spec_reg_b_out = (insn_wreg == `REG_B) ? n : z80fi_reg_b_in;
assign spec_reg_c_out = (insn_wreg == `REG_C) ? n : z80fi_reg_c_in;
assign spec_reg_d_out = (insn_wreg == `REG_D) ? n : z80fi_reg_d_in;
assign spec_reg_e_out = (insn_wreg == `REG_E) ? n : z80fi_reg_e_in;
assign spec_reg_h_out = (insn_wreg == `REG_H) ? n : z80fi_reg_h_in;
assign spec_reg_l_out = (insn_wreg == `REG_L) ? n : z80fi_reg_l_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

endmodule