// EX (SP), IX/IY
//
// Exchanges IX/IY with the two bytes at memory location SP.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ex_ind_sp_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire [7:0] insn_fixed1  = z80fi_insn[15:8];
wire [1:0] insn_fixed2  = z80fi_insn[7:6];
wire iy                 = z80fi_insn[5];
wire [4:0] insn_fixed3  = z80fi_insn[4:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 2 &&
    insn_fixed1 == 8'hE3 &&
    insn_fixed2 == 2'b11 &&
    insn_fixed3 == 5'b11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_IX | `SPEC_REG_IY |
    `SPEC_MEM_RD | `SPEC_MEM_RD2 | `SPEC_MEM_WR | `SPEC_MEM_WR2;

wire [15:0] wdata = iy ? z80fi_reg_iy_in : z80fi_reg_ix_in;

assign spec_mem_raddr = z80fi_reg_sp_in;
assign spec_mem_raddr2 = z80fi_reg_sp_in + 1;
assign spec_mem_waddr = z80fi_reg_sp_in;
assign spec_mem_waddr2 = z80fi_reg_sp_in + 1;
assign spec_mem_wdata = wdata[7:0];
assign spec_mem_wdata2 = wdata[15:8];

assign spec_reg_ix_out = iy ? z80fi_reg_ix_in : {z80fi_mem_rdata2, z80fi_mem_rdata};
assign spec_reg_iy_out = iy ? {z80fi_mem_rdata2, z80fi_mem_rdata} : z80fi_reg_iy_in;

assign spec_reg_ip_out = z80fi_reg_ip_in + 2;

endmodule