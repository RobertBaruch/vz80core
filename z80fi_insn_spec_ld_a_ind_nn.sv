// LD A, (nn)
//
// This must read memory location nn and write its value to
// register A. nn is ordered little-endian.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_a_ind_nn(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] addr = z80fi_insn[23:8];

// LD A, (nn) instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    z80fi_insn[7:0] == 8'b00111010;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_A | `SPEC_MEM_RD;

assign spec_reg_a_out = z80fi_mem_rdata;
assign spec_reg_ip_out = z80fi_reg_ip_in + 3;

assign spec_mem_raddr = addr;

endmodule