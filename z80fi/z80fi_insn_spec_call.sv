// CALL nn
//
// Calls to the given absolute address: pushes the instruction pointer
// (pointing to after the instruction) onto the stack, and jumps to the
// given absolute address.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_call(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] nn         = z80fi_insn[23:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    z80fi_insn[7:0] == 8'b11001101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_SP |
    `SPEC_MEM_WR | `SPEC_MEM_WR2;

wire [15:0] retaddr = z80fi_reg_ip_in + 16'h3;

assign spec_bus_waddr = z80fi_reg_sp_in - 16'h1;
assign spec_bus_waddr2 = z80fi_reg_sp_in - 16'h2;
assign spec_bus_wdata = retaddr[15:8];
assign spec_bus_wdata2 = retaddr[7:0];
assign spec_reg_sp_out = z80fi_reg_sp_in - 16'h2;
assign spec_reg_ip_out = nn;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_EXTENDED;
assign spec_mcycle_type5 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type6 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type7 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 3;
assign spec_tcycles3 = 3;
assign spec_tcycles4 = 1;
assign spec_tcycles5 = 3;
assign spec_tcycles6 = 3;

endmodule