// RET CC
//
// Jumps to the 16-bit address popped off the stack if the
// given condition is satisfied. If the condition is not
// satisfied, the stack is not popped.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ret_cond(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] cond        = z80fi_insn[5:3];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b11???000;

wire [2:0] flagnum =
    (cond == 0 || cond == 1) ? `FLAG_Z_NUM :
    (cond == 2 || cond == 3) ? `FLAG_C_NUM :
    (cond == 4 || cond == 5) ? `FLAG_PV_NUM :
    (cond == 6 || cond == 7) ? `FLAG_S_NUM : 0;
wire want = cond[0];
wire cond_met = (z80fi_reg_f_in[flagnum] == want);

`Z80FI_SPEC_SIGNALS
assign spec_signals = cond_met ?
    (`SPEC_REG_IP | `SPEC_REG_SP | `SPEC_MEM_RD | `SPEC_MEM_RD2) :
    `SPEC_REG_IP;

assign spec_bus_raddr = z80fi_reg_sp_in;
assign spec_bus_raddr2 = z80fi_reg_sp_in + 16'h1;
assign spec_reg_sp_out =
    z80fi_reg_sp_in + (cond_met ? 16'h2 : 16'h0);
assign spec_reg_ip_out =
    cond_met ? {z80fi_bus_rdata2, z80fi_bus_rdata} :
    (z80fi_reg_ip_in + 16'h1);

endmodule