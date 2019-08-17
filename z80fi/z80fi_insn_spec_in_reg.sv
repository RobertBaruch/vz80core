// IN r, (C)
//
// Reads a byte from the I/O port in register C and writes it to
// the given register. The high byte of the address output is the
// contents of register B, while the low byte is register C.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_in_reg(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] r = z80fi_insn[13:11];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b01???000_11101101 &&
    r != 6;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP |
    `SPEC_REG_AF | `SPEC_REG_BC | `SPEC_REG_DE | `SPEC_REG_HL |
    `SPEC_IO_RD;

assign spec_bus_raddr = z80fi_reg_bc_in;

assign spec_reg_a_out = (r == `REG_A) ? z80fi_bus_rdata : z80fi_reg_a_in;
assign spec_reg_b_out = (r == `REG_B) ? z80fi_bus_rdata : z80fi_reg_b_in;
assign spec_reg_c_out = (r == `REG_C) ? z80fi_bus_rdata : z80fi_reg_c_in;
assign spec_reg_d_out = (r == `REG_D) ? z80fi_bus_rdata : z80fi_reg_d_in;
assign spec_reg_e_out = (r == `REG_E) ? z80fi_bus_rdata : z80fi_reg_e_in;
assign spec_reg_h_out = (r == `REG_H) ? z80fi_bus_rdata : z80fi_reg_h_in;
assign spec_reg_l_out = (r == `REG_L) ? z80fi_bus_rdata : z80fi_reg_l_in;

wire flag_s = z80fi_bus_rdata[7];
wire flag_z = (z80fi_bus_rdata == 0);
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = 0;
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = parity8(z80fi_bus_rdata);
wire flag_n = 0;
wire flag_c = z80fi_reg_f_in[`FLAG_C_NUM];

assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};
assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule