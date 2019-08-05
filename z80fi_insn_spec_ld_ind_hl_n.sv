// LD (HL), n
//
// This must write n to the memory address stored in HL.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_ind_hl_n(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] n           = z80fi_insn[15:8];
wire [7:0] insn_fixed1 = z80fi_insn[7:0];

// LD (HL), n instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    insn_fixed1 == 8'b00110110;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG1_RD | `SPEC_MEM_WR;

// Data for 1's above.
assign spec_reg1_rnum = `REG_HL;

assign spec_mem_waddr = z80fi_reg1_rdata;
assign spec_mem_wdata = n;

assign spec_pc_wdata = z80fi_pc_rdata + 2;

endmodule