// Covers the LD IX/IY, (mm) instruction.
// This must write register pair IX/IY with the 16-bit value at
// memory address mm. mm and (mm) are ordered little-endian.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_ixiy_mm(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] mm         = z80fi_insn[31:16];
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
assign spec_signals = `SPEC_REG_WR | `SPEC_MEM_RD | `SPEC_MEM_RD2 ;

// Data for 1's above.
assign spec_reg_wnum = iy ? `REG_IY : `REG_IX;
assign spec_reg_wdata = {z80fi_mem_rdata2, z80fi_mem_rdata};

assign spec_mem_raddr = mm;
assign spec_mem_raddr2 = mm + 1;

assign spec_pc_wdata = z80fi_pc_rdata + 4;

endmodule