// LD A, (BC/DE)
//
// This must write A with  the contents of the memory address
// stored in BC or DE.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_a_ind_bcde(
    `Z80FI_INSN_SPEC_IO
);

wire [0:0] de           = z80fi_insn[4:4];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b000?1010;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_A | `SPEC_MEM_RD;

assign spec_reg_a_out = z80fi_bus_rdata;
assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

assign spec_bus_raddr = de ? {z80fi_reg_d_in, z80fi_reg_e_in} :
    {z80fi_reg_b_in, z80fi_reg_c_in};

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type3 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 3;

endmodule