// SET/RES b, (HL)
//
// Sets/resets bit b of the byte at memory location HL.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_set_res_ind_hl(
    `Z80FI_INSN_SPEC_IO
);

wire       set         = z80fi_insn[14];
wire [2:0] b           = z80fi_insn[13:11];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b1????110_11001011;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP  | `SPEC_MEM_RD | `SPEC_MEM_WR;

wire [7:0] rdata = z80fi_mem_rdata;
wire [7:0] wdata = set ? (rdata | (8'b1 << b)) : (rdata & ~(8'b1 << b));

assign spec_mem_raddr = z80fi_reg_hl_in;
assign spec_mem_waddr = z80fi_reg_hl_in;
assign spec_mem_wdata = wdata;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule