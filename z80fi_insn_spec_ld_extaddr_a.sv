// Covers the 8-bit load group LD (nn), A instruction.
// This must read register A and write its value to
// memory location nn. nn is ordered little-endian.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_extaddr_a(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] insn_fixed = z80fi_insn[7:0];
wire [15:0] addr = z80fi_insn[23:8];

// LD A, (nn) instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    insn_fixed == 8'h32;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG1_RD | `SPEC_MEM_WR;

// Data for 1's above.
assign spec_reg1_rnum = `REG_A;

assign spec_mem_wr = 1;
assign spec_mem_waddr = addr;
assign spec_mem_wdata = {8'b0, z80fi_reg1_rdata};

assign spec_pc_wdata = z80fi_pc_rdata + 3;

endmodule