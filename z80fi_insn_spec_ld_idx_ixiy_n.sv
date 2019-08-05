// LD (IX/IY + d), n
//
// This must write the contents of the memory address at IX/IY + d
// with the immediate byte n. d is zero-exteded to 16 bits.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_idx_ixiy_n(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] n           = z80fi_insn[31:24];
wire [7:0] d           = z80fi_insn[23:16];
wire [7:0] insn_fixed1 = z80fi_insn[15:8];
wire [1:0] insn_fixed2 = z80fi_insn[7:6];
wire       iy          = z80fi_insn[5];
wire [4:0] insn_fixed3 = z80fi_insn[4:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 4 &&
    insn_fixed1 == 8'h36 &&
    insn_fixed2 == 2'b11 &&
    insn_fixed3 == 5'b11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG1_RD | `SPEC_MEM_WR;

// Data for 1's above.
assign spec_reg1_rnum = iy ? `REG_IY : `REG_IX;

assign spec_mem_waddr = z80fi_reg1_rdata + {8'b0, d};
assign spec_mem_wdata = n;

assign spec_pc_wdata = z80fi_pc_rdata + 4;

endmodule