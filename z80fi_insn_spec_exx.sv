// EXX
//
// Exchanges BC, DE, HL and BC', DE', HL'.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_exx(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'hD9;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP |
    `SPEC_REG_BC | `SPEC_REG_DE | `SPEC_REG_HL |
    `SPEC_REG_BC2 | `SPEC_REG_DE2 | `SPEC_REG_HL2;

assign spec_reg_b_out = z80fi_reg_b2_in;
assign spec_reg_c_out = z80fi_reg_c2_in;
assign spec_reg_d_out = z80fi_reg_d2_in;
assign spec_reg_e_out = z80fi_reg_e2_in;
assign spec_reg_h_out = z80fi_reg_h2_in;
assign spec_reg_l_out = z80fi_reg_l2_in;
assign spec_reg_b2_out = z80fi_reg_b_in;
assign spec_reg_c2_out = z80fi_reg_c_in;
assign spec_reg_d2_out = z80fi_reg_d_in;
assign spec_reg_e2_out = z80fi_reg_e_in;
assign spec_reg_h2_out = z80fi_reg_h_in;
assign spec_reg_l2_out = z80fi_reg_l_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

endmodule