// DO NOT EDIT -- auto-generated from z80fi_generate.py

`define Z80FI_INPUTS \
input [0:0] z80fi_valid, \
input [31:0] z80fi_insn, \
input [2:0] z80fi_insn_len, \
input [15:0] z80fi_pc_rdata, \
input [15:0] z80fi_pc_wdata, \
input [0:0] z80fi_reg1_rd, \
input [3:0] z80fi_reg1_rnum, \
input [3:0] z80fi_reg2_rnum, \
input [15:0] z80fi_reg1_rdata, \
input [0:0] z80fi_reg2_rd, \
input [15:0] z80fi_reg2_rdata, \
input [0:0] z80fi_reg_wr, \
input [3:0] z80fi_reg_wnum, \
input [15:0] z80fi_reg_wdata, \
input [0:0] z80fi_mem_rd, \
input [15:0] z80fi_mem_raddr, \
input [7:0] z80fi_mem_rdata, \
input [0:0] z80fi_mem_rd2, \
input [15:0] z80fi_mem_raddr2, \
input [7:0] z80fi_mem_rdata2, \
input [0:0] z80fi_mem_wr, \
input [15:0] z80fi_mem_waddr, \
input [7:0] z80fi_mem_wdata, \
input [0:0] z80fi_mem_wr2, \
input [15:0] z80fi_mem_waddr2, \
input [7:0] z80fi_mem_wdata2, \
input [0:0] z80fi_i_rd, \
input [0:0] z80fi_i_wr, \
input [7:0] z80fi_i_rdata, \
input [7:0] z80fi_i_wdata, \
input [0:0] z80fi_r_rd, \
input [0:0] z80fi_r_wr, \
input [7:0] z80fi_r_rdata, \
input [7:0] z80fi_r_wdata, \
input [0:0] z80fi_f_rd, \
input [0:0] z80fi_f_wr, \
input [7:0] z80fi_f_rdata, \
input [7:0] z80fi_f_wdata, \
input [0:0] z80fi_iff1_rd, \
input [0:0] z80fi_iff1_rdata, \
input [0:0] z80fi_iff2_rd, \
input [0:0] z80fi_iff2_rdata

`define Z80FI_OUTPUTS \
output logic [0:0] z80fi_valid, \
output logic [31:0] z80fi_insn, \
output logic [2:0] z80fi_insn_len, \
output logic [15:0] z80fi_pc_rdata, \
output logic [15:0] z80fi_pc_wdata, \
output logic [0:0] z80fi_reg1_rd, \
output logic [3:0] z80fi_reg1_rnum, \
output logic [3:0] z80fi_reg2_rnum, \
output logic [15:0] z80fi_reg1_rdata, \
output logic [0:0] z80fi_reg2_rd, \
output logic [15:0] z80fi_reg2_rdata, \
output logic [0:0] z80fi_reg_wr, \
output logic [3:0] z80fi_reg_wnum, \
output logic [15:0] z80fi_reg_wdata, \
output logic [0:0] z80fi_mem_rd, \
output logic [15:0] z80fi_mem_raddr, \
output logic [7:0] z80fi_mem_rdata, \
output logic [0:0] z80fi_mem_rd2, \
output logic [15:0] z80fi_mem_raddr2, \
output logic [7:0] z80fi_mem_rdata2, \
output logic [0:0] z80fi_mem_wr, \
output logic [15:0] z80fi_mem_waddr, \
output logic [7:0] z80fi_mem_wdata, \
output logic [0:0] z80fi_mem_wr2, \
output logic [15:0] z80fi_mem_waddr2, \
output logic [7:0] z80fi_mem_wdata2, \
output logic [0:0] z80fi_i_rd, \
output logic [0:0] z80fi_i_wr, \
output logic [7:0] z80fi_i_rdata, \
output logic [7:0] z80fi_i_wdata, \
output logic [0:0] z80fi_r_rd, \
output logic [0:0] z80fi_r_wr, \
output logic [7:0] z80fi_r_rdata, \
output logic [7:0] z80fi_r_wdata, \
output logic [0:0] z80fi_f_rd, \
output logic [0:0] z80fi_f_wr, \
output logic [7:0] z80fi_f_rdata, \
output logic [7:0] z80fi_f_wdata, \
output logic [0:0] z80fi_iff1_rd, \
output logic [0:0] z80fi_iff1_rdata, \
output logic [0:0] z80fi_iff2_rd, \
output logic [0:0] z80fi_iff2_rdata

