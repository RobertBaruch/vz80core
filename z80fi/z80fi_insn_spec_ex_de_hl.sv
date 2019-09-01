// EX DE, HL
//
// Exchanges DE and HL.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ex_de_hl(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b11101011;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_DE | `SPEC_REG_HL;

assign spec_reg_h_out = z80fi_reg_d_in;
assign spec_reg_l_out = z80fi_reg_e_in;
assign spec_reg_d_out = z80fi_reg_h_in;
assign spec_reg_e_out = z80fi_reg_l_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_NONE;

assign spec_tcycles1 = 4;

endmodule