// ADD HL, dd
//
// Adds the register pair dd to HL. Note that only H and C are
// set according to the result flags.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_add_hl_dd(
    `Z80FI_INSN_SPEC_IO
);

wire [1:0] insn_fixed1 = z80fi_insn[7:6];
wire [1:0] dd          = z80fi_insn[5:4];
wire [3:0] insn_fixed2 = z80fi_insn[3:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    insn_fixed1 == 2'b00 &&
    insn_fixed2 == 4'b1001;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_HL | `SPEC_REG_F;

wire [15:0] operand =
    (dd == `REG_BC) ? z80fi_reg_bc_in :
    (dd == `REG_DE) ? z80fi_reg_de_in :
    (dd == `REG_HL) ? z80fi_reg_hl_in :
    (dd == `REG_SP) ? z80fi_reg_sp_in : 0;

wire [15:0] result = z80fi_reg_hl_in + operand;

wire flag_s = z80fi_reg_f_in[`FLAG_S_NUM];
wire flag_z = z80fi_reg_f_in[`FLAG_Z_NUM];
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = halfcarry16(z80fi_reg_hl_in, operand, 1'b0);
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = z80fi_reg_f_in[`FLAG_PV_NUM];
wire flag_n = 1'b0;
wire flag_c = carry16(z80fi_reg_hl_in, operand, 1'b0);

assign spec_reg_h_out = result[15:8];
assign spec_reg_l_out = result[7:0];
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

endmodule