`define Z80FI_WIRES \
logic [0:0] z80fi_valid; \
logic [31:0] z80fi_insn; \
logic [2:0] z80fi_insn_len; \
logic [15:0] z80fi_pc_rdata; \
logic [15:0] z80fi_pc_wdata; \
logic [0:0] z80fi_reg1_rd; \
logic [3:0] z80fi_reg1_rnum; \
logic [3:0] z80fi_reg2_rnum; \
logic [15:0] z80fi_reg1_rdata; \
logic [0:0] z80fi_reg2_rd; \
logic [15:0] z80fi_reg2_rdata; \
logic [0:0] z80fi_reg_wr; \
logic [3:0] z80fi_reg_wnum; \
logic [15:0] z80fi_reg_wdata; \
logic [0:0] z80fi_mem_rd; \
logic [15:0] z80fi_mem_raddr; \
logic [7:0] z80fi_mem_rdata; \
logic [0:0] z80fi_mem_rd2; \
logic [15:0] z80fi_mem_raddr2; \
logic [7:0] z80fi_mem_rdata2; \
logic [0:0] z80fi_mem_wr; \
logic [15:0] z80fi_mem_waddr; \
logic [7:0] z80fi_mem_wdata; \
logic [0:0] z80fi_mem_wr2; \
logic [15:0] z80fi_mem_waddr2; \
logic [7:0] z80fi_mem_wdata2; \
logic [0:0] z80fi_i_rd; \
logic [0:0] z80fi_i_wr; \
logic [7:0] z80fi_i_rdata; \
logic [7:0] z80fi_i_wdata; \
logic [0:0] z80fi_r_rd; \
logic [0:0] z80fi_r_wr; \
logic [7:0] z80fi_r_rdata; \
logic [7:0] z80fi_r_wdata; \
logic [0:0] z80fi_f_rd; \
logic [0:0] z80fi_f_wr; \
logic [7:0] z80fi_f_rdata; \
logic [7:0] z80fi_f_wdata; \
logic [0:0] z80fi_iff1_rd; \
logic [0:0] z80fi_iff1_rdata; \
logic [0:0] z80fi_iff2_rd; \
logic [0:0] z80fi_iff2_rdata;

`define Z80FI_NEXT_STATE \
logic [0:0] next_z80fi_valid; \
logic [31:0] next_z80fi_insn; \
logic [2:0] next_z80fi_insn_len; \
logic [15:0] next_z80fi_pc_rdata; \
logic [15:0] next_z80fi_pc_wdata; \
logic [0:0] next_z80fi_reg1_rd; \
logic [3:0] next_z80fi_reg1_rnum; \
logic [3:0] next_z80fi_reg2_rnum; \
logic [15:0] next_z80fi_reg1_rdata; \
logic [0:0] next_z80fi_reg2_rd; \
logic [15:0] next_z80fi_reg2_rdata; \
logic [0:0] next_z80fi_reg_wr; \
logic [3:0] next_z80fi_reg_wnum; \
logic [15:0] next_z80fi_reg_wdata; \
logic [0:0] next_z80fi_mem_rd; \
logic [15:0] next_z80fi_mem_raddr; \
logic [7:0] next_z80fi_mem_rdata; \
logic [0:0] next_z80fi_mem_rd2; \
logic [15:0] next_z80fi_mem_raddr2; \
logic [7:0] next_z80fi_mem_rdata2; \
logic [0:0] next_z80fi_mem_wr; \
logic [15:0] next_z80fi_mem_waddr; \
logic [7:0] next_z80fi_mem_wdata; \
logic [0:0] next_z80fi_mem_wr2; \
logic [15:0] next_z80fi_mem_waddr2; \
logic [7:0] next_z80fi_mem_wdata2; \
logic [0:0] next_z80fi_i_rd; \
logic [0:0] next_z80fi_i_wr; \
logic [7:0] next_z80fi_i_rdata; \
logic [7:0] next_z80fi_i_wdata; \
logic [0:0] next_z80fi_r_rd; \
logic [0:0] next_z80fi_r_wr; \
logic [7:0] next_z80fi_r_rdata; \
logic [7:0] next_z80fi_r_wdata; \
logic [0:0] next_z80fi_f_rd; \
logic [0:0] next_z80fi_f_wr; \
logic [7:0] next_z80fi_f_rdata; \
logic [7:0] next_z80fi_f_wdata; \
logic [0:0] next_z80fi_iff1_rd; \
logic [0:0] next_z80fi_iff1_rdata; \
logic [0:0] next_z80fi_iff2_rd; \
logic [0:0] next_z80fi_iff2_rdata;

`define Z80FI_RESET_STATE \
z80fi_valid <= 0; \
z80fi_insn <= 0; \
z80fi_insn_len <= 0; \
z80fi_pc_rdata <= 0; \
z80fi_pc_wdata <= 0; \
z80fi_reg1_rd <= 0; \
z80fi_reg1_rnum <= 0; \
z80fi_reg2_rnum <= 0; \
z80fi_reg1_rdata <= 0; \
z80fi_reg2_rd <= 0; \
z80fi_reg2_rdata <= 0; \
z80fi_reg_wr <= 0; \
z80fi_reg_wnum <= 0; \
z80fi_reg_wdata <= 0; \
z80fi_mem_rd <= 0; \
z80fi_mem_raddr <= 0; \
z80fi_mem_rdata <= 0; \
z80fi_mem_rd2 <= 0; \
z80fi_mem_raddr2 <= 0; \
z80fi_mem_rdata2 <= 0; \
z80fi_mem_wr <= 0; \
z80fi_mem_waddr <= 0; \
z80fi_mem_wdata <= 0; \
z80fi_mem_wr2 <= 0; \
z80fi_mem_waddr2 <= 0; \
z80fi_mem_wdata2 <= 0; \
z80fi_i_rd <= 0; \
z80fi_i_wr <= 0; \
z80fi_i_rdata <= 0; \
z80fi_i_wdata <= 0; \
z80fi_r_rd <= 0; \
z80fi_r_wr <= 0; \
z80fi_r_rdata <= 0; \
z80fi_r_wdata <= 0; \
z80fi_f_rd <= 0; \
z80fi_f_wr <= 0; \
z80fi_f_rdata <= 0; \
z80fi_f_wdata <= 0; \
z80fi_iff1_rd <= 0; \
z80fi_iff1_rdata <= 0; \
z80fi_iff2_rd <= 0; \
z80fi_iff2_rdata <= 0;

`define Z80FI_LOAD_NEXT_STATE \
z80fi_valid <= next_z80fi_valid; \
z80fi_insn <= next_z80fi_insn; \
z80fi_insn_len <= next_z80fi_insn_len; \
z80fi_pc_rdata <= next_z80fi_pc_rdata; \
z80fi_pc_wdata <= next_z80fi_pc_wdata; \
z80fi_reg1_rd <= next_z80fi_reg1_rd; \
z80fi_reg1_rnum <= next_z80fi_reg1_rnum; \
z80fi_reg2_rnum <= next_z80fi_reg2_rnum; \
z80fi_reg1_rdata <= next_z80fi_reg1_rdata; \
z80fi_reg2_rd <= next_z80fi_reg2_rd; \
z80fi_reg2_rdata <= next_z80fi_reg2_rdata; \
z80fi_reg_wr <= next_z80fi_reg_wr; \
z80fi_reg_wnum <= next_z80fi_reg_wnum; \
z80fi_reg_wdata <= next_z80fi_reg_wdata; \
z80fi_mem_rd <= next_z80fi_mem_rd; \
z80fi_mem_raddr <= next_z80fi_mem_raddr; \
z80fi_mem_rdata <= next_z80fi_mem_rdata; \
z80fi_mem_rd2 <= next_z80fi_mem_rd2; \
z80fi_mem_raddr2 <= next_z80fi_mem_raddr2; \
z80fi_mem_rdata2 <= next_z80fi_mem_rdata2; \
z80fi_mem_wr <= next_z80fi_mem_wr; \
z80fi_mem_waddr <= next_z80fi_mem_waddr; \
z80fi_mem_wdata <= next_z80fi_mem_wdata; \
z80fi_mem_wr2 <= next_z80fi_mem_wr2; \
z80fi_mem_waddr2 <= next_z80fi_mem_waddr2; \
z80fi_mem_wdata2 <= next_z80fi_mem_wdata2; \
z80fi_i_rd <= next_z80fi_i_rd; \
z80fi_i_wr <= next_z80fi_i_wr; \
z80fi_i_rdata <= next_z80fi_i_rdata; \
z80fi_i_wdata <= next_z80fi_i_wdata; \
z80fi_r_rd <= next_z80fi_r_rd; \
z80fi_r_wr <= next_z80fi_r_wr; \
z80fi_r_rdata <= next_z80fi_r_rdata; \
z80fi_r_wdata <= next_z80fi_r_wdata; \
z80fi_f_rd <= next_z80fi_f_rd; \
z80fi_f_wr <= next_z80fi_f_wr; \
z80fi_f_rdata <= next_z80fi_f_rdata; \
z80fi_f_wdata <= next_z80fi_f_wdata; \
z80fi_iff1_rd <= next_z80fi_iff1_rd; \
z80fi_iff1_rdata <= next_z80fi_iff1_rdata; \
z80fi_iff2_rd <= next_z80fi_iff2_rd; \
z80fi_iff2_rdata <= next_z80fi_iff2_rdata;

