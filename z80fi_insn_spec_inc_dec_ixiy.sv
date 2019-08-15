// INC/DEC IX/IY
//
// Increment or decrement IX or IY.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_inc_dec_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire       dec         = z80fi_insn[11];
wire       iy          = z80fi_insn[5];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b0010?011_11?11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_IX | `SPEC_REG_IY;

wire [15:0] operand = dec ? 16'hFFFF : 16'h1;
wire [15:0] result = (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) + operand;

assign spec_reg_ix_out = iy ? z80fi_reg_ix_in : result;
assign spec_reg_iy_out = iy ? result : z80fi_reg_iy_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule