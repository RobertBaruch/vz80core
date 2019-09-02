// BIT b, (IX/IY + d)
//
// Sets the Z flag if bit b of the byte at memory location
// IX/IY + d is zero.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_bit_idx_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] b           = z80fi_insn[29:27];
wire [7:0] d           = z80fi_insn[23:16];
wire [0:0] iy          = z80fi_insn[5];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 4 &&
    z80fi_insn[31:0] == 32'b01???110_????????_11001011_11?11101;

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

wire [15:0] offset = {{8{d[7]}}, d[7:0]};
assign spec_bus_raddr = (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) + offset;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 4;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type5 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type6 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;
assign spec_tcycles3 = 3;
assign spec_tcycles4 = 5;
assign spec_tcycles5 = 4;

endmodule