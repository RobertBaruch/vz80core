// LD r, n
//
// This must write n to 8-bit register r.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_reg_n(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] n            = z80fi_insn[15:8];
wire [2:0] r            = z80fi_insn[5:3];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[7:0] == 8'b00???110 &&
    r != 6;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_A | `SPEC_REG_B |
    `SPEC_REG_C | `SPEC_REG_D | `SPEC_REG_E | `SPEC_REG_H | `SPEC_REG_L;

// Registers out
assign spec_reg_a_out = (r == `REG_A) ? n : z80fi_reg_a_in;
assign spec_reg_b_out = (r == `REG_B) ? n : z80fi_reg_b_in;
assign spec_reg_c_out = (r == `REG_C) ? n : z80fi_reg_c_in;
assign spec_reg_d_out = (r == `REG_D) ? n : z80fi_reg_d_in;
assign spec_reg_e_out = (r == `REG_E) ? n : z80fi_reg_e_in;
assign spec_reg_h_out = (r == `REG_H) ? n : z80fi_reg_h_in;
assign spec_reg_l_out = (r == `REG_L) ? n : z80fi_reg_l_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_tcycles1 = 4;
assign spec_mcycle_type2 = `CYCLE_RDWR_MEM;
assign spec_tcycles2 = 3;
assign spec_mcycle_type3 = `CYCLE_NONE;

endmodule