// LD r, (HL)
//
// This must write the byte in the memory address stored in HL
// to the given register.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_reg_ind_hl(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] r           = z80fi_insn[5:3];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b01???110 &&
    r != 6;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_MEM_RD | `SPEC_REG_A |
    `SPEC_REG_BC | `SPEC_REG_DE | `SPEC_REG_HL;

assign spec_bus_raddr = z80fi_reg_hl_in;
assign spec_reg_a_out = (r == `REG_A) ? z80fi_bus_rdata : z80fi_reg_a_in;
assign spec_reg_b_out = (r == `REG_B) ? z80fi_bus_rdata : z80fi_reg_b_in;
assign spec_reg_c_out = (r == `REG_C) ? z80fi_bus_rdata : z80fi_reg_c_in;
assign spec_reg_d_out = (r == `REG_D) ? z80fi_bus_rdata : z80fi_reg_d_in;
assign spec_reg_e_out = (r == `REG_E) ? z80fi_bus_rdata : z80fi_reg_e_in;
assign spec_reg_h_out = (r == `REG_H) ? z80fi_bus_rdata : z80fi_reg_h_in;
assign spec_reg_l_out = (r == `REG_L) ? z80fi_bus_rdata : z80fi_reg_l_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type3 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 3;

endmodule