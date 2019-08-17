// SRA/SRL/SLA (HL)
//
// Shifts arithmetic/logical the byte at the memory location
// in HL left/right.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_shift_ind_hl(
    `Z80FI_INSN_SPEC_IO
);

wire       logical     = z80fi_insn[12];
wire       right       = z80fi_insn[11];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b001??110_11001011 &&
    !(logical && !right); // SLL is illegal in strict mode.

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_F | `SPEC_MEM_RD |
    `SPEC_MEM_WR;

wire [7:0] rdata = z80fi_bus_rdata;

// This is the bit that gets shoved into the register from the right or left.
// If we're rotating through carry, it's the carry bit. Otherwise
// it's the rightmost or leftmost bit of register.
wire shove_bit = (!logical && right) ? rdata[7] : 1'b0;
wire [7:0] wdata =
    right ? {shove_bit, rdata[7:1]} : {rdata[6:0], shove_bit};

wire flag_s = wdata[7];
wire flag_z = (wdata == 0);
wire flag_5 = z80fi_reg_f_in[`FLAG_5_NUM];
wire flag_h = 0;
wire flag_3 = z80fi_reg_f_in[`FLAG_3_NUM];
wire flag_v = parity8(wdata);
wire flag_n = 0;
wire flag_c = rdata[right ? 0 : 7];

assign spec_bus_raddr = z80fi_reg_hl_in;
assign spec_bus_waddr = z80fi_reg_hl_in;
assign spec_bus_wdata = wdata;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule