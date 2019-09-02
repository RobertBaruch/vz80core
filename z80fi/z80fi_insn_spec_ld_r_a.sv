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
    z80fi_insn[15:0] == 16'b01001111_11101101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_R;

assign spec_reg_r_out = z80fi_reg_a_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 5;

endmodule