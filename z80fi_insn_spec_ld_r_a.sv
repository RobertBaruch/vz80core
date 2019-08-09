// LD R, A
//
// Copies A into R.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_r_a(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'h4FED;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_R;

assign spec_reg_r_out = z80fi_reg_a_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule