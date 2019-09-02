// CPD
//
// Set the flags based on A minus the byte at memory address HL, then
// decrement HL and BC. Set the P/V flag if BC != 0 after
// decrementing. Flags H and N are reset.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_cpd(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b10101001_11101101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_BC |
    `SPEC_REG_HL | `SPEC_REG_F | `SPEC_MEM_RD;

wire [7:0] sub = z80fi_reg_a_in - z80fi_bus_rdata;
wire flag_s = sub[7];
wire flag_z = (sub == 0);
wire flag_5 = (z80fi_reg_f_in & `FLAG_5_BIT) != 0;
wire flag_h = halfcarry8(z80fi_reg_a_in, ~z80fi_bus_rdata, 1);
wire flag_3 = (z80fi_reg_f_in & `FLAG_3_BIT) != 0;
wire flag_v = z80fi_reg_bc_in != 16'b1;
wire flag_n = 1;
wire flag_c = (z80fi_reg_f_in & `FLAG_C_BIT) != 0;

assign spec_bus_raddr = z80fi_reg_hl_in;
assign {spec_reg_b_out, spec_reg_c_out} = z80fi_reg_bc_in - 16'h1;
assign {spec_reg_h_out, spec_reg_l_out} = z80fi_reg_hl_in - 16'h1;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_INTERNAL;
assign spec_mcycle_type5 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;
assign spec_tcycles3 = 3;
assign spec_tcycles4 = 5;

endmodule