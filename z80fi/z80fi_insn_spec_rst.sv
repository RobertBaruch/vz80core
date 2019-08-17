// RST p
//
// Calls to the address p * 8.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_rst(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] p = z80fi_insn[5:3];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b11???111;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_SP |
    `SPEC_MEM_WR | `SPEC_MEM_WR2;

wire [15:0] retaddr = z80fi_reg_ip_in + 16'h1;

assign spec_bus_waddr = z80fi_reg_sp_in - 16'h1;
assign spec_bus_waddr2 = z80fi_reg_sp_in - 16'h2;
assign spec_bus_wdata = retaddr[15:8];
assign spec_bus_wdata2 = retaddr[7:0];
assign spec_reg_sp_out = z80fi_reg_sp_in - 16'h2;
assign spec_reg_ip_out = {p, 3'b000};

endmodule