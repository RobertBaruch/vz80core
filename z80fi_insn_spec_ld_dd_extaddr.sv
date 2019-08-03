// Covers the 16-bit load group LD dd, (nn) instruction.
// This must read memory locations nn and nn+1 and write its value
// to 16-bit register pair dd. nn is ordered little-endian. The data
// is also little-endian, so for example the byte at memory location nn
// for writing to BC would go in C.

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_dd_extaddr(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] addr        = z80fi_insn[31:16];
wire [1:0]  insn_fixed1 = z80fi_insn[15:14];
wire [1:0]  dd          = z80fi_insn[13:12];
wire [3:0]  insn_fixed2 = z80fi_insn[11:8];
wire [7:0]  insn_fixed3 = z80fi_insn[7:0];

// LD dd, (nn) instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 4 &&
    insn_fixed1 == 2'b01 &&
    insn_fixed2 == 4'b1011 &&
    insn_fixed3 == 8'hED;

// Once spec_valid, what is supposed to happen?
assign spec_reg1_rd = 0;
assign spec_reg2_rd = 0;
assign spec_reg_wr = 1;
assign spec_mem_rd = 1;
assign spec_mem_rd2 = 1;
assign spec_mem_wr = 0;
assign spec_mem_wr2 = 0;
assign spec_i_rd = 0;
assign spec_i_wr = 0;
assign spec_r_rd = 0;
assign spec_r_wr = 0;
assign spec_f_rd = 0;
assign spec_f_wr = 0;

// Data for 1's above.
assign spec_reg_wnum = {2'b10, dd};
assign spec_reg_wdata = {z80fi_mem_rdata2, z80fi_mem_rdata};

assign spec_mem_raddr = addr;
assign spec_mem_raddr2 = addr + 1;

assign spec_pc_wdata = z80fi_pc_rdata + 4;

endmodule