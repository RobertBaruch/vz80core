// OUT (C), r
//
// Writes a byte to the I/O port in register C from
// the given register. The high byte of the address output is the
// contents of register B, while the low byte is register C.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_out_reg(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] r = z80fi_insn[13:11];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b01???001_11101101 &&
    r != 6;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_IO_WR;

assign spec_bus_waddr = z80fi_reg_bc_in;
assign spec_bus_wdata =
    (r == `REG_A) ? z80fi_reg_a_in :
    (r == `REG_B) ? z80fi_reg_b_in :
    (r == `REG_C) ? z80fi_reg_c_in :
    (r == `REG_D) ? z80fi_reg_d_in :
    (r == `REG_E) ? z80fi_reg_e_in :
    (r == `REG_H) ? z80fi_reg_h_in :
    (r == `REG_L) ? z80fi_reg_l_in : 0;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule