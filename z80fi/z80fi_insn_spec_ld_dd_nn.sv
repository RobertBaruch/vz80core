// LD dd, nn
//
// This must write nn to 16-bit register pair dd. nn is ordered
// little-endian.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_dd_nn(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] nn          = z80fi_insn[23:8];
wire [1:0]  dd          = z80fi_insn[5:4];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    z80fi_insn[7:0] == 8'b00??0001;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP |
    `SPEC_REG_BC | `SPEC_REG_DE | `SPEC_REG_HL | `SPEC_REG_SP;

assign spec_reg_b_out = (dd == `REG_BC) ? nn[15:8] : z80fi_reg_b_in;
assign spec_reg_c_out = (dd == `REG_BC) ? nn[7:0] : z80fi_reg_c_in;
assign spec_reg_d_out = (dd == `REG_DE) ? nn[15:8] : z80fi_reg_d_in;
assign spec_reg_e_out = (dd == `REG_DE) ? nn[7:0] : z80fi_reg_e_in;
assign spec_reg_h_out = (dd == `REG_HL) ? nn[15:8] : z80fi_reg_h_in;
assign spec_reg_l_out = (dd == `REG_HL) ? nn[7:0] : z80fi_reg_l_in;
assign spec_reg_sp_out = (dd == `REG_SP) ? nn : z80fi_reg_sp_in;
assign spec_reg_ip_out = z80fi_reg_ip_in + 3;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 3;
assign spec_tcycles3 = 3;

endmodule