`define Z80FI_RETAIN_NEXT_STATE \
next_z80fi_valid = 0; \
next_z80fi_insn = z80fi_insn; \
next_z80fi_insn_len = z80fi_insn_len; \
next_z80fi_pc_rdata = z80fi_pc_rdata; \
next_z80fi_pc_wdata = z80fi_pc_wdata; \
next_z80fi_reg1_rd = z80fi_reg1_rd; \
next_z80fi_reg1_rnum = z80fi_reg1_rnum; \
next_z80fi_reg2_rnum = z80fi_reg2_rnum; \
next_z80fi_reg1_rdata = z80fi_reg1_rdata; \
next_z80fi_reg2_rd = z80fi_reg2_rd; \
next_z80fi_reg2_rdata = z80fi_reg2_rdata; \
next_z80fi_reg_wr = z80fi_reg_wr; \
next_z80fi_reg_wnum = z80fi_reg_wnum; \
next_z80fi_reg_wdata = z80fi_reg_wdata; \
next_z80fi_mem_rd = z80fi_mem_rd; \
next_z80fi_mem_raddr = z80fi_mem_raddr; \
next_z80fi_mem_rdata = z80fi_mem_rdata; \
next_z80fi_mem_rd2 = z80fi_mem_rd2; \
next_z80fi_mem_raddr2 = z80fi_mem_raddr2; \
next_z80fi_mem_rdata2 = z80fi_mem_rdata2; \
next_z80fi_mem_wr = z80fi_mem_wr; \
next_z80fi_mem_waddr = z80fi_mem_waddr; \
next_z80fi_mem_wdata = z80fi_mem_wdata; \
next_z80fi_mem_wr2 = z80fi_mem_wr2; \
next_z80fi_mem_waddr2 = z80fi_mem_waddr2; \
next_z80fi_mem_wdata2 = z80fi_mem_wdata2; \
next_z80fi_i_rd = z80fi_i_rd; \
next_z80fi_i_wr = z80fi_i_wr; \
next_z80fi_i_rdata = z80fi_i_rdata; \
next_z80fi_i_wdata = z80fi_i_wdata; \
next_z80fi_r_rd = z80fi_r_rd; \
next_z80fi_r_wr = z80fi_r_wr; \
next_z80fi_r_rdata = z80fi_r_rdata; \
next_z80fi_r_wdata = z80fi_r_wdata; \
next_z80fi_f_rd = z80fi_f_rd; \
next_z80fi_f_wr = z80fi_f_wr; \
next_z80fi_f_rdata = z80fi_f_rdata; \
next_z80fi_f_wdata = z80fi_f_wdata; \
next_z80fi_iff1_rd = z80fi_iff1_rd; \
next_z80fi_iff1_rdata = z80fi_iff1_rdata; \
next_z80fi_iff2_rd = z80fi_iff2_rd; \
next_z80fi_iff2_rdata = z80fi_iff2_rdata;

`define Z80FI_INIT_NEXT_STATE \
next_z80fi_valid = 0; \
next_z80fi_insn = 0; \
next_z80fi_insn_len = 0; \
next_z80fi_pc_rdata = 0; \
next_z80fi_pc_wdata = 0; \
next_z80fi_reg1_rd = 0; \
next_z80fi_reg1_rnum = 0; \
next_z80fi_reg2_rnum = 0; \
next_z80fi_reg1_rdata = 0; \
next_z80fi_reg2_rd = 0; \
next_z80fi_reg2_rdata = 0; \
next_z80fi_reg_wr = 0; \
next_z80fi_reg_wnum = 0; \
next_z80fi_reg_wdata = 0; \
next_z80fi_mem_rd = 0; \
next_z80fi_mem_raddr = 0; \
next_z80fi_mem_rdata = 0; \
next_z80fi_mem_rd2 = 0; \
next_z80fi_mem_raddr2 = 0; \
next_z80fi_mem_rdata2 = 0; \
next_z80fi_mem_wr = 0; \
next_z80fi_mem_waddr = 0; \
next_z80fi_mem_wdata = 0; \
next_z80fi_mem_wr2 = 0; \
next_z80fi_mem_waddr2 = 0; \
next_z80fi_mem_wdata2 = 0; \
next_z80fi_i_rd = 0; \
next_z80fi_i_wr = 0; \
next_z80fi_i_rdata = 0; \
next_z80fi_i_wdata = 0; \
next_z80fi_r_rd = 0; \
next_z80fi_r_wr = 0; \
next_z80fi_r_rdata = 0; \
next_z80fi_r_wdata = 0; \
next_z80fi_f_rd = 0; \
next_z80fi_f_wr = 0; \
next_z80fi_f_rdata = 0; \
next_z80fi_f_wdata = 0; \
next_z80fi_iff1_rd = 0; \
next_z80fi_iff1_rdata = 0; \
next_z80fi_iff2_rd = 0; \
next_z80fi_iff2_rdata = 0;

