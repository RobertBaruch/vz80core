// LD r, (IX/IY + d)
//
// This must write the contents of the memory address at IX + d
// to register r.  d is sign-extended to 16 bits.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_reg_idx_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] d           = { {8{z80fi_insn[23]}}, z80fi_insn[23:16]};
wire [2:0] r           = z80fi_insn[13:11];
wire       iy          = z80fi_insn[5];

// LD r, (IX/IY + d) instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    z80fi_insn[15:0] == 16'b01???110_11?11101 &&
    r != 6;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_BC | `SPEC_REG_DE |
    `SPEC_REG_HL | `SPEC_REG_A | `SPEC_MEM_RD;

wire [7:0] n = z80fi_bus_rdata;
assign spec_reg_a_out = (r == `REG_A) ? n : z80fi_reg_a_in;
assign spec_reg_b_out = (r == `REG_B) ? n : z80fi_reg_b_in;
assign spec_reg_c_out = (r == `REG_C) ? n : z80fi_reg_c_in;
assign spec_reg_d_out = (r == `REG_D) ? n : z80fi_reg_d_in;
assign spec_reg_e_out = (r == `REG_E) ? n : z80fi_reg_e_in;
assign spec_reg_h_out = (r == `REG_H) ? n : z80fi_reg_h_in;
assign spec_reg_l_out = (r == `REG_L) ? n : z80fi_reg_l_in;

assign spec_bus_raddr = (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) + d;

assign spec_reg_ip_out = z80fi_reg_ip_in + 3;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_INTERNAL;
assign spec_mcycle_type5 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type6 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;
assign spec_tcycles3 = 3;
assign spec_tcycles4 = 5;
assign spec_tcycles5 = 3;

endmodule