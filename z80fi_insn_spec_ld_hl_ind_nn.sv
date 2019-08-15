// LD HL, (nn)
//
// This must write register pair HL with the 16-bit value in
// memory location nn. nn is ordered little-endian.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_hl_ind_nn(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] nn         = z80fi_insn[23:8];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    z80fi_insn[7:0] == 8'b00101010;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_HL | `SPEC_MEM_RD | `SPEC_MEM_RD2;

assign spec_reg_h_out = z80fi_mem_rdata2;
assign spec_reg_l_out = z80fi_mem_rdata;
assign spec_reg_ip_out = z80fi_reg_ip_in + 3;

assign spec_mem_raddr = nn;
assign spec_mem_raddr2 = nn + 1;

endmodule