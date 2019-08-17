// JR e
//
// Jumps to the given relative address (relative to just after the insn).

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_jr(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] e         = z80fi_insn[15:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[7:0] == 8'b00011000;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP;

wire [15:0] offset = { {8{e[7]}}, e};
assign spec_reg_ip_out = z80fi_reg_ip_in + 16'h2 + offset;

endmodule