`define Z80FI_CONN \
.z80fi_valid (z80fi_valid), \
.z80fi_insn (z80fi_insn), \
.z80fi_insn_len (z80fi_insn_len), \
.z80fi_pc_rdata (z80fi_pc_rdata), \
.z80fi_pc_wdata (z80fi_pc_wdata), \
.z80fi_reg1_rd (z80fi_reg1_rd), \
.z80fi_reg1_rnum (z80fi_reg1_rnum), \
.z80fi_reg2_rnum (z80fi_reg2_rnum), \
.z80fi_reg1_rdata (z80fi_reg1_rdata), \
.z80fi_reg2_rd (z80fi_reg2_rd), \
.z80fi_reg2_rdata (z80fi_reg2_rdata), \
.z80fi_reg_wr (z80fi_reg_wr), \
.z80fi_reg_wnum (z80fi_reg_wnum), \
.z80fi_reg_wdata (z80fi_reg_wdata), \
.z80fi_mem_rd (z80fi_mem_rd), \
.z80fi_mem_raddr (z80fi_mem_raddr), \
.z80fi_mem_rdata (z80fi_mem_rdata), \
.z80fi_mem_rd2 (z80fi_mem_rd2), \
.z80fi_mem_raddr2 (z80fi_mem_raddr2), \
.z80fi_mem_rdata2 (z80fi_mem_rdata2), \
.z80fi_mem_wr (z80fi_mem_wr), \
.z80fi_mem_waddr (z80fi_mem_waddr), \
.z80fi_mem_wdata (z80fi_mem_wdata), \
.z80fi_mem_wr2 (z80fi_mem_wr2), \
.z80fi_mem_waddr2 (z80fi_mem_waddr2), \
.z80fi_mem_wdata2 (z80fi_mem_wdata2), \
.z80fi_i_rd (z80fi_i_rd), \
.z80fi_i_wr (z80fi_i_wr), \
.z80fi_i_rdata (z80fi_i_rdata), \
.z80fi_i_wdata (z80fi_i_wdata), \
.z80fi_r_rd (z80fi_r_rd), \
.z80fi_r_wr (z80fi_r_wr), \
.z80fi_r_rdata (z80fi_r_rdata), \
.z80fi_r_wdata (z80fi_r_wdata), \
.z80fi_f_rd (z80fi_f_rd), \
.z80fi_f_wr (z80fi_f_wr), \
.z80fi_f_rdata (z80fi_f_rdata), \
.z80fi_f_wdata (z80fi_f_wdata), \
.z80fi_iff1_rd (z80fi_iff1_rd), \
.z80fi_iff1_rdata (z80fi_iff1_rdata), \
.z80fi_iff2_rd (z80fi_iff2_rd), \
.z80fi_iff2_rdata (z80fi_iff2_rdata)

`define Z80FI_INSN_SPEC_IO \
output logic [0:0] spec_valid, \
input [0:0] z80fi_valid, \
input [31:0] z80fi_insn, \
input [2:0] z80fi_insn_len, \
input [15:0] z80fi_pc_rdata, \
output logic [15:0] spec_pc_wdata, \
output logic [0:0] spec_reg1_rd, \
output logic [3:0] spec_reg1_rnum, \
output logic [3:0] spec_reg2_rnum, \
input [15:0] z80fi_reg1_rdata, \
output logic [0:0] spec_reg2_rd, \
input [15:0] z80fi_reg2_rdata, \
output logic [0:0] spec_reg_wr, \
output logic [3:0] spec_reg_wnum, \
output logic [15:0] spec_reg_wdata, \
output logic [0:0] spec_mem_rd, \
output logic [15:0] spec_mem_raddr, \
input [7:0] z80fi_mem_rdata, \
output logic [0:0] spec_mem_rd2, \
output logic [15:0] spec_mem_raddr2, \
input [7:0] z80fi_mem_rdata2, \
output logic [0:0] spec_mem_wr, \
output logic [15:0] spec_mem_waddr, \
output logic [7:0] spec_mem_wdata, \
output logic [0:0] spec_mem_wr2, \
output logic [15:0] spec_mem_waddr2, \
output logic [7:0] spec_mem_wdata2, \
output logic [0:0] spec_i_rd, \
output logic [0:0] spec_i_wr, \
input [7:0] z80fi_i_rdata, \
output logic [7:0] spec_i_wdata, \
output logic [0:0] spec_r_rd, \
output logic [0:0] spec_r_wr, \
input [7:0] z80fi_r_rdata, \
output logic [7:0] spec_r_wdata, \
output logic [0:0] spec_f_rd, \
output logic [0:0] spec_f_wr, \
input [7:0] z80fi_f_rdata, \
output logic [7:0] spec_f_wdata, \
output logic [0:0] spec_iff1_rd, \
input [0:0] z80fi_iff1_rdata, \
output logic [0:0] spec_iff2_rd, \
input [0:0] z80fi_iff2_rdata

