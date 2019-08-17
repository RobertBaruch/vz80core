// LD SP, IX/IY
//
// Copies IX/IY into SP.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_sp_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire       iy          = z80fi_insn[5];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b11111001_11?11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_SP;

assign spec_reg_sp_out = iy ? z80fi_reg_iy_in : z80fi_reg_ix_in;
assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule