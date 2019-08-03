// Covers the 16-bit load group LD dd, nn instruction.
// This must write nn to 16-bit register pair dd. nn is ordered
// little-endian.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_dd_immed(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] nn          = z80fi_insn[23:8];
wire [1:0]  insn_fixed1 = z80fi_insn[7:6];
wire [1:0]  dd          = z80fi_insn[5:4];
wire [3:0]  insn_fixed2 = z80fi_insn[3:0];

// LD dd, nn instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    insn_fixed1 == 2'b00 &&
    insn_fixed2 == 4'b0001;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_WR;

// Data for 1's above.
assign spec_reg_wnum = {2'b10, dd};
assign spec_reg_wdata = nn;

assign spec_pc_wdata = z80fi_pc_rdata + 3;

endmodule