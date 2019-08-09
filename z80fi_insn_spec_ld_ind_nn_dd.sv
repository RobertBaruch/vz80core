// LD (nn), dd
//
// This must read register pair dd and write its 16-bit value to
// memory location nn. nn is ordered little-endian.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ld_ind_nn_dd(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] nn         = z80fi_insn[31:16];
wire [1:0] insn_fixed1 = z80fi_insn[15:14];
wire [1:0] dd          = z80fi_insn[13:12];
wire [3:0] insn_fixed2 = z80fi_insn[11:8];
wire [7:0] insn_fixed3 = z80fi_insn[7:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 4 &&
    insn_fixed1 == 2'b01 &&
    insn_fixed2 == 4'b0011 &&
    insn_fixed3 == 8'hED;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_MEM_WR | `SPEC_MEM_WR2;

wire [15:0] wdata =
    (dd == `REG_BC) ? z80fi_reg_bc_in :
    (dd == `REG_DE) ? z80fi_reg_de_in :
    (dd == `REG_HL) ? z80fi_reg_hl_in :
    (dd == `REG_SP) ? z80fi_reg_sp_in : 0;
assign spec_mem_waddr = nn;
assign spec_mem_waddr2 = nn + 1;
assign spec_mem_wdata = wdata[7:0];
assign spec_mem_wdata2 = wdata[15:8];

assign spec_reg_ip_out = z80fi_reg_ip_in + 4;

endmodule