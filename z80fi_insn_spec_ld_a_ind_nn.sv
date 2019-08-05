// LD A, (nn)
//
// This must read memory location nn and write its value to
// register A. nn is ordered little-endian.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_a_ind_nn(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] insn_fixed = z80fi_insn[7:0];
wire [15:0] addr = z80fi_insn[23:8];

// LD A, (nn) instruction
assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    insn_fixed == 8'h3A;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_WR | `SPEC_MEM_RD;

// Data for 1's above
assign spec_reg_wnum = `REG_A;
assign spec_reg_wdata = {8'b0, z80fi_mem_rdata};

assign spec_mem_raddr = addr;

assign spec_pc_wdata = z80fi_pc_rdata + 3;

endmodule