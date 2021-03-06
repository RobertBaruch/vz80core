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

`include "z80fi_signals.vh"

`define SPEC_REG_BC (`SPEC_REG_B | `SPEC_REG_C)
`define SPEC_REG_DE (`SPEC_REG_D | `SPEC_REG_E)
`define SPEC_REG_HL (`SPEC_REG_H | `SPEC_REG_L)
`define SPEC_REG_AF (`SPEC_REG_A | `SPEC_REG_F)
`define SPEC_REG_BC2 (`SPEC_REG_B2 | `SPEC_REG_C2)
`define SPEC_REG_DE2 (`SPEC_REG_D2 | `SPEC_REG_E2)
`define SPEC_REG_HL2 (`SPEC_REG_H2 | `SPEC_REG_L2)
`define SPEC_REG_AF2 (`SPEC_REG_A2 | `SPEC_REG_F2)

// Functions useful for checking flags

// Parity is set if parity is even (i.e. 0).
function parity8(input [7:0] x);
  parity8 = ~(x[0] ^ x[1] ^ x[2] ^ x[3] ^ x[4] ^ x[5] ^ x[6] ^ x[7]);
endfunction

function halfcarry8(input [7:0] x, input [7:0] y, input carry);
  reg [4:0] out;
  out = x[3:0] + y[3:0] + carry;
  halfcarry8 = out[4];
endfunction

function carry8(input [7:0] x, input [7:0] y, input carry);
  reg [8:0] out;
  out = x + y + carry;
  carry8 = out[8];
endfunction

function overflow8(input [7:0] x, input [7:0] y, input carry);
  reg [7:0] out;
  out = x[6:0] + y[6:0] + carry;
  overflow8 = carry8(x, y, carry) ^ out[7];
endfunction

function halfcarry16(input [15:0] x, input [15:0] y, input carry);
  reg [12:0] out;
  out = x[11:0] + y[11:0] + carry;
  halfcarry16 = out[12];
endfunction

function carry16(input [15:0] x, input [15:0] y, input carry);
  reg [16:0] out;
  out = x + y + carry;
  carry16 = out[16];
endfunction

function overflow16(input [15:0] x, input [15:0] y, input carry);
  reg [15:0] out;
  out = x[14:0] + y[14:0] + carry;
  overflow16 = carry16(x, y, carry) ^ out[15];
endfunction

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
// z80fi_mem_(r/w)addr(2), z80fi_mem_rd(2), z80fi_mem_wr(2), z80fi_bus_rdata(2), z80fi_bus_wdata(2):
//   If the instruction did not read from memory (ignoring reads of instruction data)
//   then z80fi_mem_rd is zero. If the instruction did not write memory, z80fi_mem_wr
//   is zero. If memory was read or written, z80fi_mem_addr is the address location
//   accessed, or an arbitrary value otherwise. z80fi_bus_rdata is the contents of the
//   memory location just prior to the instruction starting, or an arbitrary value if
//   memory was not read. z80fi_bus_wdata is the data written to memory, or an
//   arbitrary value if memory was not written.
//   z80fi_mem_rd is for the first read. If there was a second read, use z80_fi_mem_rd2/
//   z80fi_mem_addr2/z80fi_bus_rdata2.
// z80fi_rd/i_wr/r/f, z80fi_i/r/f_r/wdata:
//   As expected, for reading and writing the I, R and Flags registers.
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

`endif // _z80fi_vh_
