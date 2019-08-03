// Covers the LD A, I and LD I, A instructions.
// The first copies I into A, and the second copies
// A into I.

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_ai_ia(
    `Z80FI_INSN_SPEC_IO
);

wire [1:0] insn_fixed = z80fi_insn[7:6];
wire [2:0] insn_rreg = z80fi_insn[2:0];
wire [2:0] insn_wreg = z80fi_insn[5:3];

// LD r, r' instruction
assign spec_valid = z80fi_valid && 
    z80fi_insn_len == 1 && 
    insn_fixed == 2'b01 && 
    insn_rreg != 3'b110 && 
    insn_wreg != 3'b110;

// Once spec_valid, what is supposed to happen?
assign spec_reg1_rd = 1;
assign spec_reg2_rd = 0;
assign spec_reg_wr = 1;
assign spec_mem_rd = 0;
assign spec_mem_rd2 = 0;
assign spec_mem_wr = 0;
assign spec_mem_wr2 = 0;
assign spec_i_rd = 0;
assign spec_i_wr = 0;
assign spec_r_rd = 0;
assign spec_r_wr = 0;
assign spec_f_rd = 0;
assign spec_f_wr = 0;

// Data for 1's above.
assign spec_reg1_rnum = insn_rreg;

assign spec_reg_wnum = insn_wreg;
assign spec_reg_wdata = {8'b0, z80fi_reg1_rdata[7:0]};

assign spec_pc_wdata = z80fi_pc_rdata + 1;

endmodule