// LD (IX/IY + d), r
//
// This must write the contents of the memory address at IX + d
// with the contents of register r. d is zero-exteded to 16 bits.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_idx_ixiy_reg(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] d           = z80fi_insn[23:16];
wire [4:0] insn_fixed1 = z80fi_insn[15:11];
wire [3:0] r           = z80fi_insn[10:8];
wire [1:0] insn_fixed2 = z80fi_insn[7:6];
wire       iy          = z80fi_insn[5];
wire [4:0] insn_fixed3 = z80fi_insn[4:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    insn_fixed1 == 5'b01110 &&
    insn_fixed2 == 2'b11 &&
    insn_fixed3 == 5'b11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG1_RD | `SPEC_REG2_RD | `SPEC_MEM_WR;

// Data for 1's above.
assign spec_reg1_rnum = iy ? `REG_IY : `REG_IX;
assign spec_reg2_rnum = {1'b0, r};

assign spec_mem_waddr = z80fi_reg1_rdata + {8'b0, d};
assign spec_mem_wdata = z80fi_reg2_rdata[7:0];

assign spec_pc_wdata = z80fi_pc_rdata + 3;

endmodule