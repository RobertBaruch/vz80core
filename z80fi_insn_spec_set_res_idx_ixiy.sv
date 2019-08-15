// SET/RES b, (IX/IY + d)
//
// Sets/resets the bit b of the byte at memory location IX/IY + d.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_set_res_idx_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire       insn_fixed1 = z80fi_insn[31];
wire       set         = z80fi_insn[30];
wire [2:0] b           = z80fi_insn[29:27];
wire [2:0] insn_fixed2 = z80fi_insn[26:24];
wire [7:0] d           = z80fi_insn[23:16];
wire [7:0] insn_fixed3 = z80fi_insn[15:8];
wire [1:0] insn_fixed4 = z80fi_insn[7:6];
wire [0:0] iy          = z80fi_insn[5];
wire [4:0] insn_fixed5 = z80fi_insn[4:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 4 &&
    insn_fixed1 == 1'b1 &&
    insn_fixed2 == 3'b110 &&
    insn_fixed3 == 8'hCB &&
    insn_fixed4 == 2'b11 &&
    insn_fixed5 == 5'b11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_MEM_RD | `SPEC_MEM_WR;

wire [7:0] rdata = z80fi_mem_rdata;
wire [7:0] wdata = set ? (rdata | (8'b1 << b)) : (rdata & ~(8'b1 << b));

wire [15:0] offset = {{8{d[7]}}, d[7:0]};
assign spec_mem_raddr = (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) + offset;
assign spec_mem_waddr = (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) + offset;
assign spec_mem_wdata = wdata;

assign spec_reg_ip_out = z80fi_reg_ip_in + 4;

endmodule