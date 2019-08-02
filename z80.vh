`ifndef _z80_vh_
`define _z80_vh_

`define Z80_FORMAL 1

`define reg_select [3:0]

// 8-bit register numbers.
// These are ordered so that they correspond with the standard
// 3-bit encoding in instructions.
`define REG_A 7
`define REG_B 0
`define REG_C 1
`define REG_D 2
`define REG_E 3
`define REG_H 4
`define REG_L 5

// 16-bit register numbers.
// These are ordered so that the lower two bits correspond with
// the standard 2-bit encoding in instructions.
// REG_{FIRST|LAST}16 are the register numbers for the first
// and last 16 bit register, for range checks.
`define REG_FIRST16 8
`define REG_BC 8
`define REG_DE 9
`define REG_HL 10
`define REG_SP 11
`define REG_AF 12
`define REG_IX 13
`define REG_IY 14
`define REG_LAST16 14

`define INSN_GROUP_NEED_MORE_BYTES 254
`define INSN_GROUP_ILLEGAL_INSTR 255
`define INSN_GROUP_LD_REG_REG 0
`define INSN_GROUP_LD_DD_IMMED 1
`define INSN_GROUP_LD_DD_EXTADDR 2
`define INSN_GROUP_LD_BCDE_A 3
`define INSN_GROUP_LD_A_EXTADDR 4
`define INSN_GROUP_LD_EXTADDR_A 5
`define INSN_GROUP_LD_REG_IMMED 6
`define INSN_GROUP_LD_HL_IMMED 7
`define INSN_GROUP_LD_HL_REG 8
`define INSN_GROUP_LD_REG_IXIY 9


`define Z80_REGS_OUTPUTS \
output [7:0] z80_reg_a, \
output [7:0] z80_reg_f, \
output [7:0] z80_reg_b, \
output [7:0] z80_reg_c, \
output [7:0] z80_reg_d, \
output [7:0] z80_reg_e, \
output [7:0] z80_reg_h, \
output [7:0] z80_reg_l, \
output [7:0] z80_reg_a2, \
output [7:0] z80_reg_f2, \
output [7:0] z80_reg_b2, \
output [7:0] z80_reg_c2, \
output [7:0] z80_reg_d2, \
output [7:0] z80_reg_e2, \
output [7:0] z80_reg_h2, \
output [7:0] z80_reg_l2, \
output [15:0] z80_reg_ix, \
output [15:0] z80_reg_iy, \
output [15:0] z80_reg_sp

`define Z80_REGS_WIRES \
wire [7:0] z80_reg_a; \
wire [7:0] z80_reg_f; \
wire [7:0] z80_reg_b; \
wire [7:0] z80_reg_c; \
wire [7:0] z80_reg_d; \
wire [7:0] z80_reg_e; \
wire [7:0] z80_reg_h; \
wire [7:0] z80_reg_l; \
wire [7:0] z80_reg_a2; \
wire [7:0] z80_reg_f2; \
wire [7:0] z80_reg_b2; \
wire [7:0] z80_reg_c2; \
wire [7:0] z80_reg_d2; \
wire [7:0] z80_reg_e2; \
wire [7:0] z80_reg_h2; \
wire [7:0] z80_reg_l2; \
wire [15:0] z80_reg_ix; \
wire [15:0] z80_reg_iy; \
wire [15:0] z80_reg_sp;

`define Z80_REGS_CONN \
.z80_reg_a(z80_reg_a), \
.z80_reg_f(z80_reg_f), \
.z80_reg_b(z80_reg_b), \
.z80_reg_c(z80_reg_c), \
.z80_reg_d(z80_reg_d), \
.z80_reg_e(z80_reg_e), \
.z80_reg_h(z80_reg_h), \
.z80_reg_l(z80_reg_l), \
.z80_reg_a2(z80_reg_a2), \
.z80_reg_f2(z80_reg_f2), \
.z80_reg_b2(z80_reg_b2), \
.z80_reg_c2(z80_reg_c2), \
.z80_reg_d2(z80_reg_d2), \
.z80_reg_e2(z80_reg_e2), \
.z80_reg_h2(z80_reg_h2), \
.z80_reg_l2(z80_reg_l2), \
.z80_reg_ix(z80_reg_ix), \
.z80_reg_iy(z80_reg_iy), \
.z80_reg_sp(z80_reg_sp)

`endif // _z80_vh_