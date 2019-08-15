// RLC / RL / RRC / RR r
//
// Rotates the given register left/right.
//
// If rotating through carry, these are effectively nine-bit rotates.
// If not rotating through carry, the bit that falls off the end
// of the register is put into the carry flag.
//
// Interestingly, RL/RR are the instructions that rotate through
// carry, not RL/RRC.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_rr_rlc_reg(
    `Z80FI_INSN_SPEC_IO
);

wire       through_c   = z80fi_insn[12];
wire       right       = z80fi_insn[11];
wire [2:0] r           = z80fi_insn[10:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b000?????_11001011 &&
    r != 6;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_AF | `SPEC_REG_BC |
    `SPEC_REG_DE | `SPEC_REG_HL;

wire [7:0] rdata =
    (r == `REG_A) ? z80fi_reg_a_in :
    (r == `REG_B) ? z80fi_reg_b_in :
    (r == `REG_C) ? z80fi_reg_c_in :
    (r == `REG_D) ? z80fi_reg_d_in :
    (r == `REG_E) ? z80fi_reg_e_in :
    (r == `REG_H) ? z80fi_reg_h_in :
    (r == `REG_L) ? z80fi_reg_l_in : 0;

// This is the bit that gets shoved into the register from the right or left.
// If we're rotating through carry, it's the carry bit. Otherwise
// it's the rightmost or leftmost bit of register.
wire shove_bit =
    through_c ? z80fi_reg_f_in[`FLAG_C_NUM] : rdata[right ? 0 : 7];
wire [7:0] wdata =
    right ? {shove_bit, rdata[7:1]} : {rdata[6:0], shove_bit};

wire flag_s = wdata[7];
wire flag_z = (wdata == 0);
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = 0;
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = parity8(wdata);
wire flag_n = 0;
wire flag_c = rdata[right ? 0 : 7];

assign spec_reg_a_out = (r == `REG_A) ? wdata : z80fi_reg_a_in;
assign spec_reg_b_out = (r == `REG_B) ? wdata : z80fi_reg_b_in;
assign spec_reg_c_out = (r == `REG_C) ? wdata : z80fi_reg_c_in;
assign spec_reg_d_out = (r == `REG_D) ? wdata : z80fi_reg_d_in;
assign spec_reg_e_out = (r == `REG_E) ? wdata : z80fi_reg_e_in;
assign spec_reg_h_out = (r == `REG_H) ? wdata : z80fi_reg_h_in;
assign spec_reg_l_out = (r == `REG_L) ? wdata : z80fi_reg_l_in;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule