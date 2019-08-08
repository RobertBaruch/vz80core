`ifndef _z80_vh_
`define _z80_vh_

`default_nettype none
`timescale 1us/1us

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
`define REG_IX 12
`define REG_IY 13
`define REG_LAST16 13

`define FLAG_S_BIT  8'b10000000
`define FLAG_S_MASK (~`FLAG_S_BIT)
`define FLAG_Z_BIT  8'b01000000
`define FLAG_Z_MASK (~`FLAG_Z_BIT)
`define FLAG_5_BIT  8'b00100000
`define FLAG_5_MASK (~`FLAG_5_BIT)
`define FLAG_H_BIT  8'b00010000
`define FLAG_H_MASK (~`FLAG_H_BIT)
`define FLAG_3_BIT  8'b00001000
`define FLAG_3_MASK (~`FLAG_3_BIT)
`define FLAG_PV_BIT  8'b00000100
`define FLAG_PV_MASK (~`FLAG_PV_BIT)
`define FLAG_N_BIT  8'b00000010
`define FLAG_N_MASK (~`FLAG_N_BIT)
`define FLAG_C_BIT  8'b00000001
`define FLAG_C_MASK (~`FLAG_C_BIT)

`define INSN_GROUP_NEED_MORE_BYTES 254
`define INSN_GROUP_ILLEGAL_INSTR 255
`define INSN_GROUP_LD_REG_REG 0        /* LD  r, r'        */
`define INSN_GROUP_LD_DD_NN 1          /* LD  dd, nn       */
`define INSN_GROUP_LD_DD_IND_NN 2      /* LD  dd, (nn)     */
`define INSN_GROUP_LD_IND_BCDE_A 3     /* LD  (BC/DE), A   */
`define INSN_GROUP_LD_A_IND_NN 4       /* LD  A, (nn)      */
`define INSN_GROUP_LD_IND_NN_A 5       /* LD  (nn), A      */
`define INSN_GROUP_LD_REG_N 6          /* LD  r, n         */
`define INSN_GROUP_LD_IND_HL_N 7       /* LD  (HL), n      */
`define INSN_GROUP_LD_IND_HL_REG 8     /* LD  (HL), r      */
`define INSN_GROUP_LD_REG_IDX_IXIY 9   /* LD  r, (IX/IY+d) */
`define INSN_GROUP_LD_IDX_IXIY_N 10    /* LD  (IX/IY+d), n */
`define INSN_GROUP_LD_IDX_IXIY_REG 11  /* LD  (IX/IY+d), r */
`define INSN_GROUP_LD_IND_NN_DD 12     /* LD  (nn), dd     */
`define INSN_GROUP_LD_IND_NN_HL 13     /* LD  (nn), HL     */
`define INSN_GROUP_LD_IND_NN_IXIY 14   /* LD  (nn), IX/IY  */
`define INSN_GROUP_LD_A_IND_BCDE 15    /* LD  A, (BC/DE)   */
`define INSN_GROUP_LD_A_I 16           /* LD  A, I         */
`define INSN_GROUP_LD_I_A 17           /* LD  I, A         */
`define INSN_GROUP_LD_A_R 18           /* LD  A, R         */
`define INSN_GROUP_LD_HL_IND_NN 19     /* LD  HL, (nn)     */
`define INSN_GROUP_LD_IXIY_NN 20       /* LD  IX/IY, nn    */
`define INSN_GROUP_LD_IXIY_IND_NN 21   /* LD  IX/IY, (nn)  */
`define INSN_GROUP_NOP 22              /* NOP              */
`define INSN_GROUP_LD_R_A 23           /* LD  R, A         */
`define INSN_GROUP_LD_SP_HL 24         /* LD  SP, HL       */
`define INSN_GROUP_LD_SP_IXIY 25       /* LD  SP, IX/IY    */
`define INSN_GROUP_LDD 26              /* LDD              */

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