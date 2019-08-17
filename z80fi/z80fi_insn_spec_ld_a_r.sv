// Covers the LD A, R instruction.
// Copies R into A, with some flags set.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_a_r(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b01011111_11101101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_A | `SPEC_REG_F;

assign spec_reg_a_out = z80fi_reg_r_in;
assign spec_reg_f_out =
    (z80fi_reg_f_in & (`FLAG_5_BIT | `FLAG_3_BIT | `FLAG_C_BIT)) |
    (z80fi_reg_r_in[7] ? `FLAG_S_BIT : 0) |
    (z80fi_reg_r_in == 0 ? `FLAG_Z_BIT : 0) |
    (z80fi_reg_iff2_in == 1 ? `FLAG_PV_BIT : 0);

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule