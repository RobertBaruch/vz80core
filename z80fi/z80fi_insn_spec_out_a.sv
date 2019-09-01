// OUT (n), A
//
// Writes a byte to I/O port n from register A.
// The high byte of the address output is the contents of A,
// while the low byte is n.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_out_a(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] n = z80fi_insn[15:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[7:0] == 8'b11010011;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_IO_WR;

assign spec_bus_waddr = {z80fi_reg_a_in, n};
assign spec_bus_wdata = z80fi_reg_a_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type3 = `CYCLE_RDWR_IO;
assign spec_mcycle_type4 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 3;
assign spec_tcycles3 = 4;

endmodule