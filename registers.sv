`ifndef _registers_sv_
`define _registers_sv_

`default_nettype none

`include "z80.vh"

module registers(
    input logic reset,
    input logic clk,

    // What to write.
    input logic write_en,
    input logic `reg_select dest,
    input logic [15:0] in,

    // What to read (2 busses)
    input logic `reg_select src1,
    output logic [15:0] out1,

    input logic `reg_select src2,
    output logic [15:0] out2,

    // Flags are always output, and may be
    // written to. This is ignored if writing
    // to AF.
    output logic [7:0] reg_f,
    input logic [7:0] f_in,
    input logic f_wr

`ifdef Z80_FORMAL
    ,
    `Z80_REGS_OUTPUTS
`endif
);

logic [15:0] _af;
logic [15:0] _bc;
logic [15:0] _de;
logic [15:0] _hl;

logic [15:0] _af2;
logic [15:0] _bc2;
logic [15:0] _de2;
logic [15:0] _hl2;

logic [15:0] _ix;
logic [15:0] _iy;
logic [15:0] _sp;

`ifdef Z80_FORMAL
  assign z80_reg_a = _af[15:8];
  assign z80_reg_f = _af[7:0];
  assign z80_reg_b = _bc[15:8];
  assign z80_reg_c = _bc[7:0];
  assign z80_reg_d = _de[15:8];
  assign z80_reg_e = _de[7:0];
  assign z80_reg_h = _hl[15:8];
  assign z80_reg_l = _hl[7:0];
  assign z80_reg_a2 = _af2[15:8];
  assign z80_reg_f2 = _af2[7:0];
  assign z80_reg_b2 = _bc2[15:8];
  assign z80_reg_c2 = _bc2[7:0];
  assign z80_reg_d2 = _de2[15:8];
  assign z80_reg_e2 = _de2[7:0];
  assign z80_reg_h2 = _hl2[15:8];
  assign z80_reg_l2 = _hl2[7:0];
  assign z80_reg_ix = _ix;
  assign z80_reg_iy = _iy;
  assign z80_reg_sp = _sp;
`endif // Z80_FORMAL

logic f_wr2;
assign f_wr2 = f_wr && !(write_en && (dest == `REG_AF));
assign reg_f = _af[7:0];

always @(*) begin
    out1[15:0] = 0;
    out2[15:0] = 0;
    case (src1)
      `REG_A: out1[7:0] = _af[15:8];
      `REG_B: out1[7:0] = _bc[15:8];
      `REG_C: out1[7:0] = _bc[7:0];
      `REG_D: out1[7:0] = _de[15:8];
      `REG_E: out1[7:0] = _de[7:0];
      `REG_H: out1[7:0] = _hl[15:8];
      `REG_L: out1[7:0] = _hl[7:0];
      `REG_AF: out1[15:0] = _af;
      `REG_BC: out1[15:0] = _bc;
      `REG_DE: out1[15:0] = _de;
      `REG_HL: out1[15:0] = _hl;
      `REG_IX: out1[15:0] = _ix;
      `REG_IY: out1[15:0] = _iy;
      `REG_SP: out1[15:0] = _sp;
    endcase
    case (src2)
      `REG_A: out2[7:0] = _af[15:8];
      `REG_B: out2[7:0] = _bc[15:8];
      `REG_C: out2[7:0] = _bc[7:0];
      `REG_D: out2[7:0] = _de[15:8];
      `REG_E: out2[7:0] = _de[7:0];
      `REG_H: out2[7:0] = _hl[15:8];
      `REG_L: out2[7:0] = _hl[7:0];
      `REG_AF: out2[15:0] = _af;
      `REG_BC: out2[15:0] = _bc;
      `REG_DE: out2[15:0] = _de;
      `REG_HL: out2[15:0] = _hl;
      `REG_IX: out2[15:0] = _ix;
      `REG_IY: out2[15:0] = _iy;
      `REG_SP: out2[15:0] = _sp;
    endcase
end

always @(posedge clk or posedge reset) begin
  if (reset) begin
    _af <= 0;
    _bc <= 0;
    _de <= 0;
    _hl <= 0;
    _af2 <= 0;
    _bc2 <= 0;
    _de2 <= 0;
    _hl2 <= 0;
    _ix <= 0;
    _iy <= 0;
    _sp <= 0;
  end else begin
    _af[7:0] <= (write_en && dest == `REG_AF) ? in[7:0] : (f_wr2 ? f_in : _af[7:0]);
    if (write_en) begin
      case (dest)
        `REG_A: _af[15:8] <= in[7:0];
        `REG_B: _bc[15:8] <= in[7:0];
        `REG_C: _bc[7:0] <= in[7:0];
        `REG_D: _de[15:8] <= in[7:0];
        `REG_E: _de[7:0] <= in[7:0];
        `REG_H: _hl[15:8] <= in[7:0];
        `REG_L: _hl[7:0] <= in[7:0];
        `REG_AF: _af <= in;
        `REG_BC: _bc <= in;
        `REG_DE: _de <= in;
        `REG_HL: _hl <= in;
        `REG_IX: _ix <= in;
        `REG_IY: _iy <= in;
        `REG_SP: _sp <= in;
      endcase
    end
  end
end

`ifdef REGISTERS_FORMAL
initial assume(reset);

logic past_valid;
initial	past_valid = 0;
always @(posedge clk) past_valid <= 1;

function is_8bit(input `reg_select x);
  is_8bit = (x <= 7 && x != 6);
endfunction

function is_16bit(input `reg_select x);
  is_16bit = (x >= `REG_FIRST16 && x <= `REG_LAST16);
endfunction

`define wrote $past(!reset && write_en && !f_wr) && !reset
`define wrote_flags $past(!reset && f_wr2) && !reset

always @(posedge clk) begin
  if (past_valid) begin
    if (`wrote && $past(dest) == src1 && is_8bit(src1))
      assert(out1[7:0] == $past(in[7:0]));
    if (`wrote && $past(dest) == src2 && is_8bit(src2))
      assert(out2[7:0] == $past(in[7:0]));
    if (`wrote && $past(dest) == src1 && is_16bit(src1))
      assert(out1[15:0] == $past(in[15:0]));
    if (`wrote && $past(dest) == src2 && is_16bit(src2))
      assert(out2[15:0] == $past(in[15:0]));
    if (`wrote_flags)
      assert(reg_f == $past(f_in));
  end
  cover(_bc == 16'h1234 && _ix == 16'h1234 && out1[15:0] == 16'h5678 && out2[15:0] == 16'h0098);
  cover($past(_af) == 16'hFFFF && reg_f == 0 && `wrote_flags);
end
`endif

endmodule

`endif  // _registers_sv_
