// IM 0/1/2
//
// Sets interrupt mode 0, 1, or 2.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_im(
    `Z80FI_INSN_SPEC_IO
);

wire [1:0] mode_code = z80fi_insn[12:11];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b010??110_11101101 &&
    mode_code != 2'b01;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_IM;

assign spec_reg_im_out =
    (mode_code == 2'b00) ? 0 :
    (mode_code == 2'b10) ? 1 : 2;
assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;

endmodule