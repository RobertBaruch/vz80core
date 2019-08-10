// EX (SP), HL
//
// Exchanges HL with the two bytes at memory location SP.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ex_ind_sp_hl(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'hE3;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_HL |
    `SPEC_MEM_RD | `SPEC_MEM_RD2 | `SPEC_MEM_WR | `SPEC_MEM_WR2;

assign spec_mem_raddr = z80fi_reg_sp_in;
assign spec_mem_raddr2 = z80fi_reg_sp_in + 1;
assign spec_mem_waddr = z80fi_reg_sp_in;
assign spec_mem_waddr2 = z80fi_reg_sp_in + 1;
assign spec_mem_wdata = z80fi_reg_l_in;
assign spec_mem_wdata2 = z80fi_reg_h_in;

assign spec_reg_h_out = z80fi_mem_rdata2;
assign spec_reg_l_out = z80fi_mem_rdata;

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

endmodule