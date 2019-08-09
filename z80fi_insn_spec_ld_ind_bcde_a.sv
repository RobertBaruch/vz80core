// LD (BC/DE), A
//
// This must write A to the memory address stored in BC or DE.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_ind_bcde_a(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] insn_fixed1  = z80fi_insn[7:5];
wire [0:0] de           = z80fi_insn[4:4];
wire [3:0] insn_fixed2  = z80fi_insn[3:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    insn_fixed1 == 3'b000 &&
    insn_fixed2 == 4'b0010;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP |`SPEC_MEM_WR;

assign spec_mem_waddr = de ? z80fi_reg_de_in : z80fi_reg_bc_in;
assign spec_mem_wdata = z80fi_reg_a_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

endmodule