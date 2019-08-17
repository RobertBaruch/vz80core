// INC/DEC dd
//
// Increment or decrement the given register pair.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_inc_dec_dd(
    `Z80FI_INSN_SPEC_IO
);

wire [1:0] dd          = z80fi_insn[5:4];
wire       dec         = z80fi_insn[3];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b00???011;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_BC | `SPEC_REG_DE |
    `SPEC_REG_HL | `SPEC_REG_SP;

wire [15:0] operand = dec ? 16'hFFFF : 16'h1;
wire [15:0] result = (
    (dd == `REG_BC) ? z80fi_reg_bc_in :
    (dd == `REG_DE) ? z80fi_reg_de_in :
    (dd == `REG_HL) ? z80fi_reg_hl_in :
    (dd == `REG_SP) ? z80fi_reg_sp_in : 0) + operand;

assign spec_reg_b_out = (dd == `REG_BC) ? result[15:8] : z80fi_reg_b_in;
assign spec_reg_c_out = (dd == `REG_BC) ? result[7:0] : z80fi_reg_c_in;
assign spec_reg_d_out = (dd == `REG_DE) ? result[15:8] : z80fi_reg_d_in;
assign spec_reg_e_out = (dd == `REG_DE) ? result[7:0] : z80fi_reg_e_in;
assign spec_reg_h_out = (dd == `REG_HL) ? result[15:8] : z80fi_reg_h_in;
assign spec_reg_l_out = (dd == `REG_HL) ? result[7:0] : z80fi_reg_l_in;
assign spec_reg_sp_out = (dd == `REG_SP) ? result : z80fi_reg_sp_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

endmodule