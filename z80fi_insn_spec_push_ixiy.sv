// PUSH IX/IY
//
// Pushes IX/IY onto the stack.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_push_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] insn_fixed1 = z80fi_insn[15:8];
wire [1:0] insn_fixed2 = z80fi_insn[7:6];
wire [0:0] iy          = z80fi_insn[5];
wire [4:0] insn_fixed3 = z80fi_insn[4:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    insn_fixed1 == 8'hE5 &&
    insn_fixed2 == 2'b11 &&
    insn_fixed3 == 5'b11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_SP |
    `SPEC_MEM_WR | `SPEC_MEM_WR2;

wire [15:0] wdata = iy ? z80fi_reg_iy_in : z80fi_reg_ix_in;

assign spec_mem_waddr = z80fi_reg_sp_in - 16'h2;
assign spec_mem_waddr2 = z80fi_reg_sp_in - 16'h1;
assign spec_mem_wdata = wdata[7:0];
assign spec_mem_wdata2 = wdata[15:8];
assign spec_reg_sp_out = z80fi_reg_sp_in - 16'h2;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule