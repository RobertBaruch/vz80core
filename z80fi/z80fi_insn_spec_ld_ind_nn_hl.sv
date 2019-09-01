// LD (nn), HL
//
// This must read register pair HL and write its value to
// memory location nn. nn is ordered little-endian.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_ind_nn_hl(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] nn         = z80fi_insn[23:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    z80fi_insn[7:0] == 8'b00100010;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_MEM_WR | `SPEC_MEM_WR2;

assign spec_bus_waddr = nn;
assign spec_bus_waddr2 = nn + 1;
assign spec_bus_wdata = z80fi_reg_l_in;
assign spec_bus_wdata2 = z80fi_reg_h_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 3;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type5 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type6 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 3;
assign spec_tcycles3 = 3;
assign spec_tcycles4 = 3;
assign spec_tcycles5 = 3;

endmodule