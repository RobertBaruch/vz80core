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
// z80fi_mem_(r/w)addr(2), z80fi_mem_rd(2), z80fi_mem_wr(2), z80fi_mem_rdata(2), z80fi_mem_wdata(2):
//   If the instruction did not read from memory (ignoring reads of instruction data)
//   then z80fi_mem_rd is zero. If the instruction did not write memory, z80fi_mem_wr
//   is zero. If memory was read or written, z80fi_mem_addr is the address location
//   accessed, or an arbitrary value otherwise. z80fi_mem_rdata is the contents of the
//   memory location just prior to the instruction starting, or an arbitrary value if
//   memory was not read. z80fi_mem_wdata is the data written to memory, or an
//   arbitrary value if memory was not written.
//   z80fi_mem_rd is for the first read. If there was a second read, use z80_fi_mem_rd2/
//   z80fi_mem_addr2/z80fi_mem_rdata2.
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
