// Covers the LD A, I instruction.
// Copies I into A, with some flags set.

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_a_i(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid && 
    z80fi_insn_len == 2 && 
    z80fi_insn[15:0] == 16'h57ED;

// Once spec_valid, what is supposed to happen?
assign spec_reg1_rd = 0;
assign spec_reg2_rd = 0;
assign spec_reg_wr = 1;
assign spec_mem_rd = 0;
assign spec_mem_rd2 = 0;
assign spec_mem_wr = 0;
assign spec_mem_wr2 = 0;
assign spec_i_rd = 1;
assign spec_i_wr = 0;
assign spec_r_rd = 0;
assign spec_r_wr = 0;
assign spec_f_rd = 1;
assign spec_f_wr = 1;

// Data for 1's above.
assign spec_reg_wnum = `REG_A;
assign spec_reg_wdata = z80fi_i_rdata;

assign spec_f_wdata = 
    (z80fi_f_rdata & (`FLAG_5_BIT | `FLAG_3_BIT | `FLAG_C_BIT)) |
    (z80fi_i_rdata[7] ? `FLAG_S_BIT : 0) |
    (z80fi_i_rdata == 0 ? `FLAG_Z_BIT : 0) |
    (0); // TODO: IFF2 flag

assign spec_pc_wdata = z80fi_pc_rdata + 2;

endmodule