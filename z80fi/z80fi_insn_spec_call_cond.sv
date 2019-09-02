// CALL CC, nn
//
// Calls to the given absolute address if the given condition is
// satisfied: pushes the instruction pointer (pointing to after the
// instruction) onto the stack, and jumps to the given absolute address.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_call_cond(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] cond        = z80fi_insn[5:3];
wire [15:0] nn         = z80fi_insn[23:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    z80fi_insn[7:0] == 8'b11???100;

wire [2:0] flagnum =
    (cond == 0 || cond == 1) ? `FLAG_Z_NUM :
    (cond == 2 || cond == 3) ? `FLAG_C_NUM :
    (cond == 4 || cond == 5) ? `FLAG_PV_NUM :
    (cond == 6 || cond == 7) ? `FLAG_S_NUM : 0;
wire want = cond[0];
wire cond_met = (z80fi_reg_f_in[flagnum] == want);
wire [15:0] retaddr = z80fi_reg_ip_in + 16'h3;

`Z80FI_SPEC_SIGNALS
assign spec_signals = cond_met ?
    (`SPEC_REG_IP | `SPEC_REG_SP | `SPEC_MEM_WR | `SPEC_MEM_WR2) :
    `SPEC_REG_IP;

assign spec_bus_waddr = z80fi_reg_sp_in - 16'h1;
assign spec_bus_waddr2 = z80fi_reg_sp_in - 16'h2;
assign spec_bus_wdata = retaddr[15:8];
assign spec_bus_wdata2 = retaddr[7:0];
assign spec_reg_sp_out =
    z80fi_reg_sp_in - (cond_met ? 16'h2 : 0);
assign spec_reg_ip_out =
    cond_met ? nn : (z80fi_reg_ip_in + 16'h3);

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = cond_met ? `CYCLE_RDWR_MEM : `CYCLE_NONE;
assign spec_mcycle_type5 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type6 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 3;
assign spec_tcycles3 = cond_met ? 4 : 3;
assign spec_tcycles4 = 3;
assign spec_tcycles5 = 3;

endmodule