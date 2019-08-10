// EX AF, AF'
//
// Exchanges AF and AF'.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ex_af_af2(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'h08;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_AF | `SPEC_REG_AF2;

assign spec_reg_a_out = z80fi_reg_a2_in;
assign spec_reg_f_out = z80fi_reg_f2_in;
assign spec_reg_a2_out = z80fi_reg_a_in;
assign spec_reg_f2_out = z80fi_reg_f_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

endmodule