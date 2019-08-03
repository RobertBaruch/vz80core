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
output logic [0:0] z80fi_iff2_rd, \
output logic [0:0] z80fi_iff2_rdata

`define Z80FI_WIRES \
wire [0:0] z80fi_valid; \
wire [31:0] z80fi_insn; \
wire [2:0] z80fi_insn_len; \
wire [15:0] z80fi_pc_rdata; \
wire [15:0] z80fi_pc_wdata; \
wire [0:0] z80fi_reg1_rd; \
wire [3:0] z80fi_reg1_rnum; \
wire [3:0] z80fi_reg2_rnum; \
wire [15:0] z80fi_reg1_rdata; \
wire [0:0] z80fi_reg2_rd; \
wire [15:0] z80fi_reg2_rdata; \
wire [0:0] z80fi_reg_wr; \
wire [3:0] z80fi_reg_wnum; \
wire [15:0] z80fi_reg_wdata; \
wire [0:0] z80fi_mem_rd; \
wire [15:0] z80fi_mem_raddr; \
wire [7:0] z80fi_mem_rdata; \
wire [0:0] z80fi_mem_rd2; \
wire [15:0] z80fi_mem_raddr2; \
wire [7:0] z80fi_mem_rdata2; \
wire [0:0] z80fi_mem_wr; \
wire [15:0] z80fi_mem_waddr; \
wire [7:0] z80fi_mem_wdata; \
wire [0:0] z80fi_mem_wr2; \
wire [15:0] z80fi_mem_waddr2; \
wire [7:0] z80fi_mem_wdata2; \
wire [0:0] z80fi_i_rd; \
wire [0:0] z80fi_i_wr; \
wire [7:0] z80fi_i_rdata; \
wire [7:0] z80fi_i_wdata; \
wire [0:0] z80fi_r_rd; \
wire [0:0] z80fi_r_wr; \
wire [7:0] z80fi_r_rdata; \
wire [7:0] z80fi_r_wdata; \
wire [0:0] z80fi_f_rd; \
wire [0:0] z80fi_f_wr; \
wire [7:0] z80fi_f_rdata; \
wire [7:0] z80fi_f_wdata; \
wire [0:0] z80fi_iff2_rd; \
wire [0:0] z80fi_iff2_rdata;

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
.z80fi_iff2_rd (z80fi_iff2_rd), \
.z80fi_iff2_rdata (z80fi_iff2_rdata)

`define Z80FI_INSN_SPEC_IO \
output [0:0] spec_valid, \
input [0:0] z80fi_valid, \
input [31:0] z80fi_insn, \
input [2:0] z80fi_insn_len, \
input [15:0] z80fi_pc_rdata, \
output [15:0] spec_pc_wdata, \
output [0:0] spec_reg1_rd, \
output [3:0] spec_reg1_rnum, \
output [3:0] spec_reg2_rnum, \
input [15:0] z80fi_reg1_rdata, \
output [0:0] spec_reg2_rd, \
input [15:0] z80fi_reg2_rdata, \
output [0:0] spec_reg_wr, \
output [3:0] spec_reg_wnum, \
output [15:0] spec_reg_wdata, \
output [0:0] spec_mem_rd, \
output [15:0] spec_mem_raddr, \
input [7:0] z80fi_mem_rdata, \
output [0:0] spec_mem_rd2, \
output [15:0] spec_mem_raddr2, \
input [7:0] z80fi_mem_rdata2, \
output [0:0] spec_mem_wr, \
output [15:0] spec_mem_waddr, \
output [7:0] spec_mem_wdata, \
output [0:0] spec_mem_wr2, \
output [15:0] spec_mem_waddr2, \
output [7:0] spec_mem_wdata2, \
output [0:0] spec_i_rd, \
output [0:0] spec_i_wr, \
input [7:0] z80fi_i_rdata, \
output [7:0] spec_i_wdata, \
output [0:0] spec_r_rd, \
output [0:0] spec_r_wr, \
input [7:0] z80fi_r_rdata, \
output [7:0] spec_r_wdata, \
output [0:0] spec_f_rd, \
output [0:0] spec_f_wr, \
input [7:0] z80fi_f_rdata, \
output [7:0] spec_f_wdata, \
output [0:0] spec_iff2_rd, \
input [0:0] z80fi_iff2_rdata

`define SPEC_REG1_RD 13'b0000000000001
`define SPEC_REG2_RD 13'b0000000000010
`define SPEC_REG_WR 13'b0000000000100
`define SPEC_MEM_RD 13'b0000000001000
`define SPEC_MEM_RD2 13'b0000000010000
`define SPEC_MEM_WR 13'b0000000100000
`define SPEC_MEM_WR2 13'b0000001000000
`define SPEC_I_RD 13'b0000010000000
`define SPEC_I_WR 13'b0000100000000
`define SPEC_R_RD 13'b0001000000000
`define SPEC_R_WR 13'b0010000000000
`define SPEC_F_RD 13'b0100000000000
`define SPEC_F_WR 13'b1000000000000

`define Z80FI_SPEC_SIGNALS \
wire [12:0] spec_signals; \
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
assign spec_f_wr = spec_signals[12];
