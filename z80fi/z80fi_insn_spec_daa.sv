// DAA
//
// Decimal adjusts register A.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_daa(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b00100111;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_AF;

wire [7:0] daa_adjust;
assign daa_adjust =
  ((z80fi_reg_f_in[`FLAG_H_NUM] || (z80fi_reg_a_in[3:0] > 4'h9)) ? 8'h06 : 0) +
  ((z80fi_reg_f_in[`FLAG_C_NUM] || (z80fi_reg_a_in[7:4] > 4'h9)) ? 8'h60 : 0);
wire is_sub = z80fi_reg_f_in[`FLAG_N_NUM];
wire [7:0] result = is_sub ?
    (z80fi_reg_a_in - daa_adjust) :
    (z80fi_reg_a_in + daa_adjust);

wire flag_s = result[7];
wire flag_z = (result == 8'b0);
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = halfcarry8(z80fi_reg_a_in, is_sub ? ~daa_adjust : daa_adjust, is_sub);
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = parity8(result);
wire flag_n = is_sub;
wire flag_c = carry8(z80fi_reg_a_in, is_sub ? ~daa_adjust : daa_adjust, is_sub);

assign spec_reg_a_out = result;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_NONE;

assign spec_tcycles1 = 4;

endmodule