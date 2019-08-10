// CPIR
//
// Set the flags based on A minus the byte at memory address HL, then
// increment HL and decrement BC. Set the P/V flag if BC != 0 after
// decrementing. Flags H and N are reset. Repeat the instruction
// if BC != 0 after decrementing.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_cpir(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] insn_fixed1 = z80fi_insn[15:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    insn_fixed1 == 16'hB1ED;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_BC |
    `SPEC_REG_HL | `SPEC_REG_F | `SPEC_MEM_RD;

wire [7:0] sub = z80fi_reg_a_in - z80fi_mem_rdata;
wire flag_s = sub[7];
wire flag_z = (sub == 0);
wire flag_5 = (z80fi_reg_f_in & `FLAG_5_BIT) != 0;
wire flag_h = halfcarry8(z80fi_reg_a_in, ~z80fi_mem_rdata, 1);
wire flag_3 = (z80fi_reg_f_in & `FLAG_3_BIT) != 0;
wire flag_v = z80fi_reg_bc_in != 16'b1;
wire flag_n = 1;
wire flag_c = (z80fi_reg_f_in & `FLAG_C_BIT) != 0;

assign spec_mem_raddr = z80fi_reg_hl_in;
assign {spec_reg_b_out, spec_reg_c_out} = z80fi_reg_bc_in - 16'h1;
assign {spec_reg_h_out, spec_reg_l_out} = z80fi_reg_hl_in + 16'h1;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + (z80fi_reg_bc_in == 1 ? 16'h2 : 0);

endmodule