// DO NOT EDIT -- auto-generated from z80fi_generate.py

`include "z80fi_insn_spec_ld_a_r.sv"
`include "z80fi_insn_spec_ld_ixiy_immed.sv"
`include "z80fi_insn_spec_ld_ixiy_reg.sv"
`include "z80fi_insn_spec_ld_dd_immed.sv"
`include "z80fi_insn_spec_ld_a_extaddr.sv"
`include "z80fi_insn_spec_ld_i_a.sv"
`include "z80fi_insn_spec_ld_ixiy_nn.sv"
`include "z80fi_insn_spec_ld_a_bcde.sv"
`include "z80fi_insn_spec_ld_extaddr_hl.sv"
`include "z80fi_insn_spec_ld_hl_reg.sv"
`include "z80fi_insn_spec_ld_extaddr_a.sv"
`include "z80fi_insn_spec_ld_dd_extaddr.sv"
`include "z80fi_insn_spec_ld_extaddr_dd.sv"
`include "z80fi_insn_spec_ld_a_i.sv"
`include "z80fi_insn_spec_ld_hl_extaddr.sv"
`include "z80fi_insn_spec_ld_ixiy_mm.sv"
`include "z80fi_insn_spec_ld_reg_immed.sv"
`include "z80fi_insn_spec_ld_extaddr_ixiy.sv"
`include "z80fi_insn_spec_ld_hl_immed.sv"
`include "z80fi_insn_spec_ld_reg_ixiy.sv"
`include "z80fi_insn_spec_ld_reg_reg.sv"
`include "z80fi_insn_spec_ld_bcde_a.sv"

module isa_coverage(
    input [31:0] insn,
    input [2:0] insn_len,
    output [21:0] valid
);


z80fi_insn_spec_ld_a_r insn_spec_ld_a_r(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[0])
);


z80fi_insn_spec_ld_ixiy_immed insn_spec_ld_ixiy_immed(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[1])
);


z80fi_insn_spec_ld_ixiy_reg insn_spec_ld_ixiy_reg(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[2])
);


z80fi_insn_spec_ld_dd_immed insn_spec_ld_dd_immed(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[3])
);


z80fi_insn_spec_ld_a_extaddr insn_spec_ld_a_extaddr(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[4])
);


z80fi_insn_spec_ld_i_a insn_spec_ld_i_a(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[5])
);


z80fi_insn_spec_ld_ixiy_nn insn_spec_ld_ixiy_nn(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[6])
);


z80fi_insn_spec_ld_a_bcde insn_spec_ld_a_bcde(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[7])
);


z80fi_insn_spec_ld_extaddr_hl insn_spec_ld_extaddr_hl(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[8])
);


z80fi_insn_spec_ld_hl_reg insn_spec_ld_hl_reg(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[9])
);


z80fi_insn_spec_ld_extaddr_a insn_spec_ld_extaddr_a(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[10])
);


z80fi_insn_spec_ld_dd_extaddr insn_spec_ld_dd_extaddr(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[11])
);


z80fi_insn_spec_ld_extaddr_dd insn_spec_ld_extaddr_dd(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[12])
);


z80fi_insn_spec_ld_a_i insn_spec_ld_a_i(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[13])
);


z80fi_insn_spec_ld_hl_extaddr insn_spec_ld_hl_extaddr(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[14])
);


z80fi_insn_spec_ld_ixiy_mm insn_spec_ld_ixiy_mm(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[15])
);


z80fi_insn_spec_ld_reg_immed insn_spec_ld_reg_immed(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[16])
);


z80fi_insn_spec_ld_extaddr_ixiy insn_spec_ld_extaddr_ixiy(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[17])
);


z80fi_insn_spec_ld_hl_immed insn_spec_ld_hl_immed(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[18])
);


z80fi_insn_spec_ld_reg_ixiy insn_spec_ld_reg_ixiy(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[19])
);


z80fi_insn_spec_ld_reg_reg insn_spec_ld_reg_reg(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[20])
);


z80fi_insn_spec_ld_bcde_a insn_spec_ld_bcde_a(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[21])
);

endmodule
