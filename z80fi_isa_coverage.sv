// DO NOT EDIT -- auto-generated from z80fi_generate.py

`include "z80fi_insn_spec_alu_a_n.sv"
`include "z80fi_insn_spec_cpir.sv"
`include "z80fi_insn_spec_pop_ixiy.sv"
`include "z80fi_insn_spec_ld_r_a.sv"
`include "z80fi_insn_spec_push_qq.sv"
`include "z80fi_insn_spec_exx.sv"
`include "z80fi_insn_spec_ld_ind_nn_dd.sv"
`include "z80fi_insn_spec_ld_reg_n.sv"
`include "z80fi_insn_spec_ld_reg_idx_ixiy.sv"
`include "z80fi_insn_spec_ld_ixiy_ind_nn.sv"
`include "z80fi_insn_spec_alu_a_idx_ixiy.sv"
`include "z80fi_insn_spec_ld_idx_ixiy_reg.sv"
`include "z80fi_insn_spec_ld_a_ind_nn.sv"
`include "z80fi_insn_spec_ld_ind_hl_reg.sv"
`include "z80fi_insn_spec_ld_hl_ind_nn.sv"
`include "z80fi_insn_spec_push_ixiy.sv"
`include "z80fi_insn_spec_cpd.sv"
`include "z80fi_insn_spec_cpdr.sv"
`include "z80fi_insn_spec_ld_a_i.sv"
`include "z80fi_insn_spec_ld_dd_nn.sv"
`include "z80fi_insn_spec_pop_qq.sv"
`include "z80fi_insn_spec_lddr.sv"
`include "z80fi_insn_spec_ld_sp_hl.sv"
`include "z80fi_insn_spec_alu_a_ind_hl.sv"
`include "z80fi_insn_spec_ld_a_r.sv"
`include "z80fi_insn_spec_nop.sv"
`include "z80fi_insn_spec_ld_ind_bcde_a.sv"
`include "z80fi_insn_spec_ld_reg_reg.sv"
`include "z80fi_insn_spec_ld_dd_ind_nn.sv"
`include "z80fi_insn_spec_ex_ind_sp_ixiy.sv"
`include "z80fi_insn_spec_ex_de_hl.sv"
`include "z80fi_insn_spec_ldi.sv"
`include "z80fi_insn_spec_cpi.sv"
`include "z80fi_insn_spec_ld_sp_ixiy.sv"
`include "z80fi_insn_spec_ex_ind_sp_hl.sv"
`include "z80fi_insn_spec_ld_ixiy_nn.sv"
`include "z80fi_insn_spec_ex_af_af2.sv"
`include "z80fi_insn_spec_ldd.sv"
`include "z80fi_insn_spec_ld_ind_hl_n.sv"
`include "z80fi_insn_spec_ld_ind_nn_ixiy.sv"
`include "z80fi_insn_spec_ld_ind_nn_hl.sv"
`include "z80fi_insn_spec_alu_a_reg.sv"
`include "z80fi_insn_spec_ld_idx_ixiy_n.sv"
`include "z80fi_insn_spec_ld_ind_nn_a.sv"
`include "z80fi_insn_spec_ld_i_a.sv"
`include "z80fi_insn_spec_ldir.sv"
`include "z80fi_insn_spec_ld_a_ind_bcde.sv"

module isa_coverage(
    input [31:0] insn,
    input [2:0] insn_len,
    output [46:0] valid
);


z80fi_insn_spec_alu_a_n insn_spec_alu_a_n(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[0])
);


z80fi_insn_spec_cpir insn_spec_cpir(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[1])
);


z80fi_insn_spec_pop_ixiy insn_spec_pop_ixiy(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[2])
);


z80fi_insn_spec_ld_r_a insn_spec_ld_r_a(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[3])
);


z80fi_insn_spec_push_qq insn_spec_push_qq(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[4])
);


z80fi_insn_spec_exx insn_spec_exx(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[5])
);


z80fi_insn_spec_ld_ind_nn_dd insn_spec_ld_ind_nn_dd(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[6])
);


z80fi_insn_spec_ld_reg_n insn_spec_ld_reg_n(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[7])
);


z80fi_insn_spec_ld_reg_idx_ixiy insn_spec_ld_reg_idx_ixiy(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[8])
);


z80fi_insn_spec_ld_ixiy_ind_nn insn_spec_ld_ixiy_ind_nn(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[9])
);


z80fi_insn_spec_alu_a_idx_ixiy insn_spec_alu_a_idx_ixiy(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[10])
);


z80fi_insn_spec_ld_idx_ixiy_reg insn_spec_ld_idx_ixiy_reg(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[11])
);


z80fi_insn_spec_ld_a_ind_nn insn_spec_ld_a_ind_nn(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[12])
);


z80fi_insn_spec_ld_ind_hl_reg insn_spec_ld_ind_hl_reg(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[13])
);


z80fi_insn_spec_ld_hl_ind_nn insn_spec_ld_hl_ind_nn(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[14])
);


z80fi_insn_spec_push_ixiy insn_spec_push_ixiy(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[15])
);


z80fi_insn_spec_cpd insn_spec_cpd(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[16])
);


z80fi_insn_spec_cpdr insn_spec_cpdr(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[17])
);


z80fi_insn_spec_ld_a_i insn_spec_ld_a_i(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[18])
);


z80fi_insn_spec_ld_dd_nn insn_spec_ld_dd_nn(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[19])
);


z80fi_insn_spec_pop_qq insn_spec_pop_qq(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[20])
);


z80fi_insn_spec_lddr insn_spec_lddr(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[21])
);


z80fi_insn_spec_ld_sp_hl insn_spec_ld_sp_hl(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[22])
);


z80fi_insn_spec_alu_a_ind_hl insn_spec_alu_a_ind_hl(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[23])
);


z80fi_insn_spec_ld_a_r insn_spec_ld_a_r(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[24])
);


z80fi_insn_spec_nop insn_spec_nop(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[25])
);


z80fi_insn_spec_ld_ind_bcde_a insn_spec_ld_ind_bcde_a(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[26])
);


z80fi_insn_spec_ld_reg_reg insn_spec_ld_reg_reg(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[27])
);


z80fi_insn_spec_ld_dd_ind_nn insn_spec_ld_dd_ind_nn(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[28])
);


z80fi_insn_spec_ex_ind_sp_ixiy insn_spec_ex_ind_sp_ixiy(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[29])
);


z80fi_insn_spec_ex_de_hl insn_spec_ex_de_hl(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[30])
);


z80fi_insn_spec_ldi insn_spec_ldi(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[31])
);


z80fi_insn_spec_cpi insn_spec_cpi(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[32])
);


z80fi_insn_spec_ld_sp_ixiy insn_spec_ld_sp_ixiy(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[33])
);


z80fi_insn_spec_ex_ind_sp_hl insn_spec_ex_ind_sp_hl(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[34])
);


z80fi_insn_spec_ld_ixiy_nn insn_spec_ld_ixiy_nn(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[35])
);


z80fi_insn_spec_ex_af_af2 insn_spec_ex_af_af2(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[36])
);


z80fi_insn_spec_ldd insn_spec_ldd(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[37])
);


z80fi_insn_spec_ld_ind_hl_n insn_spec_ld_ind_hl_n(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[38])
);


z80fi_insn_spec_ld_ind_nn_ixiy insn_spec_ld_ind_nn_ixiy(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[39])
);


z80fi_insn_spec_ld_ind_nn_hl insn_spec_ld_ind_nn_hl(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[40])
);


z80fi_insn_spec_alu_a_reg insn_spec_alu_a_reg(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[41])
);


z80fi_insn_spec_ld_idx_ixiy_n insn_spec_ld_idx_ixiy_n(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[42])
);


z80fi_insn_spec_ld_ind_nn_a insn_spec_ld_ind_nn_a(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[43])
);


z80fi_insn_spec_ld_i_a insn_spec_ld_i_a(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[44])
);


z80fi_insn_spec_ldir insn_spec_ldir(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[45])
);


z80fi_insn_spec_ld_a_ind_bcde insn_spec_ld_a_ind_bcde(
    .z80fi_valid(1'b1),
    .z80fi_insn(insn),
    .z80fi_insn_len(insn_len),
    .spec_valid(valid[46])
);

endmodule
