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
    z80fi_insn[15:0] == 16'h5FED;

`Z80FI_SPEC_SIGNALS
assign spec_signals =
    `SPEC_REG_WR | `SPEC_R_RD | `SPEC_F_RD | `SPEC_F_WR | `SPEC_IFF2_RD;

// Data for 1's above.
assign spec_reg_wnum = `REG_A;
assign spec_reg_wdata = z80fi_r_rdata;

assign spec_f_wdata =
    (z80fi_f_rdata & (`FLAG_5_BIT | `FLAG_3_BIT | `FLAG_C_BIT)) |
    (z80fi_r_rdata[7] ? `FLAG_S_BIT : 0) |
    (z80fi_r_rdata == 0 ? `FLAG_Z_BIT : 0) |
    (z80fi_iff2_rdata == 1 ? `FLAG_PV_BIT : 0);

assign spec_pc_wdata = z80fi_pc_rdata + 2;

endmodule