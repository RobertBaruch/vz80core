// LD (nn), IX/IY
//
// This must read register pair IX/IY and write its value to
// memory location nn. nn is ordered little-endian.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_ind_nn_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] nn         = z80fi_insn[31:16];
wire       iy          = z80fi_insn[5];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 4 &&
    z80fi_insn[15:0] == 16'b00100010_11?11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_MEM_WR | `SPEC_MEM_WR2;

assign spec_bus_waddr = nn;
assign spec_bus_waddr2 = nn + 1;
assign spec_bus_wdata = iy ? z80fi_reg_iy_in[7:0] : z80fi_reg_ix_in[7:0];
assign spec_bus_wdata2 = iy ? z80fi_reg_iy_in[15:8] : z80fi_reg_ix_in[15:8];

assign spec_reg_ip_out = z80fi_reg_ip_in + 4;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type5 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type6 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type7 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;
assign spec_tcycles3 = 3;
assign spec_tcycles4 = 3;
assign spec_tcycles5 = 3;
assign spec_tcycles6 = 3;

endmodule