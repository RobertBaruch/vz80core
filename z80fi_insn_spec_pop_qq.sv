// POP qq
//
// Pops 2 bytes off the stack and puts them in the
// register pair qq.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_pop_qq(
    `Z80FI_INSN_SPEC_IO
);

wire [1:0] qq          = z80fi_insn[5:4];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b11??0001;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_SP |
    `SPEC_REG_AF | `SPEC_REG_BC | `SPEC_REG_DE | `SPEC_REG_HL |
    `SPEC_MEM_RD | `SPEC_MEM_RD2;

wire [15:0] data = {z80fi_mem_rdata2, z80fi_mem_rdata};

assign spec_mem_raddr = z80fi_reg_sp_in;
assign spec_mem_raddr2 = z80fi_reg_sp_in + 1;
assign spec_reg_sp_out = z80fi_reg_sp_in + 2;
assign spec_reg_b_out = (qq == `REG_BC) ? data[15:8] : z80fi_reg_b_in;
assign spec_reg_c_out = (qq == `REG_BC) ? data[7:0] : z80fi_reg_c_in;
assign spec_reg_d_out = (qq == `REG_DE) ? data[15:8] : z80fi_reg_d_in;
assign spec_reg_e_out = (qq == `REG_DE) ? data[7:0] : z80fi_reg_e_in;
assign spec_reg_h_out = (qq == `REG_HL) ? data[15:8] : z80fi_reg_h_in;
assign spec_reg_l_out = (qq == `REG_HL) ? data[7:0] : z80fi_reg_l_in;
assign spec_reg_a_out = (qq == `REG_AF) ? data[15:8] : z80fi_reg_a_in;
assign spec_reg_f_out = (qq == `REG_AF) ? data[7:0] : z80fi_reg_f_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

endmodule