// RRD/RLD
//
// Rotate left/right decimal.
//
// Treating A, (HL) as a 16-byte BCD number, breaking it into nibbles,
// rotate left rotates the bottom three nibbles left by a nibble,
// and rotate right does it right. Flags S, Z, and P are affected,
// and H and N are reset.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_rot_dec(
    `Z80FI_INSN_SPEC_IO
);

wire       left        = z80fi_insn[11];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b0110?111_11101101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_AF | `SPEC_MEM_RD |
    `SPEC_MEM_WR;

wire [15:0] src_data = {z80fi_reg_a_in, z80fi_bus_rdata};
wire [15:0] result = left ?
    {src_data[15:12], src_data[7:4], src_data[3:0], src_data[11:8]} :
    {src_data[15:12], src_data[3:0], src_data[11:8], src_data[7:4]};

wire flag_s = result[15];
wire flag_z = (result[15:8] == 0);
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = 0;
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = parity8(result[15:8]);
wire flag_n = 0;
wire flag_c = z80fi_reg_f_in[`FLAG_C_NUM];

assign spec_bus_raddr = z80fi_reg_hl_in;
assign spec_bus_waddr = z80fi_reg_hl_in;
assign spec_bus_wdata = result[7:0];
assign spec_reg_a_out = result[15:8];
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule