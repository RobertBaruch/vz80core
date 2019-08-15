// JP nn
//
// Jumps to the given address.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_jp(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] insn_fixed1 = z80fi_insn[7:0];
wire [15:0] nn         = z80fi_insn[23:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    insn_fixed1 == 8'hC3;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP;

assign spec_reg_ip_out = nn;

endmodule