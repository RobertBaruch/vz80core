`ifndef _z80fi_vh_
`define _z80fi_vh_

`ifdef YOSYS
  `define z80formal_rand_reg rand reg
  `define z80formal_const_rand_reg const rand reg
`else
  `ifdef SIMULATION
    `define z80formal_rand_reg reg
    `define z80formal_const_rand_reg reg
  `else
    `define z80formal_rand_reg wire
    `define z80formal_const_rand_reg reg
  `endif
`endif

// Z80FI signal definitions:
//
// z80fi_valid:
//   When the core completes execution of an instruction, this signal is asserted
//   and the rest of the signals below describe the details of the instruction.
//   The signals below are only valid during such a cycle and can be driven to
//   arbitrary values in a cycle in which z80fi_valid is not asserted.
// z80fi_insn:
//   The instruction bytes (as many as four bytes) for the completed instruction,
//   including operands. Instructions are stored first byte last, so that the first byte
//   of an instruction is always in the low 8 bits, the next byte is always in bits
//   8-15, and so on. The actual number of bytes in the instruction is given in
//   z80fi_insn_len. Unused bytes must be zero.
// z80fi_insn_len:
//   The length in bytes of the instruction word for the completed instruction.
// z80fi_reg1/2_rd, z80fi_reg1/2_rnum, z80fi_reg1/2_rdata:
//   If the instruction did not read any register, then z80fi_reg1/2_rd contains zero,
//   and the rest contin arbitrary values.
//   If the instruction read registers, then z80fi_reg1/2_rd contains 1,
//   z80fi_reg1/2_rnum contains the register number read (one of the REG_ defines in
//   z80.vh) and z80fi_reg1/2_rdata contains the contents of that register just prior
//   to the instruction starting. For 8-bit reads, the high 8 bits of rdata must be
//   set to zero.
// z80fi_reg_wr, z80fi_reg_wnum, z80fi_reg_wdata:
//   If the instruction did not write any register, then z80fi_reg_wr must be zero,
//   and z80fi_reg_wnum and z80fi_reg_wdata may contain arbitrary values. If the instruction
//   wrote a register, then z80fi_reg_wr must be 1, z80fi_reg_wnum contains the register
//   number written (one of the REG_ defines in z80.vh) and z80fi_reg_wdata contains
//   the data written. For 8-bit writes, the high 8 bits of wdata must be set to zero.
// z80fi_pc_rdata, z80fi_pc_wdata:
//   These are the value of the program counter just prior (z80fi_pc_rdata) and just
//   after (z80fi_pc_wdata) the instruction executes. That is, z80fi_pc_rdata is the
//   address of the instruction just executed, and z80fi_pc_wdata is the address of
//   the next instructino to execute.
// z80fi_mem_addr(2), z80fi_mem_rd(2), z80fi_mem_wr, z80fi_mem_rdata(2), z80fi_mem_wdata:
//   If the instruction did not read from memory (ignoring reads of instruction data)
//   then z80fi_mem_rd is zero. If the instruction did not write memory, z80fi_mem_wr
//   is zero. If memory was read or written, z80fi_mem_addr is the address location
//   accessed, or an arbitrary value otherwise. z80fi_mem_rdata is the contents of the
//   memory location just prior to the instruction starting, or an arbitrary value if
//   memory was not read. z80fi_mem_wdata is the data written to memory, or an
//   arbitrary value if memory was not written.
//   z80fi_mem_rd is for the first read. If there was a second read, use z80_fi_mem_rd2/
//   z80fi_mem_addr2/z80fi_mem_rdata2.
//
// The general strategy for setting these is to use `Z80FI_NEXT_STATE in the module
// state, and `Z80FI_RETAIN_NEXT_STATE as the default condition during state
// calculation, so that nothing changes from state to state, except that
// next_z80fi_valid is always set to 0. 
//
// In addition, on every clock, ensure you use `Z80FI_LOAD_NEXT_STATE which will
// update the state. If reset, use `Z80FI_RESET_STATE.
//
// As an instruction executes, you can update the state values using the
// next_<signal> signals. Once the instruction is complete, additionally set
// next_z80fi_valid to 1.

