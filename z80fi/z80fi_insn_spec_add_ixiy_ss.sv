// ADD IX/IY, ss
//
// Adds the register pair ss to IX/IY. Note that only H and C are
// set according to the result flags. ss is like dd, except instead
// of HL, use IX for ADD IX and IY for ADD IY.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_add_ixiy_ss(
    `Z80FI_INSN_SPEC_IO
);

wire [1:0] ss          = z80fi_insn[13:12];
wire       iy          = z80fi_insn[5];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b00??1001_11?11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_IX | `SPEC_REG_IY | `SPEC_REG_F;

wire [15:0] operand1 = iy ? z80fi_reg_iy_in : z80fi_reg_ix_in;
wire [15:0] operand2 =
    (ss == `REG_BC) ? z80fi_reg_bc_in :
    (ss == `REG_DE) ? z80fi_reg_de_in :
    (ss == `REG_HL) ? (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) :
    (ss == `REG_SP) ? z80fi_reg_sp_in : 0;

wire [15:0] result = operand1 + operand2;

wire flag_s = z80fi_reg_f_in[`FLAG_S_NUM];
wire flag_z = z80fi_reg_f_in[`FLAG_Z_NUM];
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = halfcarry16(operand1, operand2, 1'b0);
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = z80fi_reg_f_in[`FLAG_PV_NUM];
wire flag_n = 1'b0;
wire flag_c = carry16(operand1, operand2, 1'b0);

assign spec_reg_ix_out = iy ? z80fi_reg_ix_in : result;
assign spec_reg_iy_out = iy ? result : z80fi_reg_iy_in;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_INTERNAL;
assign spec_mcycle_type4 = `CYCLE_INTERNAL;
assign spec_mcycle_type5 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;
assign spec_tcycles3 = 4;
assign spec_tcycles4 = 3;

endmodule