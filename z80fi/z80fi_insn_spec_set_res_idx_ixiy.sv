// SET/RES b, (IX/IY + d)
//
// Sets/resets the bit b of the byte at memory location IX/IY + d.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_set_res_idx_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire       set         = z80fi_insn[30];
wire [2:0] b           = z80fi_insn[29:27];
wire [7:0] d           = z80fi_insn[23:16];
wire [0:0] iy          = z80fi_insn[5];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 4 &&
    z80fi_insn[31:0] == 32'b1????110_????????_11001011_11?11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_MEM_RD | `SPEC_MEM_WR;

wire [7:0] rdata = z80fi_bus_rdata;
wire [7:0] wdata = set ? (rdata | (8'b1 << b)) : (rdata & ~(8'b1 << b));

wire [15:0] offset = {{8{d[7]}}, d[7:0]};
assign spec_bus_raddr = (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) + offset;
assign spec_bus_waddr = (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) + offset;
assign spec_bus_wdata = wdata;

assign spec_reg_ip_out = z80fi_reg_ip_in + 4;

assign spec_mcycle_type1 = `CYCLE_M1;
assign spec_mcycle_type2 = `CYCLE_M1;
assign spec_mcycle_type3 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type4 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type5 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type6 = `CYCLE_RDWR_MEM;
assign spec_mcycle_type7 = `CYCLE_NONE;

assign spec_tcycles1 = 4;
assign spec_tcycles2 = 4;
assign spec_tcycles3 = 3;
assign spec_tcycles4 = 5;
assign spec_tcycles5 = 4;
assign spec_tcycles6 = 3;

endmodule