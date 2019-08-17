// LD (HL), n
//
// This must write n to the memory address stored in HL.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_ind_hl_n(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] n           = z80fi_insn[15:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[7:0] == 8'b00110110;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_MEM_WR;

assign spec_bus_waddr = z80fi_reg_hl_in;
assign spec_bus_wdata = n;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule