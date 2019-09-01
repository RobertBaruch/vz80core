// JR CC, e
//
// Jumps to the given absolute address on the given condition.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_jr_cond(
    `Z80FI_INSN_SPEC_IO
);

wire [1:0] cond        = z80fi_insn[4:3];
wire [7:0] e           = z80fi_insn[15:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[7:0] == 8'b001??000;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP;

wire [2:0] flagnum =
    (cond == 0 || cond == 1) ? `FLAG_Z_NUM :
    (cond == 2 || cond == 3) ? `FLAG_C_NUM : 0;
wire want = cond[0];
wire [15:0] offset = { {8{e[7]}}, e};

assign spec_reg_ip_out =
    z80fi_reg_ip_in + 16'h2 + ((z80fi_reg_f_in[flagnum] == want) ? offset : 0);

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type3 = (z80fi_reg_f_in[flagnum] == want) ? `CYCLE_INTERNAL : `CYCLE_NONE;
assign spec_mcycle_type4 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 3;
assign spec_tcycles3 = 5;

endmodule