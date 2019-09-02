// OUTI/OTIR/OUTD/OTDR
//
// Writes a byte from the I/O port in register C from the byte at
// the memory address at HL. The high byte of the address output is the
// contents of register B, while the low byte is register C.
// Then HL is incremented or decremented, and B is decremented.
// For repeat instructions, if B is nonzero after being decremented,
// repeat the instruction.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_out_block(
    `Z80FI_INSN_SPEC_IO
);

wire rep = z80fi_insn[12];
wire dec = z80fi_insn[11];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b101??011_11101101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP |`SPEC_REG_BC | `SPEC_REG_HL |
    `SPEC_IO_WR | `SPEC_MEM_RD | `SPEC_REG_F;

assign spec_bus_raddr = z80fi_reg_hl_in;
assign spec_bus_waddr = z80fi_reg_bc_in;
assign spec_bus_wdata = z80fi_bus_rdata;
assign spec_reg_b_out = z80fi_reg_b_in - 8'h01;
assign spec_reg_c_out = z80fi_reg_c_in;

wire [15:0] next_hl = z80fi_reg_hl_in + (dec ? 16'hFFFF : 16'h0001);
assign spec_reg_h_out = next_hl[15:8];
assign spec_reg_l_out = next_hl[7:0];

wire flag_s = spec_reg_b_out[7];
wire flag_z = (spec_reg_b_out == 0);
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = 0;
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = 0;
wire flag_n = 1;
wire flag_c = z80fi_reg_f_in[`FLAG_C_NUM];

assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};
assign spec_reg_ip_out = z80fi_reg_ip_in +
    ((spec_reg_b_out != 0 && rep) ? 0 : 2);

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_RDWR_IO;
assign spec_mcycle_type5 = (rep && spec_reg_b_out != 0) ? `CYCLE_INTERNAL : `CYCLE_NONE;
assign spec_mcycle_type6 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 5;
assign spec_tcycles3 = 3;
assign spec_tcycles4 = 4;
assign spec_tcycles5 = 5;

endmodule