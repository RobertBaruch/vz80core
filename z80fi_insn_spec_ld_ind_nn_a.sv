// LD (nn), A
//
// This must read register A and write its value to
// memory location nn. nn is ordered little-endian.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_ind_nn_a(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] addr = z80fi_insn[23:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    z80fi_insn[7:0] == 8'b00110010;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_MEM_WR;

assign spec_mem_waddr = addr;
assign spec_mem_wdata = z80fi_reg_a_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 3;

endmodule