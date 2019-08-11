// ADD/ADC A, n
//
// Adds the immediate byte to A (without or with carry in).

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_add_adc_a_n(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] n           = z80fi_insn[15:8];
wire [3:0] insn_fixed1 = z80fi_insn[7:4];
wire adc               = z80fi_insn[3];
wire [2:0] insn_fixed2 = z80fi_insn[2:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    insn_fixed1 == 4'b1100 &&
    insn_fixed2 == 3'b110;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_AF;

wire carry_in = adc && ((z80fi_reg_f_in & `FLAG_C_BIT) != 0);

wire [7:0] result = z80fi_reg_a_in + n + carry_in;

wire flag_s = result[7];
wire flag_z = (result == 8'b0);
wire flag_5 = (z80fi_reg_f_in & `FLAG_5_BIT) != 0;
wire flag_h = halfcarry8(z80fi_reg_a_in, n, carry_in);
wire flag_3 = (z80fi_reg_f_in & `FLAG_3_BIT) != 0;
wire flag_v = overflow8(z80fi_reg_a_in, n, carry_in);
wire flag_n = 0;
wire flag_c = carry8(z80fi_reg_a_in, n, carry_in);

assign spec_reg_a_out = result;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule