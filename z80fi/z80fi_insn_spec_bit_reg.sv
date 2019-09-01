// BIT b, r
//
// Sets the Z flag if bit b of register r is zero.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_bit_reg(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] b           = z80fi_insn[13:11];
wire [2:0] r           = z80fi_insn[10:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b01??????_11001011 &&
    r != 6;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_F;

wire [7:0] rdata =
    (r == `REG_A) ? z80fi_reg_a_in :
    (r == `REG_B) ? z80fi_reg_b_in :
    (r == `REG_C) ? z80fi_reg_c_in :
    (r == `REG_D) ? z80fi_reg_d_in :
    (r == `REG_E) ? z80fi_reg_e_in :
    (r == `REG_H) ? z80fi_reg_h_in :
    (r == `REG_L) ? z80fi_reg_l_in : 0;

// Undocumented value of S flag:
// Set if bit = 7 and bit 7 in r is set.
wire flag_s = b == 7 && rdata[7] == 1;
wire flag_z = rdata[b] == 0;
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = 1;
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = rdata[b] == 0;
wire flag_n = 0;
wire flag_c = z80fi_reg_f_in[`FLAG_C_NUM];

assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;

endmodule