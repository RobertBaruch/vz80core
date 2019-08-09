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
wire [1:0] insn_fixed1 = z80fi_insn[15:14];
wire [2:0] r           = z80fi_insn[13:11];
wire [2:0] insn_fixed2 = z80fi_insn[10:8];
wire [1:0] insn_fixed3 = z80fi_insn[7:6];
wire       iy          = z80fi_insn[5];
wire [4:0] insn_fixed4 = z80fi_insn[4:0];

// LD r, (IX/IY + d) instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    insn_fixed1 == 2'b01 &&
    insn_fixed2 == 3'b110 &&
    insn_fixed3 == 2'b11 &&
    insn_fixed4 == 5'b11101 &&
    r != 6;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_BC | `SPEC_REG_DE |
    `SPEC_REG_HL | `SPEC_REG_A | `SPEC_MEM_RD;

wire [7:0] n = z80fi_mem_rdata;
assign spec_reg_a_out = (r == `REG_A) ? n : z80fi_reg_a_in;
assign spec_reg_b_out = (r == `REG_B) ? n : z80fi_reg_b_in;
assign spec_reg_c_out = (r == `REG_C) ? n : z80fi_reg_c_in;
assign spec_reg_d_out = (r == `REG_D) ? n : z80fi_reg_d_in;
assign spec_reg_e_out = (r == `REG_E) ? n : z80fi_reg_e_in;
assign spec_reg_h_out = (r == `REG_H) ? n : z80fi_reg_h_in;
assign spec_reg_l_out = (r == `REG_L) ? n : z80fi_reg_l_in;

assign spec_mem_raddr = (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) + d;

assign spec_reg_ip_out = z80fi_reg_ip_in + 3;

endmodule