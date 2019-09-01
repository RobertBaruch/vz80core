// CPL
//
// Complement A.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_cpl(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b00101111;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_AF;

wire [7:0] result = ~z80fi_reg_a_in;

wire flag_s = z80fi_reg_f_in[`FLAG_S_NUM];
wire flag_z = z80fi_reg_f_in[`FLAG_Z_NUM];
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = 1'b1;
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = z80fi_reg_f_in[`FLAG_PV_NUM];
wire flag_n = 1'b1;
wire flag_c = z80fi_reg_f_in[`FLAG_C_NUM];

assign spec_reg_a_out = result;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_NONE;

assign spec_tcycles1 = 4;

endmodule