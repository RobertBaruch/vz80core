// DJNZ e
//
// Decrements B, and if result is nonzero, jumps to the given
// relative address.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_djnz(
    `Z80FI_INSN_SPEC_IO
);

// Unlike all the other instructions, the operand is not included
// in the instruction data. This is because unlike any other instruction,
// the M1 cycle here lasts one extra T cycle before the operand is
// read. Since the sequencer reads operands automatically, we can't use
// that mechanism to make DJNZ's M1 cycle last an extra T cycle. So instead
// we treat the M2 cycle as a memory read instead of an operand read.
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b00010000;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_B | `SPEC_MEM_RD;

assign spec_bus_raddr = z80fi_reg_ip_in + 1;

wire [7:0] e = z80fi_bus_rdata;
wire [15:0] offset = { {8{e[7]}}, e};
assign spec_reg_b_out = z80fi_reg_b_in - 8'b1;

assign spec_reg_ip_out =
    z80fi_reg_ip_in + 16'h2 + ((z80fi_reg_b_in != 1) ? offset : 0);

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_EXTENDED;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = (z80fi_reg_b_in != 1) ? `CYCLE_INTERNAL : `CYCLE_NONE;
assign spec_mcycle_type5 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 1;
assign spec_tcycles3 = 3;
assign spec_tcycles4 = 5;

endmodule