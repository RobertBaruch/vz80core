// LD dd, (nn)
//
// This must read memory locations nn and nn+1 and write its value
// to 16-bit register pair dd. nn is ordered little-endian. The data
// is also little-endian, so for example the byte at memory location nn
// for writing to BC would go in C.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_dd_ind_nn(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] addr        = z80fi_insn[31:16];
wire [1:0]  dd          = z80fi_insn[13:12];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 4 &&
    z80fi_insn[15:0] == 16'b01??1011_11101101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP |
    `SPEC_REG_BC | `SPEC_REG_DE | `SPEC_REG_HL | `SPEC_REG_SP |
    `SPEC_MEM_RD | `SPEC_MEM_RD2;

assign spec_reg_b_out = (dd == `REG_BC) ? z80fi_bus_rdata2 : z80fi_reg_b_in;
assign spec_reg_c_out = (dd == `REG_BC) ? z80fi_bus_rdata : z80fi_reg_c_in;
assign spec_reg_d_out = (dd == `REG_DE) ? z80fi_bus_rdata2 : z80fi_reg_d_in;
assign spec_reg_e_out = (dd == `REG_DE) ? z80fi_bus_rdata : z80fi_reg_e_in;
assign spec_reg_h_out = (dd == `REG_HL) ? z80fi_bus_rdata2 : z80fi_reg_h_in;
assign spec_reg_l_out = (dd == `REG_HL) ? z80fi_bus_rdata : z80fi_reg_l_in;
assign spec_reg_sp_out = (dd == `REG_SP) ? {z80fi_bus_rdata2, z80fi_bus_rdata} : z80fi_reg_sp_in;
assign spec_reg_ip_out = z80fi_reg_ip_in + 4;

assign spec_bus_raddr = addr;
assign spec_bus_raddr2 = addr + 1;

endmodule