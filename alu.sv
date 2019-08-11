`ifndef _alu_sv_
`define _alu_sv_

`default_nettype none
`timescale 1us/100 ns

`include "z80.vh"

function _alu_iszero8(input [7:0] x);
  _alu_iszero8 = (x == 0);
endfunction

function _alu_parity8(input [7:0] x);
  _alu_parity8 = x[0] ^ x[1] ^ x[2] ^ x[3] ^ x[4] ^ x[5] ^ x[6] ^ x[7];
endfunction

// adc8 is an 8-bit adder module, with special code
// for subtraction. The Z80 is unlike many other
// processors in that the carry is subtracted during
// a subtract-with-carry, so it's not like a borrow flag.
//
// SBC: out = x - y - carry
// ADC: out = x + y + carry
//
// The reason is that the Z80 inverts y and carry for
// SBC. Since -y = ~y + 1,
// then x - y - carry = x + (~y + 1) - carry.
// If carry is 1, then this is just x + ~y. If carry is 0,
// then this is just x + ~y + 1. Thus, we can invert the
// carry and y, and calculate x + ~y + ~carry.
module adc8(
    input logic [7:0] x,
    input logic [7:0] y,
    input logic carry,
    input logic sub_y,
    output logic [7:0] out,
    output logic [7:0] f
);

logic flag_s; // sign
logic flag_z; // zero
logic flag_5; // flag 5
logic flag_h; // half-carry
logic flag_3; // flag 3
logic flag_v; // parity/overflow
logic flag_n; // negative
logic flag_c; // carry

assign f = {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

logic [4:0] out_lo;
logic [3:0] out_hi1;
logic [1:0] out_hi2;

always @(*) begin
      out_lo = x[3:0] + y[3:0] + carry;
      out_hi1 = x[6:4] + y[6:4] + out_lo[4];
      out_hi2 = x[7] + y[7] + out_hi1[3];
      out = {out_hi2[0], out_hi1[2:0], out_lo[3:0]};
      flag_s = out[7];
      flag_z = out == 0 ? 1 : 0;
      flag_h = out_lo[4];
      flag_n = sub_y;
      flag_c = out_hi2[1];
      flag_v = out_hi2[1] ^ out_hi1[3];
      flag_5 = 0; // will be overwritten in the parent alu
      flag_3 = 0; // will be overwritten in the parent alu
end

endmodule

module adc16(
    input logic [15:0] x,
    input logic [15:0] y,
    input logic sub_y,
    input logic [7:0] f_in,
    output logic [15:0] out,
    output logic [7:0] f
);

logic flag_s; // sign
logic flag_z; // zero
logic flag_5; // flag 5
logic flag_h; // half-carry
logic flag_3; // flag 3
logic flag_v; // parity/overflow
logic flag_n; // negative
logic flag_c; // carry

assign f = {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

logic [12:0] out_lo;
logic [4:0] out_hi;

always @(*) begin
      out_lo = x[11:0] + y[11:0] + f_in[0];
      out_hi = x[15:10] + y[15:10] + out_lo[12];
      out = {out_hi[3:0], out_lo[11:0]};
      flag_s = f_in[7];
      flag_z = f_in[6];
      flag_h = out_lo[12];
      flag_v = f_in[2];
      flag_n = sub_y;
      flag_c = out_hi[4];
      flag_5 = 0; // will be overwritten in the parent alu
      flag_3 = 0; // will be overwritten in the parent alu
end

endmodule

module alu8(
    input logic [7:0] x,
    input logic [7:0] y,
    input logic [3:0] func,
    input logic [7:0] f_in,
    output logic [7:0] out,
    output logic [7:0] f
);

logic carry;
assign carry = f_in[0];

logic [7:0] flag_5;
logic [7:0] flag_3;
assign flag_5 = f_in & `FLAG_5_BIT;
assign flag_3 = f_in & `FLAG_3_BIT;

logic [7:0] add_out, add_f;
adc8 add8(
    .x(x),
    .y(y),
    .carry(1'b0),
    .sub_y(1'b0),
    .out(add_out),
    .f(add_f)
);

logic [7:0] adc_out, adc_f;
adc8 adc8(
    .x(x),
    .y(y),
    .carry(carry),
    .sub_y(1'b0),
    .out(adc_out),
    .f(adc_f)
);

logic [7:0] sub_out, sub_f;
adc8 sub8(
    .x(x),
    .y(~y),
    .carry(1'b1),
    .sub_y(1'b1),
    .out(sub_out),
    .f(sub_f)
);

logic [7:0] sbc_out, sbc_f;
adc8 sbc8(
    .x(x),
    .y(~y),
    .carry(~carry),
    .sub_y(1'b1),
    .out(sbc_out),
    .f(sbc_f)
);

always @(*) begin
  case (func)
    `ALU_FUNC_ADD: begin
        out = add_out;
        f = add_f;
    end

    `ALU_FUNC_ADC: begin
        out = adc_out;
        f = adc_f;
    end

    `ALU_FUNC_SUB, `ALU_FUNC_CP: begin
        out = sub_out;
        f = sub_f;
    end

    `ALU_FUNC_SBC: begin
        out = sbc_out;
        f = sbc_f;
    end

    `ALU_FUNC_AND: begin
      out = x & y;
      f = {
        out[7], // sign
        _alu_iszero8(out), // zero
        f_in[5],
        1'b1, // h
        f_in[3],
        _alu_parity8(out), // parity
        2'b00 // n, c
      };
    end

    `ALU_FUNC_XOR: begin
      out = x ^ y;
      f = {
        out[7], // sign
        _alu_iszero8(out), // zero
        f_in[5],
        1'b0, // h
        f_in[3],
        _alu_parity8(out), // parity
        2'b00 // n, c
      };
    end

    `ALU_FUNC_OR: begin
      out = x | y;
      f = {
        out[7], // sign
        _alu_iszero8(out), // zero
        f_in[5],
        1'b0, // h
        f_in[3],
        _alu_parity8(out), // parity
        2'b00 // n, c
      };
    end

    default: begin
      out = 0;
      f = f_in;
    end

  endcase

  f = (f & `FLAG_5_MASK & `FLAG_3_MASK) | flag_5 | flag_3;
end

endmodule

module alu16(
    input logic [15:0] x,
    input logic [15:0] y,
    input logic [3:0] func,
    input logic [7:0] f_in,
    output logic [15:0] out,
    output logic [7:0] f
);

logic [7:0] flag_5;
logic [7:0] flag_3;
assign flag_5 = f_in & `FLAG_5_BIT;
assign flag_3 = f_in & `FLAG_3_BIT;

logic [15:0] add_out;
logic [7:0] add_f;
adc16 add16(
    .x(x),
    .y(y),
    .sub_y(1'b0),
    .f_in(f),
    .out(add_out),
    .f(add_f)
);

logic [15:0] adc_out;
logic [7:0] adc_f;
adc16 adc16(
    .x(x),
    .y(y),
    .sub_y(1'b0),
    .f_in(f_in),
    .out(adc_out),
    .f(adc_f)
);

logic [15:0] sub_out;
logic [7:0] sub_f;
adc16 sub16(
    .x(x),
    .y(~y),
    .sub_y(1'b1),
    .f_in({f_in[7:1], 1'b1}), // set carry
    .out(sub_out),
    .f(sub_f)
);

logic [15:0] sbc_out;
logic [7:0] sbc_f;
adc16 sbc16(
    .x(x),
    .y(~y),
    .sub_y(1'b1),
    .f_in({f_in[7:1], ~f_in[0]}), // invert carry
    .out(sbc_out),
    .f(sbc_f)
);

always @(*) begin
  case (func)
    // ADD. Use also for INC (set y = 1, ignore flags).
    `ALU_FUNC_ADD: begin
        out = add_out;
        f = add_f;
    end

    // ADC
    `ALU_FUNC_ADC: begin
        out = adc_out;
        f = adc_f;
    end

    // SUB. Use also for DEC (set y = 1, ignore flags) and CP (ignore out).
    `ALU_FUNC_SUB: begin
        out = sub_out;
        f = sub_f;
    end

    // SBC
    `ALU_FUNC_SBC: begin
        out = sbc_out;
        f = sbc_f;
    end
  endcase

  f = (f & `FLAG_5_MASK & `FLAG_3_MASK) | flag_5 | flag_3;
end

endmodule

`endif  // _alu_sv_
