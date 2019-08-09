// LD (IX/IY + d), n
//
// This must write the contents of the memory address at IX/IY + d
// with the immediate byte n. d is sign-extended to 16 bits.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_idx_ixiy_n(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] n           = z80fi_insn[31:24];
wire [15:0] d           = { {8{z80fi_insn[23]}}, z80fi_insn[23:16]};
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
assign spec_signals = `SPEC_REG_IP | `SPEC_MEM_WR;

assign spec_reg_ip_out = z80fi_reg_ip_in + 4;
assign spec_mem_waddr = (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) + d;
assign spec_mem_wdata = n;

endmodule