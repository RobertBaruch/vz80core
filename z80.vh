`ifndef _z80_vh_
`define _z80_vh_

`default_nettype none
`timescale 1us/1us

`define Z80_FORMAL 1

// reg_select is big enough for 4 bits of set number, and 3 bits of
// register number. Not all combinations are valid.
`define reg_select [4:0]

// The 8-bit registers A, B, C, D, E, H, L
`define REG_SET_R  2'b00
// The 16-bit registers BC, DE, HL, SP
`define REG_SET_DD 3'b010
// The 16-bit registers BC, DE, HL, AF
`define REG_SET_QQ 3'b100
// The 16-bit registers IX, IY
`define REG_SET_IDX 4'b1100

// 8-bit register numbers.
// These are ordered so that they correspond with the standard
// 3-bit encoding in instructions. You may use these directly in
// task_reg_read and task_reg_write, no need to concat to
// REG_SET_R.
`define REG_B 3'b000
`define REG_C 3'b001
`define REG_D 3'b010
`define REG_E 3'b011
`define REG_H 3'b100
`define REG_L 3'b101
`define REG_A 3'b111

// 16-bit registers dd.
// These are ordered so that the two bits are the same as
// the standard 2-bit encoding for dd in instructions.
// When specifying these registers, use DD_REG_*, or
// concat your 2 bits to REG_SET_DD.
`define REG_BC 2'b00
`define REG_DE 2'b01
`define REG_HL 2'b10
`define REG_SP 2'b11

// 16-bit registers qq. BC, DE, and HL have the same numbers.
// These are ordered so that the two bits are the same as
// the standard 2-bit encoding for dd in instructions.
// When specifying these registers, use QQ_REG_*, or
// concat your 2 bits to REG_SET_QQ.
`define REG_AF 2'b11

// 16-bit index register numbers. IY is 1 to be the same as
// the standard 1-bit encoding in instructions.
// When specifying these registers, use IDX_REG_*, or
// concat your single bit to REG_SET_IDX.
`define REG_IX 1'b0
`define REG_IY 1'b1

`define DD_REG_BC ({`REG_SET_DD, `REG_BC})
`define DD_REG_DE ({`REG_SET_DD, `REG_DE})
`define DD_REG_HL ({`REG_SET_DD, `REG_HL})
`define DD_REG_SP ({`REG_SET_DD, `REG_SP})

`define QQ_REG_BC ({`REG_SET_QQ, `REG_BC})
`define QQ_REG_DE ({`REG_SET_QQ, `REG_DE})
`define QQ_REG_HL ({`REG_SET_QQ, `REG_HL})
`define QQ_REG_AF ({`REG_SET_QQ, `REG_AF})

`define IDX_REG_IX ({`REG_SET_IDX, `REG_IX})
`define IDX_REG_IY ({`REG_SET_IDX, `REG_IY})

`define FLAG_S_NUM  7
`define FLAG_S_BIT  8'b10000000
`define FLAG_S_MASK (~`FLAG_S_BIT)
`define FLAG_Z_NUM  6
`define FLAG_Z_BIT  8'b01000000
`define FLAG_Z_MASK (~`FLAG_Z_BIT)
`define FLAG_5_NUM  5
`define FLAG_5_BIT  8'b00100000
`define FLAG_5_MASK (~`FLAG_5_BIT)
`define FLAG_H_NUM  4
`define FLAG_H_BIT  8'b00010000
`define FLAG_H_MASK (~`FLAG_H_BIT)
`define FLAG_3_NUM  3
`define FLAG_3_BIT  8'b00001000
`define FLAG_3_MASK (~`FLAG_3_BIT)
`define FLAG_PV_NUM  2
`define FLAG_PV_BIT  8'b00000100
`define FLAG_PV_MASK (~`FLAG_PV_BIT)
`define FLAG_N_NUM  1
`define FLAG_N_BIT  8'b00000010
`define FLAG_N_MASK (~`FLAG_N_BIT)
`define FLAG_C_NUM  0
`define FLAG_C_BIT  8'b00000001
`define FLAG_C_MASK (~`FLAG_C_BIT)

