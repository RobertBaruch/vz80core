// EX (SP), IX/IY
//
// Exchanges IX/IY with the two bytes at memory location SP.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ex_ind_sp_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire iy                 = z80fi_insn[5];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b11100011_11?11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_IX | `SPEC_REG_IY |
    `SPEC_MEM_RD | `SPEC_MEM_RD2 | `SPEC_MEM_WR | `SPEC_MEM_WR2;

wire [15:0] wdata = iy ? z80fi_reg_iy_in : z80fi_reg_ix_in;

assign spec_bus_raddr = z80fi_reg_sp_in;
assign spec_bus_raddr2 = z80fi_reg_sp_in + 1;
assign spec_bus_waddr = z80fi_reg_sp_in + 1;
assign spec_bus_waddr2 = z80fi_reg_sp_in;
assign spec_bus_wdata = wdata[15:8];
assign spec_bus_wdata2 = wdata[7:0];

assign spec_reg_ix_out = iy ? z80fi_reg_ix_in : {z80fi_bus_rdata2, z80fi_bus_rdata};
assign spec_reg_iy_out = iy ? {z80fi_bus_rdata2, z80fi_bus_rdata} : z80fi_reg_iy_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_EXTENDED;
assign spec_mcycle_type5 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type6 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type7 = `CYCLE_EXTENDED;
assign spec_mcycle_type8 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type9 = `CYCLE_EXTENDED;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;
assign spec_tcycles3 = 3;
assign spec_tcycles4 = 1;
assign spec_tcycles5 = 3;
assign spec_tcycles6 = 3;
assign spec_tcycles7 = 1;
assign spec_tcycles8 = 3;
assign spec_tcycles9 = 1;

endmodule