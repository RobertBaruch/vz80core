// INC/DEC r
//
// Increment or decrement the given register.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_inc_dec_reg(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] r           = z80fi_insn[5:3];
wire       dec         = z80fi_insn[0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b00???10? &&
    r != 6;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_AF | `SPEC_REG_BC |
    `SPEC_REG_DE | `SPEC_REG_HL;

wire [7:0] operand =
    (r == `REG_A) ? z80fi_reg_a_in :
    (r == `REG_B) ? z80fi_reg_b_in :
    (r == `REG_C) ? z80fi_reg_c_in :
    (r == `REG_D) ? z80fi_reg_d_in :
    (r == `REG_E) ? z80fi_reg_e_in :
    (r == `REG_H) ? z80fi_reg_h_in :
    (r == `REG_L) ? z80fi_reg_l_in : 0;

wire [7:0] result = dec ? (operand - 8'b1) : (operand + 8'b1);

wire flag_s = result[7];
wire flag_z = (result == 8'b0);
wire flag_5 = (z80fi_reg_f_in & `FLAG_5_BIT) != 0;
wire flag_h = halfcarry8(operand, dec ? ~8'b1 : 8'b1, dec);
wire flag_3 = (z80fi_reg_f_in & `FLAG_3_BIT) != 0;
wire flag_v = overflow8(operand, dec ? ~8'b1 : 8'b1, dec);
wire flag_n = dec;
wire flag_c = (z80fi_reg_f_in & `FLAG_C_BIT) != 0;

assign spec_reg_a_out = (r == `REG_A) ? result : z80fi_reg_a_in;
assign spec_reg_b_out = (r == `REG_B) ? result : z80fi_reg_b_in;
assign spec_reg_c_out = (r == `REG_C) ? result : z80fi_reg_c_in;
assign spec_reg_d_out = (r == `REG_D) ? result : z80fi_reg_d_in;
assign spec_reg_e_out = (r == `REG_E) ? result : z80fi_reg_e_in;
assign spec_reg_h_out = (r == `REG_H) ? result : z80fi_reg_h_in;
assign spec_reg_l_out = (r == `REG_L) ? result : z80fi_reg_l_in;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_NONE;

assign spec_tcycles1 = 4;

endmodule