// A function that keeps all of the flags in f1 specified in mask1,
// and the rest are taken from f2.
function [7:0] _combine_flags(input [7:0] f1, input [7:0] f2, input [7:0] mask1);
  _combine_flags = (f1 & mask1) | (f2 & ~mask1);
endfunction

// A function that returns the amount that needs to be added to or
// subtracted from A for decimal adjust.
//
// The description of DAA in various Z80 books is grotesque. The
// readable algorithm is:
//
// * If H is set or lower nibble of A is > 9 then
//   add (N=0) or subtract (N=1) 8'h06 from A.
// * If C is set or upper nibble of A is > 9 then
//   add (N=0) or subtract (N=1) 8'h60 from A.
//
// Note that this is the whole raison d'etre of the half-carry
// flag.
function [7:0] _daa_adjustment(input flag_c, input flag_h, input [7:0] a);
    _daa_adjustment =
        ((flag_h || (a[3:0] > 4'h9)) ? 8'h6 : 0) +
        ((flag_c || (a[7:4] > 4'h9)) ? 8'h60 : 0);
endfunction

// These are numbered and ordered in the same way as instructions
// 80-BF.
`define ALU_FUNC_ADD 0
`define ALU_FUNC_ADC 1
`define ALU_FUNC_SUB 2
`define ALU_FUNC_SBC 3
`define ALU_FUNC_AND 4
`define ALU_FUNC_XOR 5
`define ALU_FUNC_OR 6
`define ALU_FUNC_CP 7

// The following are ordered in the same way as the
// 'through_c' and 'right' bits in instructions are designated.

// Prefix to cancatenate with through_c and right bits to get func.
`define ALU_ROT 2'b10
// Rotate left, copy to carry
`define ALU_FUNC_RLC 8
// Rotate right, copy to carry
`define ALU_FUNC_RRC 9
// Rotate left through carry
`define ALU_FUNC_RL 10
// Rotate right through carry
`define ALU_FUNC_RR 11

// Same, for shift left/right arithmetic/logical.
`define ALU_SHIFT 2'b11
`define ALU_FUNC_SLA 12
`define ALU_FUNC_SRA 13
// Note: SLL is undocumented.
`define ALU_FUNC_SLL 14
`define ALU_FUNC_SRL 15


`define INSN_GROUP_IDX_IXIY_BITS 253
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
`define INSN_GROUP_POP_QQ 26           /* POP qq           */
`define INSN_GROUP_POP_IXIY 27         /* POP IX/IY        */
`define INSN_GROUP_PUSH_QQ 28          /* PUSH qq          */
`define INSN_GROUP_PUSH_IXIY 29        /* PUSH IX/IY       */
`define INSN_GROUP_LDD 30              /* LDD              */
`define INSN_GROUP_LDI 31              /* LDI              */
`define INSN_GROUP_LDDR 32             /* LDDR             */
`define INSN_GROUP_LDIR 33             /* LDIR             */
`define INSN_GROUP_EX_DE_HL 34         /* EX DE, HL        */
`define INSN_GROUP_EX_AF_AF2 35        /* EX AF, AF2       */
`define INSN_GROUP_EXX 36              /* EXX              */
`define INSN_GROUP_EX_IND_SP_HL 37     /* EX (SP), HL      */
`define INSN_GROUP_EX_IND_SP_IXIY 38   /* EX (SP), IX/IY   */
`define INSN_GROUP_CPD 39              /* CPD              */
`define INSN_GROUP_CPI 40              /* CPI              */
`define INSN_GROUP_CPDR 41             /* CPDR             */
`define INSN_GROUP_CPIR 42             /* CPIR             */
`define INSN_GROUP_ALU_A_REG 43        /* ADD/ADC A, r     */
                                       /* SUB/SBC A, r     */
                                       /* AND/XOR A, r     */
                                       /* OR/CP A, r       */
`define INSN_GROUP_ALU_A_N 44          /* ADD/ADC A, n     */
                                       /* SUB/SBC A, n     */
                                       /* AND/XOR A, n     */
                                       /* OR/CP A, n       */
`define INSN_GROUP_ALU_A_IND_HL 45     /* ADD/ADC A, (HL)  */
                                       /* SUB/SBC A, (HL)  */
                                       /* AND/XOR A, (HL)  */
                                       /* OR/CP A, (HL)    */
`define INSN_GROUP_ALU_A_IDX_IXIY 46   /* ADD/ADC A, (IX/IY + d)  */
                                       /* SUB/SBC A, (IX/IY + d)  */
                                       /* AND/XOR A, (IX/IY + d)  */
                                       /* OR/CP A, (IX/IY + d)    */
`define INSN_GROUP_INC_DEC_REG 47      /* INC/DEC r        */
`define INSN_GROUP_INC_DEC_IND_HL 48   /* INC/DEC (HL)     */
`define INSN_GROUP_INC_DEC_IDX_IXIY 49 /* INC/DEC (IX/IY + d)     */
`define INSN_GROUP_DAA 50              /* DAA              */
`define INSN_GROUP_CPL 51              /* CPL              */
`define INSN_GROUP_NEG 52              /* NEG              */
`define INSN_GROUP_CCF 53              /* CCF              */
`define INSN_GROUP_SCF 54              /* SCF              */
`define INSN_GROUP_HALT 55             /* HALT             */
`define INSN_GROUP_EI_DI 56            /* EI/DI            */
`define INSN_GROUP_ADD_HL_DD 57        /* ADD HL, dd       */
`define INSN_GROUP_ADC_SBC_HL_DD 58    /* ADC/SBC HL, dd   */
`define INSN_GROUP_ADD_IXIY_SS 59      /* ADD IX/IY, ss    */
`define INSN_GROUP_INC_DEC_DD 60       /* INC/DEC dd       */
`define INSN_GROUP_INC_DEC_IXIY 61     /* INC/DEC IX/IY    */
`define INSN_GROUP_RR_RLCA 62          /* RLCA/RLA/RRCA/RRA       */
`define INSN_GROUP_RR_RLC_REG 63       /* RLCA/RLA/RRCA/RRA r     */
`define INSN_GROUP_RR_RLC_IND_HL 64    /* RLCA/RLA/RRCA/RRA (HL)  */
`define INSN_GROUP_SHIFT_REG 65        /* SRA/SRL/SLA r    */
`define INSN_GROUP_SHIFT_IND_HL 66     /* SRA/SRL/SLA (HL) */
`define INSN_GROUP_ROT_DEC 67          /* RRD/RLD          */
`define INSN_GROUP_BIT_REG 68          /* BIT b, r         */
`define INSN_GROUP_BIT_IND_HL 69       /* BIT b, (HL)      */
`define INSN_GROUP_SET_REG 70          /* SET b, r         */
`define INSN_GROUP_SET_IND_HL 71       /* SET b, (HL)      */
`define INSN_GROUP_RES_REG 72          /* RES b, r         */
`define INSN_GROUP_RES_IND_HL 73       /* RES b, (HL)      */

// These are the INSN_GROUP_IDX_IXIY_BITS groups
`define INSN_GROUP_RR_RLC_IDX_IXIY 0   /* RLCA/RLA/RRCA/RRA (IX/IY + d) */
`define INSN_GROUP_SHIFT_IDX_IXIY 1    /* SRA/SRL/SLA (IX/IY + d)       */
`define INSN_GROUP_BIT_IDX_IXIY 2      /* BIT b, (IX/IY + d)            */
`define INSN_GROUP_SET_IDX_IXIY 3      /* SET b, (IX/IY + d)            */
`define INSN_GROUP_RES_IDX_IXIY 4      /* RES b, (IX/IY + d)            */

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