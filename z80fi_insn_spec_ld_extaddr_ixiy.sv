// Covers the 16-bit load group LD (nn), IX/IY instruction.
// This must read register pair IX/IY and write its value to
// memory location nn. nn is ordered little-endian.

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_extaddr_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] nn         = z80fi_insn[31:16];
wire [7:0] insn_fixed1 = z80fi_insn[15:8];
wire [1:0] insn_fixed2 = z80fi_insn[7:6];
wire       iy          = z80fi_insn[5];
wire [4:0] insn_fixed3 = z80fi_insn[4:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 4 &&
    insn_fixed1 == 8'h22 &&
    insn_fixed2 == 2'b11 &&
    insn_fixed3 == 5'b11101;

// Once spec_valid, what is supposed to happen?
assign spec_reg1_rd = 1; // IX/IY
assign spec_reg2_rd = 0;
assign spec_reg_wr = 0;
assign spec_mem_rd = 0;
assign spec_mem_rd2 = 0;
assign spec_mem_wr = 1;
assign spec_mem_wr2 = 1;

// Data for 1's above.
assign spec_reg1_rnum = iy ? `REG_IY : `REG_IX;

assign spec_mem_waddr = nn;
assign spec_mem_waddr2 = nn + 1;
assign spec_mem_wdata = z80fi_reg1_rdata[7:0];
assign spec_mem_wdata2 = z80fi_reg1_rdata[15:8];

assign spec_pc_wdata = z80fi_pc_rdata + 4;

endmodule