// Covers the 8-bit load group LD r, r' instructions.
// This must read register r' and write its value to
// register r.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_reg_reg(
    `Z80FI_INSN_SPEC_IO
);

wire [1:0] insn_fixed = z80fi_insn[7:6];
wire [2:0] insn_rreg = z80fi_insn[2:0];
wire [2:0] insn_wreg = z80fi_insn[5:3];

// LD r, r' instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    insn_fixed == 2'b01 &&
    insn_rreg != 3'b110 &&
    insn_wreg != 3'b110;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG1_RD | `SPEC_REG_WR;

// Data for 1's above.
assign spec_reg1_rnum = insn_rreg;

assign spec_reg_wnum = insn_wreg;
assign spec_reg_wdata = {8'b0, z80fi_reg1_rdata[7:0]};

assign spec_pc_wdata = z80fi_pc_rdata + 1;

endmodule