// Covers the 16-bit load group LD HL, (nn) instruction.
// This must write register pair HL with the 16-bit value in
// memory location nn. nn is ordered little-endian.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_hl_extaddr(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] nn         = z80fi_insn[23:8];
wire [7:0] insn_fixed1 = z80fi_insn[7:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    insn_fixed1 == 8'h2A;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_WR | `SPEC_MEM_RD | `SPEC_MEM_RD2;

// Data for 1's above.
assign spec_reg_wnum = `REG_HL;
assign spec_reg_wdata = {z80fi_mem_rdata2, z80fi_mem_rdata};

assign spec_mem_raddr = nn;
assign spec_mem_raddr2 = nn + 1;

assign spec_pc_wdata = z80fi_pc_rdata + 3;

endmodule