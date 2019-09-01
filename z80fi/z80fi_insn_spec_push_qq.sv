// PUSH qq
//
// Pushes 2 bytes onto the stack from the register pair qq.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_push_qq(
    `Z80FI_INSN_SPEC_IO
);

wire [1:0] qq          = z80fi_insn[5:4];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b11??0101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_SP |
    `SPEC_MEM_WR | `SPEC_MEM_WR2;

wire [15:0] wdata =
    (qq == `REG_BC) ? z80fi_reg_bc_in :
    (qq == `REG_DE) ? z80fi_reg_de_in :
    (qq == `REG_HL) ? z80fi_reg_hl_in :
    (qq == `REG_AF) ? z80fi_reg_af_in : 0;

assign spec_bus_waddr = z80fi_reg_sp_in - 16'h1;
assign spec_bus_waddr2 = z80fi_reg_sp_in - 16'h2;
assign spec_bus_wdata = wdata[15:8];
assign spec_bus_wdata2 = wdata[7:0];
assign spec_reg_sp_out = z80fi_reg_sp_in - 16'h2;

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_EXTENDED;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type5 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 1;
assign spec_tcycles3 = 3;
assign spec_tcycles4 = 3;

endmodule