// RLCA / RLA / RRCA / RRA
//
// Rotates the accumulator left/right.
//
// If rotating through carry, these are effectively nine-bit rotates.
// If not rotating through carry, the bit that falls off the end
// of A is put into the carry flag.
//
// Interestingly, RL/RRA are the instructions that rotate through
// carry, not RL/RRCA.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_rr_rlca(
    `Z80FI_INSN_SPEC_IO
);

wire       through_c   = z80fi_insn[4];
wire       right       = z80fi_insn[3];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b000??111;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_A | `SPEC_REG_F;

wire flag_s = z80fi_reg_f_in[`FLAG_S_NUM];
wire flag_z = z80fi_reg_f_in[`FLAG_Z_NUM];
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = 0;
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = z80fi_reg_f_in[`FLAG_PV_NUM];
wire flag_n = 0;
wire flag_c = z80fi_reg_a_in[right ? 0 : 7];

// This is the bit that gets shoved into A from the right or left.
// If we're rotating through carry, it's the carry bit. Otherwise
// it's the rightmost or leftmost bit of A.
wire shove_bit = through_c ?
    z80fi_reg_f_in[`FLAG_C_NUM] : z80fi_reg_a_in[right ? 0 : 7];

assign spec_reg_a_out = right ?
    {shove_bit, z80fi_reg_a_in[7:1]} : {z80fi_reg_a_in[6:0], shove_bit};
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

endmodule