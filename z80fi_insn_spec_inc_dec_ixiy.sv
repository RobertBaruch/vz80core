// INC/DEC IX/IY
//
// Increment or decrement IX or IY.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_inc_dec_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire [3:0] insn_fixed1 = z80fi_insn[15:12];
wire       dec         = z80fi_insn[11];
wire [2:0] insn_fixed2 = z80fi_insn[10:8];
wire [1:0] insn_fixed3 = z80fi_insn[7:6];
wire       iy          = z80fi_insn[5];
wire [4:0] insn_fixed4 = z80fi_insn[4:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    insn_fixed1 == 4'b0010 &&
    insn_fixed2 == 3'b011 &&
    insn_fixed3 == 2'b11 &&
    insn_fixed4 == 5'b11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_IX | `SPEC_REG_IY;

wire [15:0] operand = dec ? 16'hFFFF : 16'h1;
wire [15:0] result = (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) + operand;

assign spec_reg_ix_out = iy ? z80fi_reg_ix_in : result;
assign spec_reg_iy_out = iy ? result : z80fi_reg_iy_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule