// PUSH IX/IY
//
// Pushes IX/IY onto the stack.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_push_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire [0:0] iy          = z80fi_insn[5];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b11100101_11?11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_SP |
    `SPEC_MEM_WR | `SPEC_MEM_WR2;

wire [15:0] wdata = iy ? z80fi_reg_iy_in : z80fi_reg_ix_in;

assign spec_bus_waddr = z80fi_reg_sp_in - 16'h1;
assign spec_bus_waddr2 = z80fi_reg_sp_in - 16'h2;
assign spec_bus_wdata = wdata[15:8];
assign spec_bus_wdata2 = wdata[7:0];
assign spec_reg_sp_out = z80fi_reg_sp_in - 16'h2;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_EXTENDED;
assign spec_mcycle_type4 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type5 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type6 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;
assign spec_tcycles3 = 1;
assign spec_tcycles4 = 3;
assign spec_tcycles5 = 3;

endmodule