// RETN
//
// Jumps to the 16-bit address popped from the stack, and
// copy IFF2 into IFF1.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_retn(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b01000101_11101101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_SP |
    `SPEC_MEM_RD | `SPEC_MEM_RD2 | `SPEC_REG_IFF1;

assign spec_bus_raddr = z80fi_reg_sp_in;
assign spec_bus_raddr2 = z80fi_reg_sp_in + 16'h1;
assign spec_reg_sp_out = z80fi_reg_sp_in + 16'h2;
assign spec_reg_iff1_out = z80fi_reg_iff2_in;
assign spec_reg_ip_out = {z80fi_bus_rdata2, z80fi_bus_rdata};

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type5 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;
assign spec_tcycles3 = 3;
assign spec_tcycles4 = 3;

endmodule