// Covers the LD I, A instruction.
// Copies A into I.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_i_a(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b01000111_11101101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_I;

assign spec_reg_i_out = z80fi_reg_a_in;
assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule