// DO NOT EDIT -- auto-generated from z80fi_generate.py

`include "z80fi_insn_spec_ld_hl_reg.sv"
`include "z80fi_insn_spec_ld_dd_extaddr.sv"
`include "z80fi_insn_spec_ld_bcde_a.sv"
`include "z80fi_insn_spec_ld_a_extaddr.sv"
`include "z80fi_insn_spec_ld_reg_immed.sv"
`include "z80fi_insn_spec_ld_extaddr_a.sv"
`include "z80fi_insn_spec_ld_dd_immed.sv"
`include "z80fi_insn_spec_ld_hl_immed.sv"
`include "z80fi_insn_spec_ld_reg_ixiy.sv"
`include "z80fi_insn_spec_ld_reg_reg.sv"

module isa_coverage(
    input [31:0] insn,
    input [2:0] insn_len,
    output [9:0] valid
);


z80fi_insn_spec_ld_hl_reg insn_spec_ld_hl_reg(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .z80fi_pc_rdata(16'h0000),
    .z80fi_reg1_rdata(16'h0000),
    .z80fi_reg2_rdata(16'h0000),
    .spec_valid(valid[0])
);


z80fi_insn_spec_ld_dd_extaddr insn_spec_ld_dd_extaddr(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .z80fi_pc_rdata(16'h0000),
    .z80fi_reg1_rdata(16'h0000),
    .z80fi_reg2_rdata(16'h0000),
    .spec_valid(valid[1])
);


z80fi_insn_spec_ld_bcde_a insn_spec_ld_bcde_a(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .z80fi_pc_rdata(16'h0000),
    .z80fi_reg1_rdata(16'h0000),
    .z80fi_reg2_rdata(16'h0000),
    .spec_valid(valid[2])
);


z80fi_insn_spec_ld_a_extaddr insn_spec_ld_a_extaddr(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .z80fi_pc_rdata(16'h0000),
    .z80fi_reg1_rdata(16'h0000),
    .z80fi_reg2_rdata(16'h0000),
    .spec_valid(valid[3])
);


z80fi_insn_spec_ld_reg_immed insn_spec_ld_reg_immed(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .z80fi_pc_rdata(16'h0000),
    .z80fi_reg1_rdata(16'h0000),
    .z80fi_reg2_rdata(16'h0000),
    .spec_valid(valid[4])
);


z80fi_insn_spec_ld_extaddr_a insn_spec_ld_extaddr_a(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .z80fi_pc_rdata(16'h0000),
    .z80fi_reg1_rdata(16'h0000),
    .z80fi_reg2_rdata(16'h0000),
    .spec_valid(valid[5])
);


z80fi_insn_spec_ld_dd_immed insn_spec_ld_dd_immed(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .z80fi_pc_rdata(16'h0000),
    .z80fi_reg1_rdata(16'h0000),
    .z80fi_reg2_rdata(16'h0000),
    .spec_valid(valid[6])
);


z80fi_insn_spec_ld_hl_immed insn_spec_ld_hl_immed(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .z80fi_pc_rdata(16'h0000),
    .z80fi_reg1_rdata(16'h0000),
    .z80fi_reg2_rdata(16'h0000),
    .spec_valid(valid[7])
);


z80fi_insn_spec_ld_reg_ixiy insn_spec_ld_reg_ixiy(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .z80fi_pc_rdata(16'h0000),
    .z80fi_reg1_rdata(16'h0000),
    .z80fi_reg2_rdata(16'h0000),
    .spec_valid(valid[8])
);


z80fi_insn_spec_ld_reg_reg insn_spec_ld_reg_reg(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .z80fi_pc_rdata(16'h0000),
    .z80fi_reg1_rdata(16'h0000),
    .z80fi_reg2_rdata(16'h0000),
    .spec_valid(valid[9])
);

endmodule
