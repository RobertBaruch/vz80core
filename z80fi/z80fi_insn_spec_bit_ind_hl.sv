// BIT b, (HL)
//
// Sets the Z flag if bit b of the byte at memory location HL is zero.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_bit_ind_hl(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] b           = z80fi_insn[13:11];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b01???110_11001011;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_F | `SPEC_MEM_RD;

wire [7:0] rdata = z80fi_bus_rdata;

// Undocumented value of S flag:
// Set if bit = 7 and bit 7 in r is set.
wire flag_s = b == 7 && rdata[7] == 1;
wire flag_z = rdata[b] == 0;
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = 1;
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = rdata[b] == 0;
wire flag_n = 0;
wire flag_c = z80fi_reg_f_in[`FLAG_C_NUM];

assign spec_bus_raddr = z80fi_reg_hl_in;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;
assign spec_tcycles3 = 4;

endmodule