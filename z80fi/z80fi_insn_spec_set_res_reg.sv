// SET/RES b, r
//
// Sets/resets bit b of register r.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_set_res_reg(
    `Z80FI_INSN_SPEC_IO
);

wire       set         = z80fi_insn[14];
wire [2:0] b           = z80fi_insn[13:11];
wire [2:0] r           = z80fi_insn[10:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b1???????_11001011 &&
    r != 6;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_A | `SPEC_REG_BC |
    `SPEC_REG_DE | `SPEC_REG_HL;

wire [7:0] rdata =
    (r == `REG_A) ? z80fi_reg_a_in :
    (r == `REG_B) ? z80fi_reg_b_in :
    (r == `REG_C) ? z80fi_reg_c_in :
    (r == `REG_D) ? z80fi_reg_d_in :
    (r == `REG_E) ? z80fi_reg_e_in :
    (r == `REG_H) ? z80fi_reg_h_in :
    (r == `REG_L) ? z80fi_reg_l_in : 0;

wire [7:0] wdata = set ? (rdata | (8'b1 << b)) : (rdata & ~(8'b1 << b));

assign spec_reg_a_out = (r == `REG_A) ? wdata : z80fi_reg_a_in;
assign spec_reg_b_out = (r == `REG_B) ? wdata : z80fi_reg_b_in;
assign spec_reg_c_out = (r == `REG_C) ? wdata : z80fi_reg_c_in;
assign spec_reg_d_out = (r == `REG_D) ? wdata : z80fi_reg_d_in;
assign spec_reg_e_out = (r == `REG_E) ? wdata : z80fi_reg_e_in;
assign spec_reg_h_out = (r == `REG_H) ? wdata : z80fi_reg_h_in;
assign spec_reg_l_out = (r == `REG_L) ? wdata : z80fi_reg_l_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;

endmodule