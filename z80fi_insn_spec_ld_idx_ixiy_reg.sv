// LD (IX/IY + d), r
//
// This must write the contents of the memory address at IX + d
// with the contents of register r. d is sign-extended to 16 bits.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_idx_ixiy_reg(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] d           = { {8{z80fi_insn[23]}}, z80fi_insn[23:16]};
wire [2:0] r           = z80fi_insn[10:8];
wire       iy          = z80fi_insn[5];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    z80fi_insn[15:0] == 16'b01110???_11?11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_MEM_WR;

assign spec_mem_waddr = (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) + d;
assign spec_mem_wdata =
    (r == `REG_A) ? z80fi_reg_a_in :
    (r == `REG_B) ? z80fi_reg_b_in :
    (r == `REG_C) ? z80fi_reg_c_in :
    (r == `REG_D) ? z80fi_reg_d_in :
    (r == `REG_E) ? z80fi_reg_e_in :
    (r == `REG_H) ? z80fi_reg_h_in :
    (r == `REG_L) ? z80fi_reg_l_in : 0;

assign spec_reg_ip_out = z80fi_reg_ip_in + 3;

endmodule