// Covers the 16-bit load group LD (nn), dd instruction.
// This must read register pair dd and write its value to
// memory location nn. nn is ordered little-endian.

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_extaddr_dd(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] nn         = z80fi_insn[31:16];
wire [1:0] insn_fixed1 = z80fi_insn[15:14];
wire [1:0] dd          = z80fi_insn[13:12];
wire [3:0] insn_fixed2 = z80fi_insn[11:8];
wire [7:0] insn_fixed3 = z80fi_insn[7:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 4 &&
    insn_fixed1 == 2'b01 &&
    insn_fixed2 == 4'b0011 &&
    insn_fixed3 == 8'hED;

// Once spec_valid, what is supposed to happen?
assign spec_reg1_rd = 1; // addr
assign spec_reg2_rd = 0;
assign spec_reg_wr = 0;
assign spec_mem_rd = 0;
assign spec_mem_rd2 = 0;
assign spec_mem_wr = 1;
assign spec_mem_wr2 = 1;

// Data for 1's above.
assign spec_reg1_rnum = {2'b10, dd};

assign spec_mem_waddr = nn;
assign spec_mem_waddr2 = nn + 1;
assign spec_mem_wdata = z80fi_reg1_rdata[7:0];
assign spec_mem_wdata2 = z80fi_reg1_rdata[15:8];

assign spec_pc_wdata = z80fi_pc_rdata + 4;

endmodule