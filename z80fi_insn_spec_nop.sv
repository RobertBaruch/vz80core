// NOP

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_nop(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] insn_fixed1 = z80fi_insn[7:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    insn_fixed1 == 8'h00;

`Z80FI_SPEC_SIGNALS
assign spec_signals = 0;

assign spec_pc_wdata = z80fi_pc_rdata + 1;

endmodule