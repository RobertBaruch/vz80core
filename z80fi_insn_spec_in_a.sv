// IN A, (n)
//
// Reads a byte from I/O port n and writes it to register A.
// The high byte of the address output is the contents of A,
// while the low byte is n.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_in_a(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] n = z80fi_insn[15:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[7:0] == 8'b11011011;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_A | `SPEC_IO_RD;

assign spec_bus_raddr = {z80fi_reg_a_in, n};

assign spec_reg_a_out = z80fi_bus_rdata;
assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule