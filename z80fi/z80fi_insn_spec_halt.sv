// HALT
//
// Just spin, doing nothing, until interrupt or reset.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_halt(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b01110110;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP;

assign spec_reg_ip_out = z80fi_reg_ip_in;

endmodule