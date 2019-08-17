// LDIR
//
// Load the byte at memory address HL and put it in the memory address
// at DE, then increment HL and DE, and decrement BC. Set the P/V flag
// if BC != 0 after decrementing. Flags H and N are reset. Repeat the
// instruction if BC != 0 after decrementing.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ldir(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b10110000_11101101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_BC | `SPEC_REG_DE |
    `SPEC_REG_HL | `SPEC_REG_F | `SPEC_MEM_RD | `SPEC_MEM_WR;

assign spec_bus_raddr = z80fi_reg_hl_in;
assign spec_bus_waddr = z80fi_reg_de_in;
assign spec_bus_wdata = z80fi_bus_rdata;
assign {spec_reg_b_out, spec_reg_c_out} = z80fi_reg_bc_in - 16'h1;
assign {spec_reg_d_out, spec_reg_e_out} = z80fi_reg_de_in + 16'h1;
assign {spec_reg_h_out, spec_reg_l_out} = z80fi_reg_hl_in + 16'h1;
assign spec_reg_f_out =
    (z80fi_reg_f_in & `FLAG_H_MASK & `FLAG_N_MASK & `FLAG_PV_MASK) |
    (z80fi_reg_bc_in == 1 ? 0 : `FLAG_PV_BIT);

assign spec_reg_ip_out = z80fi_reg_ip_in + (z80fi_reg_bc_in == 1 ? 16'h2 : 0);

endmodule