`define Z80FI_INPUTS \
input [0  : 0] z80fi_valid,      \
input [31 : 0] z80fi_insn,       \
input [2  : 0] z80fi_insn_len,   \
input [15 : 0] z80fi_pc_rdata,   \
input [15 : 0] z80fi_pc_wdata,   \
input [0  : 0] z80fi_reg1_rd,    \
input [0  : 0] z80fi_reg2_rd,    \
input [3  : 0] z80fi_reg1_rnum,  \
input [3  : 0] z80fi_reg2_rnum,  \
input [15 : 0] z80fi_reg1_rdata, \
input [15 : 0] z80fi_reg2_rdata, \
input [0  : 0] z80fi_reg_wr,     \
input [3  : 0] z80fi_reg_wnum,   \
input [15 : 0] z80fi_reg_wdata,  \
input [15 : 0] z80fi_mem_addr,   \
input [15 : 0] z80fi_mem_addr2,  \
input [0  : 0] z80fi_mem_rd,     \
input [7  : 0] z80fi_mem_rdata,  \
input [0  : 0] z80fi_mem_rd2,    \
input [7  : 0] z80fi_mem_rdata2, \
input [0  : 0] z80fi_mem_wr,     \
input [7  : 0] z80fi_mem_wdata

`define Z80FI_OUTPUTS \
output logic [0  : 0] z80fi_valid,      \
output logic [31 : 0] z80fi_insn,       \
output logic [2  : 0] z80fi_insn_len,   \
output logic [15 : 0] z80fi_pc_rdata,   \
output logic [15 : 0] z80fi_pc_wdata,   \
output logic [0  : 0] z80fi_reg1_rd,    \
output logic [0  : 0] z80fi_reg2_rd,    \
output logic [3  : 0] z80fi_reg1_rnum,  \
output logic [3  : 0] z80fi_reg2_rnum,  \
output logic [15 : 0] z80fi_reg1_rdata, \
output logic [15 : 0] z80fi_reg2_rdata, \
output logic [0  : 0] z80fi_reg_wr,     \
output logic [3  : 0] z80fi_reg_wnum,   \
output logic [15 : 0] z80fi_reg_wdata,  \
output logic [15 : 0] z80fi_mem_addr,   \
output logic [15 : 0] z80fi_mem_addr2,  \
output logic [0  : 0] z80fi_mem_rd,     \
output logic [7  : 0] z80fi_mem_rdata,  \
output logic [0  : 0] z80fi_mem_rd2,    \
output logic [7  : 0] z80fi_mem_rdata2, \
output logic [0  : 0] z80fi_mem_wr,     \
output logic [7  : 0] z80fi_mem_wdata

`define Z80FI_WIRES \
wire [0  : 0] z80fi_valid;      \
wire [31 : 0] z80fi_insn;       \
wire [2  : 0] z80fi_insn_len;   \
wire [15 : 0] z80fi_pc_rdata;   \
wire [15 : 0] z80fi_pc_wdata;   \
wire [0  : 0] z80fi_reg1_rd;    \
wire [0  : 0] z80fi_reg2_rd;    \
wire [3  : 0] z80fi_reg1_rnum;  \
wire [3  : 0] z80fi_reg2_rnum;  \
wire [15 : 0] z80fi_reg1_rdata; \
wire [15 : 0] z80fi_reg2_rdata; \
wire [0  : 0] z80fi_reg_wr;     \
wire [3  : 0] z80fi_reg_wnum;   \
wire [15 : 0] z80fi_reg_wdata;  \
wire [15 : 0] z80fi_mem_addr;   \
wire [15 : 0] z80fi_mem_addr2;  \
wire [0  : 0] z80fi_mem_rd;     \
wire [7  : 0] z80fi_mem_rdata;  \
wire [0  : 0] z80fi_mem_rd2;    \
wire [7  : 0] z80fi_mem_rdata2; \
wire [0  : 0] z80fi_mem_wr;     \
wire [7  : 0] z80fi_mem_wdata;

`define Z80FI_NEXT_STATE \
logic [0  : 0] next_z80fi_valid;      \
logic [31 : 0] next_z80fi_insn;       \
logic [2  : 0] next_z80fi_insn_len;   \
logic [15 : 0] next_z80fi_pc_rdata;   \
logic [15 : 0] next_z80fi_pc_wdata;   \
logic [0  : 0] next_z80fi_reg1_rd;    \
logic [0  : 0] next_z80fi_reg2_rd;    \
logic [3  : 0] next_z80fi_reg1_rnum;  \
logic [3  : 0] next_z80fi_reg2_rnum;  \
logic [15 : 0] next_z80fi_reg1_rdata; \
logic [15 : 0] next_z80fi_reg2_rdata; \
logic [0  : 0] next_z80fi_reg_wr;     \
logic [3  : 0] next_z80fi_reg_wnum;   \
logic [15 : 0] next_z80fi_reg_wdata;  \
logic [15 : 0] next_z80fi_mem_addr;   \
logic [15 : 0] next_z80fi_mem_addr2;  \
logic [0  : 0] next_z80fi_mem_rd;     \
logic [7  : 0] next_z80fi_mem_rdata;  \
logic [0  : 0] next_z80fi_mem_rd2;    \
logic [7  : 0] next_z80fi_mem_rdata2; \
logic [0  : 0] next_z80fi_mem_wr;     \
logic [7  : 0] next_z80fi_mem_wdata;