`define SPEC_REG1_RD 15'b000000000000001
`define SPEC_REG2_RD 15'b000000000000010
`define SPEC_REG_WR 15'b000000000000100
`define SPEC_MEM_RD 15'b000000000001000
`define SPEC_MEM_RD2 15'b000000000010000
`define SPEC_MEM_WR 15'b000000000100000
`define SPEC_MEM_WR2 15'b000000001000000
`define SPEC_I_RD 15'b000000010000000
`define SPEC_I_WR 15'b000000100000000
`define SPEC_R_RD 15'b000001000000000
`define SPEC_R_WR 15'b000010000000000
`define SPEC_F_RD 15'b000100000000000
`define SPEC_F_WR 15'b001000000000000
`define SPEC_IFF1_RD 15'b010000000000000
`define SPEC_IFF2_RD 15'b100000000000000

`define Z80FI_SPEC_SIGNALS \
logic [14:0] spec_signals; \
assign spec_reg1_rd = spec_signals[0]; \
assign spec_reg2_rd = spec_signals[1]; \
assign spec_reg_wr = spec_signals[2]; \
assign spec_mem_rd = spec_signals[3]; \
assign spec_mem_rd2 = spec_signals[4]; \
assign spec_mem_wr = spec_signals[5]; \
assign spec_mem_wr2 = spec_signals[6]; \
assign spec_i_rd = spec_signals[7]; \
assign spec_i_wr = spec_signals[8]; \
assign spec_r_rd = spec_signals[9]; \
assign spec_r_wr = spec_signals[10]; \
assign spec_f_rd = spec_signals[11]; \
assign spec_f_wr = spec_signals[12]; \
assign spec_iff1_rd = spec_signals[13]; \
assign spec_iff2_rd = spec_signals[14];

