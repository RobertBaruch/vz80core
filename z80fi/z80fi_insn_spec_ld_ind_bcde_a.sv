// LD (BC/DE), A
//
// This must write A to the memory address stored in BC or DE.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_ind_bcde_a(
    `Z80FI_INSN_SPEC_IO
);

wire de           = z80fi_insn[4];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b000?0010;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP |`SPEC_MEM_WR;

assign spec_bus_waddr = de ? z80fi_reg_de_in : z80fi_reg_bc_in;
assign spec_bus_wdata = z80fi_reg_a_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type3 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 3;

endmodule