`define Z80FI_RESET_STATE \
z80fi_valid <= 0;      \
z80fi_insn <= 0;       \
z80fi_insn_len <= 0;   \
z80fi_pc_rdata <= 0;   \
z80fi_pc_wdata <= 0;   \
z80fi_reg1_rd <= 0;    \
z80fi_reg2_rd <= 0;    \
z80fi_reg1_rnum <= 0;  \
z80fi_reg2_rnum <= 0;  \
z80fi_reg1_rdata <= 0; \
z80fi_reg2_rdata <= 0; \
z80fi_reg_wr <= 0;     \
z80fi_reg_wnum <= 0;   \
z80fi_reg_wdata <= 0;  \
z80fi_mem_addr <= 0;   \
z80fi_mem_addr2 <= 0;  \
z80fi_mem_rd <= 0;     \
z80fi_mem_rdata <= 0;  \
z80fi_mem_rd2 <= 0;    \
z80fi_mem_rdata2 <= 0; \
z80fi_mem_wr <= 0;     \
z80fi_mem_wdata <= 0;

`define Z80FI_LOAD_NEXT_STATE \
z80fi_valid <= next_z80fi_valid;           \
z80fi_insn <= next_z80fi_insn;             \
z80fi_insn_len <= next_z80fi_insn_len;     \
z80fi_pc_rdata <= next_z80fi_pc_rdata;     \
z80fi_pc_wdata <= next_z80fi_pc_wdata;     \
z80fi_reg1_rd <= next_z80fi_reg1_rd;       \
z80fi_reg2_rd <= next_z80fi_reg2_rd;       \
z80fi_reg1_rnum <= next_z80fi_reg1_rnum;   \
z80fi_reg2_rnum <= next_z80fi_reg2_rnum;   \
z80fi_reg1_rdata <= next_z80fi_reg1_rdata; \
z80fi_reg2_rdata <= next_z80fi_reg2_rdata; \
z80fi_reg_wr <= next_z80fi_reg_wr;         \
z80fi_reg_wnum <= next_z80fi_reg_wnum;     \
z80fi_reg_wdata <= next_z80fi_reg_wdata;   \
z80fi_mem_addr <= next_z80fi_mem_addr;     \
z80fi_mem_addr2 <= next_z80fi_mem_addr2;   \
z80fi_mem_rd <= next_z80fi_mem_rd;         \
z80fi_mem_rdata <= next_z80fi_mem_rdata;   \
z80fi_mem_rd2 <= next_z80fi_mem_rd2;       \
z80fi_mem_rdata2 <= next_z80fi_mem_rdata2; \
z80fi_mem_wr <= next_z80fi_mem_wr;         \
z80fi_mem_wdata <= next_z80fi_mem_wdata;

`define Z80FI_RETAIN_NEXT_STATE \
next_z80fi_valid = 0;                     \
next_z80fi_insn = z80fi_insn;             \
next_z80fi_insn_len = z80fi_insn_len;     \
next_z80fi_pc_rdata = z80fi_pc_rdata;     \
next_z80fi_pc_wdata = z80fi_pc_wdata;     \
next_z80fi_reg1_rd = z80fi_reg1_rd;       \
next_z80fi_reg2_rd = z80fi_reg2_rd;       \
next_z80fi_reg1_rnum = z80fi_reg1_rnum;   \
next_z80fi_reg2_rnum = z80fi_reg2_rnum;   \
next_z80fi_reg1_rdata = z80fi_reg1_rdata; \
next_z80fi_reg2_rdata = z80fi_reg2_rdata; \
next_z80fi_reg_wr = z80fi_reg_wr;         \
next_z80fi_reg_wnum = z80fi_reg_wnum;     \
next_z80fi_reg_wdata = z80fi_reg_wdata;   \
next_z80fi_mem_addr = z80fi_mem_addr;     \
next_z80fi_mem_addr2 = z80fi_mem_addr2;   \
next_z80fi_mem_rd = z80fi_mem_rd;         \
next_z80fi_mem_rdata = z80fi_mem_rdata;   \
next_z80fi_mem_rd2 = z80fi_mem_rd2;       \
next_z80fi_mem_rdata2 = z80fi_mem_rdata2; \
next_z80fi_mem_wr = z80fi_mem_wr;         \
next_z80fi_mem_wdata = z80fi_mem_wdata;

`define Z80FI_INIT_NEXT_STATE \
next_z80fi_valid = 0;      \
next_z80fi_insn = 0;       \
next_z80fi_insn_len = 0;   \
next_z80fi_pc_rdata = 0;   \
next_z80fi_pc_wdata = 0;   \
next_z80fi_reg1_rd = 0;    \
next_z80fi_reg2_rd = 0;    \
next_z80fi_reg1_rnum = 0;  \
next_z80fi_reg2_rnum = 0;  \
next_z80fi_reg1_rdata = 0; \
next_z80fi_reg2_rdata = 0; \
next_z80fi_reg_wr = 0;     \
next_z80fi_reg_wnum = 0;   \
next_z80fi_reg_wdata = 0;  \
next_z80fi_mem_addr = 0;   \
next_z80fi_mem_addr2 = 0;  \
next_z80fi_mem_rd = 0;     \
next_z80fi_mem_rdata = 0;  \
next_z80fi_mem_rd2 = 0;    \
next_z80fi_mem_rdata2 = 0; \
next_z80fi_mem_wr = 0;     \
next_z80fi_mem_wdata = 0;

`define Z80FI_CONN \
.z80fi_valid      (z80fi_valid),      \
.z80fi_insn       (z80fi_insn),       \
.z80fi_insn_len   (z80fi_insn_len),   \
.z80fi_pc_rdata   (z80fi_pc_rdata),   \
.z80fi_pc_wdata   (z80fi_pc_wdata),   \
.z80fi_reg1_rd    (z80fi_reg1_rd),    \
.z80fi_reg2_rd    (z80fi_reg2_rd),    \
.z80fi_reg1_rnum  (z80fi_reg1_rnum),  \
.z80fi_reg2_rnum  (z80fi_reg2_rnum),  \
.z80fi_reg1_rdata (z80fi_reg1_rdata), \
.z80fi_reg2_rdata (z80fi_reg2_rdata), \
.z80fi_reg_wr     (z80fi_reg_wr),     \
.z80fi_reg_wnum   (z80fi_reg_wnum),   \
.z80fi_reg_wdata  (z80fi_reg_wdata),  \
.z80fi_mem_addr   (z80fi_mem_addr),   \
.z80fi_mem_addr2  (z80fi_mem_addr2),  \
.z80fi_mem_rd     (z80fi_mem_rd),     \
.z80fi_mem_rdata  (z80fi_mem_rdata),  \
.z80fi_mem_rd2    (z80fi_mem_rd2),    \
.z80fi_mem_rdata2 (z80fi_mem_rdata2), \
.z80fi_mem_wr     (z80fi_mem_wr),     \
.z80fi_mem_wdata  (z80fi_mem_wdata)

// Used as the module i/o for z80fi_insn_* modules

`define Z80FI_INSN_SPEC_IO \
input z80fi_valid,                 \
input [31:0] z80fi_insn,           \
input [2:0] z80fi_insn_len,        \
input [15:0] z80fi_pc_rdata,       \
input [15:0] z80fi_reg1_rdata,     \
input [15:0] z80fi_reg2_rdata,     \
input [7:0] z80fi_mem_rdata,      \
input [7:0] z80fi_mem_rdata2,     \
                                   \
output spec_valid,                 \
output spec_reg1_rd,               \
output `reg_select spec_reg1_rnum, \
output spec_reg2_rd,               \
output `reg_select spec_reg2_rnum, \
output spec_reg_wr,                \
output `reg_select spec_reg_wnum,  \
output [15:0] spec_reg_wdata,      \
output [15:0] spec_pc_wdata,       \
output [15:0] spec_mem_addr,       \
output [15:0] spec_mem_addr2,      \
output spec_mem_rd,                \
output spec_mem_rd2,               \
output spec_mem_wr,                \
output [7:0] spec_mem_wdata

`endif // _z80fi_vh_
