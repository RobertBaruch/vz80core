// JP (IX/IY)
//
// Jumps to the absolute address given at the little-endian
// 16-bit memory location in IX/IY.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_jp_ind_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire iy = z80fi_insn[5];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    z80fi_insn[15:0] == 16'b11101001_11?11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_MEM_RD | `SPEC_MEM_RD2;

wire [15:0] addr = iy ? z80fi_reg_iy_in : z80fi_reg_ix_in;
assign spec_mem_raddr = addr;
assign spec_mem_raddr2 = addr + 1;

assign spec_reg_ip_out = {z80fi_mem_rdata2, z80fi_mem_rdata};

endmodule