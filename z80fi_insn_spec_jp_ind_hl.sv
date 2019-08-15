// JP (HL)
//
// Jumps to the absolute address given at the little-endian
// 16-bit memory location in HL.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_jp_ind_hl(
    `Z80FI_INSN_SPEC_IO
);

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b11101001;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_MEM_RD | `SPEC_MEM_RD2;

assign spec_mem_raddr = z80fi_reg_hl_in;
assign spec_mem_raddr2 = z80fi_reg_hl_in + 1;

assign spec_reg_ip_out = {z80fi_mem_rdata2, z80fi_mem_rdata};

endmodule