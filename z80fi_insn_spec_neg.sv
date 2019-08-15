// NEG
//
// Negate A (A <- 0 - A).

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_neg(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b01000100_11101101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_AF;

wire [7:0] result = -z80fi_reg_a_in;

wire flag_s = result[7];
wire flag_z = (result == 0);
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = halfcarry8(0, ~z80fi_reg_a_in, 1'b1);
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = overflow8(0, ~z80fi_reg_a_in, 1'b1);
wire flag_n = 1'b1;
wire flag_c = carry8(0, ~z80fi_reg_a_in, 1'b1);

assign spec_reg_a_out = result;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule