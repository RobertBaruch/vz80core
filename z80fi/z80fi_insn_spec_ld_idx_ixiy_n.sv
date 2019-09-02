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
wire       iy          = z80fi_insn[5];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 4 &&
    z80fi_insn[15:0] == 16'b00110110_11?11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_MEM_WR;

assign spec_reg_ip_out = z80fi_reg_ip_in + 4;
assign spec_bus_waddr = (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) + d;
assign spec_bus_wdata = n;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type5 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type6 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;
assign spec_tcycles3 = 3;
assign spec_tcycles4 = 5;
assign spec_tcycles5 = 3;

endmodule