`define Z80FI_SPEC_WIRES \
logic [0:0] valid = !reset && z80fi_valid; \
logic [31:0] insn = z80fi_insn; \
logic [2:0] insn_len = z80fi_insn_len; \
logic [15:0] pc_rdata = z80fi_pc_rdata; \
logic [15:0] reg1_rdata = z80fi_reg1_rdata; \
logic [15:0] reg2_rdata = z80fi_reg2_rdata; \
logic [7:0] mem_rdata = z80fi_mem_rdata; \
logic [7:0] mem_rdata2 = z80fi_mem_rdata2; \
logic [7:0] i_rdata = z80fi_i_rdata; \
logic [7:0] r_rdata = z80fi_r_rdata; \
logic [7:0] f_rdata = z80fi_f_rdata; \
logic [0:0] iff1_rdata = z80fi_iff1_rdata; \
logic [0:0] iff2_rdata = z80fi_iff2_rdata; \
\
logic [15:0] pc_wdata = z80fi_pc_wdata; \
logic [0:0] reg1_rd = z80fi_reg1_rd; \
logic [3:0] reg1_rnum = z80fi_reg1_rnum; \
logic [3:0] reg2_rnum = z80fi_reg2_rnum; \
logic [0:0] reg2_rd = z80fi_reg2_rd; \
logic [0:0] reg_wr = z80fi_reg_wr; \
logic [3:0] reg_wnum = z80fi_reg_wnum; \
logic [15:0] reg_wdata = z80fi_reg_wdata; \
logic [0:0] mem_rd = z80fi_mem_rd; \
logic [15:0] mem_raddr = z80fi_mem_raddr; \
logic [0:0] mem_rd2 = z80fi_mem_rd2; \
logic [15:0] mem_raddr2 = z80fi_mem_raddr2; \
logic [0:0] mem_wr = z80fi_mem_wr; \
logic [15:0] mem_waddr = z80fi_mem_waddr; \
logic [7:0] mem_wdata = z80fi_mem_wdata; \
logic [0:0] mem_wr2 = z80fi_mem_wr2; \
logic [15:0] mem_waddr2 = z80fi_mem_waddr2; \
logic [7:0] mem_wdata2 = z80fi_mem_wdata2; \
logic [0:0] i_rd = z80fi_i_rd; \
logic [0:0] i_wr = z80fi_i_wr; \
logic [7:0] i_wdata = z80fi_i_wdata; \
logic [0:0] r_rd = z80fi_r_rd; \
logic [0:0] r_wr = z80fi_r_wr; \
logic [7:0] r_wdata = z80fi_r_wdata; \
logic [0:0] f_rd = z80fi_f_rd; \
logic [0:0] f_wr = z80fi_f_wr; \
logic [7:0] f_wdata = z80fi_f_wdata; \
logic [0:0] iff1_rd = z80fi_iff1_rd; \
logic [0:0] iff2_rd = z80fi_iff2_rd; \
\
logic [0:0] spec_valid; \
logic [15:0] spec_pc_wdata; \
logic [0:0] spec_reg1_rd; \
logic [3:0] spec_reg1_rnum; \
logic [3:0] spec_reg2_rnum; \
logic [0:0] spec_reg2_rd; \
logic [0:0] spec_reg_wr; \
logic [3:0] spec_reg_wnum; \
logic [15:0] spec_reg_wdata; \
logic [0:0] spec_mem_rd; \
logic [15:0] spec_mem_raddr; \
logic [0:0] spec_mem_rd2; \
logic [15:0] spec_mem_raddr2; \
logic [0:0] spec_mem_wr; \
logic [15:0] spec_mem_waddr; \
logic [7:0] spec_mem_wdata; \
logic [0:0] spec_mem_wr2; \
logic [15:0] spec_mem_waddr2; \
logic [7:0] spec_mem_wdata2; \
logic [0:0] spec_i_rd; \
logic [0:0] spec_i_wr; \
logic [7:0] spec_i_wdata; \
logic [0:0] spec_r_rd; \
logic [0:0] spec_r_wr; \
logic [7:0] spec_r_wdata; \
logic [0:0] spec_f_rd; \
logic [0:0] spec_f_wr; \
logic [7:0] spec_f_wdata; \
logic [0:0] spec_iff1_rd; \
logic [0:0] spec_iff2_rd;

`define Z80FI_SPEC_CONNS \
.z80fi_valid (valid), \
.z80fi_insn (insn), \
.z80fi_insn_len (insn_len), \
.z80fi_pc_rdata (pc_rdata), \
.z80fi_reg1_rdata (reg1_rdata), \
.z80fi_reg2_rdata (reg2_rdata), \
.z80fi_mem_rdata (mem_rdata), \
.z80fi_mem_rdata2 (mem_rdata2), \
.z80fi_i_rdata (i_rdata), \
.z80fi_r_rdata (r_rdata), \
.z80fi_f_rdata (f_rdata), \
.z80fi_iff1_rdata (iff1_rdata), \
.z80fi_iff2_rdata (iff2_rdata), \
.spec_valid (spec_valid), \
.spec_pc_wdata (spec_pc_wdata), \
.spec_reg1_rd (spec_reg1_rd), \
.spec_reg1_rnum (spec_reg1_rnum), \
.spec_reg2_rnum (spec_reg2_rnum), \
.spec_reg2_rd (spec_reg2_rd), \
.spec_reg_wr (spec_reg_wr), \
.spec_reg_wnum (spec_reg_wnum), \
.spec_reg_wdata (spec_reg_wdata), \
.spec_mem_rd (spec_mem_rd), \
.spec_mem_raddr (spec_mem_raddr), \
.spec_mem_rd2 (spec_mem_rd2), \
.spec_mem_raddr2 (spec_mem_raddr2), \
.spec_mem_wr (spec_mem_wr), \
.spec_mem_waddr (spec_mem_waddr), \
.spec_mem_wdata (spec_mem_wdata), \
.spec_mem_wr2 (spec_mem_wr2), \
.spec_mem_waddr2 (spec_mem_waddr2), \
.spec_mem_wdata2 (spec_mem_wdata2), \
.spec_i_rd (spec_i_rd), \
.spec_i_wr (spec_i_wr), \
.spec_i_wdata (spec_i_wdata), \
.spec_r_rd (spec_r_rd), \
.spec_r_wr (spec_r_wr), \
.spec_r_wdata (spec_r_wdata), \
.spec_f_rd (spec_f_rd), \
.spec_f_wr (spec_f_wr), \
.spec_f_wdata (spec_f_wdata), \
.spec_iff1_rd (spec_iff1_rd), \
.spec_iff2_rd (spec_iff2_rd)

