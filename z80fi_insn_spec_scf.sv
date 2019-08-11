// SCF
//
// Sets the carry flag.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_scf(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] insn_fixed1 = z80fi_insn[7:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    insn_fixed1 == 8'h37;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_F;

wire flag_s = z80fi_reg_f_in[`FLAG_S_NUM];
wire flag_z = z80fi_reg_f_in[`FLAG_Z_NUM];
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = 0;
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = z80fi_reg_f_in[`FLAG_PV_NUM];
wire flag_n = 0;
wire flag_c = 1;

assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

endmodule