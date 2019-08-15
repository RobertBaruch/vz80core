// ADC/SBC HL, dd
//
// Adds/subtracts the register pair dd to HL, with carry in.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_adc_sbc_hl_dd(
    `Z80FI_INSN_SPEC_IO
);

wire [1:0] dd          = z80fi_insn[13:12];
wire       add         = z80fi_insn[11];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b01???010_11101101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_HL | `SPEC_REG_F;

wire [15:0] operand =
    (dd == `REG_BC) ? z80fi_reg_bc_in :
    (dd == `REG_DE) ? z80fi_reg_de_in :
    (dd == `REG_HL) ? z80fi_reg_hl_in :
    (dd == `REG_SP) ? z80fi_reg_sp_in : 0;

wire [15:0] result = add ? (z80fi_reg_hl_in + operand + carry_in) : (z80fi_reg_hl_in - operand - carry_in);
wire carry_in = z80fi_reg_f_in[`FLAG_C_NUM];

wire flag_s = result[15];
wire flag_z = (result == 0);
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = halfcarry16(z80fi_reg_hl_in, add ? operand : ~operand, add ? carry_in : ~carry_in);
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = overflow16(z80fi_reg_hl_in, add ? operand : ~operand, add ? carry_in : ~carry_in);
wire flag_n = ~add;
wire flag_c = carry16(z80fi_reg_hl_in, add ? operand : ~operand, add ? carry_in : ~carry_in);

assign spec_reg_h_out = result[15:8];
assign spec_reg_l_out = result[7:0];
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule