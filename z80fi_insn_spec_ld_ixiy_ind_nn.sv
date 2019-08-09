// LD IX/IY, (nn)
//
// This must write register pair IX/IY with the 16-bit value at
// memory address nn. nn and (nn) are ordered little-endian.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_ixiy_ind_nn(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] nn         = z80fi_insn[31:16];
wire [7:0] insn_fixed1 = z80fi_insn[15:8];
wire [1:0] insn_fixed2 = z80fi_insn[7:6];
wire       iy          = z80fi_insn[5];
wire [4:0] insn_fixed3 = z80fi_insn[4:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 4 &&
    insn_fixed1 == 8'h2A &&
    insn_fixed2 == 2'b11 &&
    insn_fixed3 == 5'b11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_IX | `SPEC_REG_IY |
     `SPEC_MEM_RD | `SPEC_MEM_RD2 ;

wire [15:0] wdata = {z80fi_mem_rdata2, z80fi_mem_rdata};
assign spec_reg_ix_out = iy ? z80fi_reg_ix_in : wdata;
assign spec_reg_iy_out = iy ? wdata : z80fi_reg_iy_in;

assign spec_mem_raddr = nn;
assign spec_mem_raddr2 = nn + 1;

assign spec_reg_ip_out = z80fi_reg_ip_in + 4;

endmodule