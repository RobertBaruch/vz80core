// Covers the LD I, A instruction.
// Copies A into I.

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_i_a(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid && 
    z80fi_insn_len == 2 && 
    z80fi_insn[15:0] == 16'h47ED;

// Once spec_valid, what is supposed to happen?
assign spec_reg1_rd = 1;
assign spec_reg2_rd = 0;
assign spec_reg_wr = 0;
assign spec_mem_rd = 0;
assign spec_mem_rd2 = 0;
assign spec_mem_wr = 0;
assign spec_mem_wr2 = 0;
assign spec_i_rd = 0;
assign spec_i_wr = 1;
assign spec_r_rd = 0;
assign spec_r_wr = 0;
assign spec_f_rd = 0;
assign spec_f_wr = 0;

// Data for 1's above.
assign spec_reg1_rnum = `REG_A;

assign spec_i_wdata = z80fi_reg1_rdata[7:0];

assign spec_pc_wdata = z80fi_pc_rdata + 2;

endmodule