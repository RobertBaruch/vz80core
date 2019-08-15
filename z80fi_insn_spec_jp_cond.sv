// JP CC, nn
//
// Jumps to the given absolute address on the given condition.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_jp_cond(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] cond        = z80fi_insn[5:3];
wire [15:0] nn         = z80fi_insn[23:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    z80fi_insn[7:0] == 8'b11???010;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP;

wire [3:0] flagnum =
    (cond == 0 || cond == 1) ? `FLAG_Z_NUM :
    (cond == 0 || cond == 1) ? `FLAG_C_NUM :
    (cond == 0 || cond == 1) ? `FLAG_PV_NUM :
    (cond == 0 || cond == 1) ? `FLAG_S_NUM : 0;
wire want = cond[0];

assign spec_reg_ip_out =
    z80fi_reg_f_in[flagnum] == want ? nn : z80fi_reg_ip_in + 3;

endmodule