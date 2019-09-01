// POP IX/IY
//
// Pops 2 bytes off the stack and puts them in IX/IY.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_pop_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire [0:0] iy          = z80fi_insn[5];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b11100001_11?11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_SP |
    `SPEC_REG_IX | `SPEC_REG_IY | `SPEC_MEM_RD | `SPEC_MEM_RD2;

wire [15:0] data = {z80fi_bus_rdata2, z80fi_bus_rdata};

assign spec_bus_raddr = z80fi_reg_sp_in;
assign spec_bus_raddr2 = z80fi_reg_sp_in + 16'h1;
assign spec_reg_sp_out = z80fi_reg_sp_in + 16'h2;
assign spec_reg_ix_out = iy ? z80fi_reg_ix_in : data;
assign spec_reg_iy_out = iy ? data : z80fi_reg_iy_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

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