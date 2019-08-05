// LD r, n
//
// This must write n to 8-bit register r.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_reg_n(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] n            = z80fi_insn[15:8];
wire [1:0] insn_fixed1  = z80fi_insn[7:6];
wire [2:0] r            = z80fi_insn[5:3];
wire [2:0] insn_fixed2  = z80fi_insn[2:0];

// LD dd, nn instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    r != 3'b110 &&
    insn_fixed1 == 2'b00 &&
    insn_fixed2 == 3'b110;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_WR;

// Data for 1's above.
assign spec_reg_wnum = {1'b0, r};
assign spec_reg_wdata = {8'b0, n};

assign spec_pc_wdata = z80fi_pc_rdata + 2;

endmodule