`default_nettype none
`include "alu.sv"

// Even parity -> flag PV = 1.
function parity8(input [7:0] x);
  parity8 = ~(x[0] ^ x[1] ^ x[2] ^ x[3] ^ x[4] ^ x[5] ^ x[6] ^ x[7]);
endfunction

function halfcarry8(input [7:0] x, input [7:0] y, input carry);
  reg [4:0] out;
  out = x[3:0] + y[3:0] + carry;
  halfcarry8 = out[4];
endfunction

function carry8(input [7:0] x, input [7:0] y, input carry);
  reg [8:0] out;
  out = x + y + carry;
  carry8 = out[8];
endfunction

function overflow8(input [7:0] x, input [7:0] y, input carry);
  reg [7:0] out;
  out = x[6:0] + y[6:0] + carry;
  overflow8 = carry8(x, y, carry) ^ out[7];
endfunction

function halfcarry16(input [15:0] x, input [15:0] y, input carry);
  reg [12:0] out;
  out = x[11:0] + y[11:0] + carry;
  halfcarry16 = out[12];
endfunction

function carry16(input [15:0] x, input [15:0] y, input carry);
  reg [16:0] out;
  out = x + y + carry;
  carry16 = out[16];
endfunction

function overflow16(input [15:0] x, input [15:0] y, input carry);
  reg [15:0] out;
  out = x[14:0] + y[14:0] + carry;
  overflow16 = carry16(x, y, carry) ^ out[15];
endfunction

module alu_tb(
    input logic [3:0] func,
    input logic [7:0] f_in,

    input logic [7:0] x,
    input logic [7:0] y,
    output logic [7:0] out,
    output logic [7:0] f,

    input logic [15:0] x16,
    input logic [15:0] y16,
    output logic [15:0] out16,
    output logic [7:0] f16
);

logic flag_in_s;
logic flag_in_z;
logic flag_in_5;
logic flag_in_h;
logic flag_in_3;
logic flag_in_v;
logic flag_in_n;
logic flag_in_c;

logic flag_s;
logic flag_z;
logic flag_5;
logic flag_h;
logic flag_3;
logic flag_v;
logic flag_n;
logic flag_c;

logic flag16_s;
logic flag16_z;
logic flag16_5;
logic flag16_h;
logic flag16_3;
logic flag16_v;
logic flag16_n;
logic flag16_c;

assign flag_in_s = f_in[7];
assign flag_in_z = f_in[6];
assign flag_in_5 = f_in[5];
assign flag_in_h = f_in[4];
assign flag_in_3 = f_in[3];
assign flag_in_v = f_in[2];
assign flag_in_n = f_in[1];
assign flag_in_c = f_in[0];

assign flag_s = f[7];
assign flag_z = f[6];
assign flag_5 = f[5];
assign flag_h = f[4];
assign flag_3 = f[3];
assign flag_v = f[2];
assign flag_n = f[1];
assign flag_c = f[0];

assign flag16_s = f16[7];
assign flag16_z = f16[6];
assign flag16_5 = f16[5];
assign flag16_h = f16[4];
assign flag16_3 = f16[3];
assign flag16_v = f16[2];
assign flag16_n = f16[1];
assign flag16_c = f16[0];

alu8 alu8(
    .x(x),
    .y(y),
    .func(func),
    .f_in(f_in),
    .out(out),
    .f(f)
);

alu16 alu16(
    .x(x16),
    .y(y16),
    .func(func),
    .f_in(f_in),
    .out(out16),
    .f(f16)
);

`ifdef FORMAL
always @(*) begin
  if (func == `ALU_FUNC_ADD) begin
    assert(out == (x + y));
    assert(flag_s == out[7]);
    assert(flag_z == (out == 0));
    assert(flag_5 == flag_in_5);
    assert(flag_h == halfcarry8(x, y, 0));
    assert(flag_3 == flag_in_3);
    assert(flag_v == overflow8(x, y, 0));
    assert(flag_n == 0);
    assert(flag_c == carry8(x, y, 0));

    assert(out16 == (x16 + y16));
    assert(flag16_s == out16[15]);
    assert(flag16_z == (out16 == 0));
    assert(flag16_5 == flag_in_5);
    assert(flag16_h == halfcarry16(x16, y16, 0));
    assert(flag16_3 == flag_in_3);
    assert(flag16_v == overflow16(x16, y16, 0));
    assert(flag16_n == 0);
    assert(flag16_c == carry16(x16, y16, 0));
  end

  if (func == `ALU_FUNC_ADC) begin
    assert(out == (x + y + flag_in_c));
    assert(flag_s == out[7]);
    assert(flag_z == (out == 0));
    assert(flag_5 == flag_in_5);
    assert(flag_h == halfcarry8(x, y, flag_in_c));
    assert(flag_3 == flag_in_3);
    assert(flag_v == overflow8(x, y, flag_in_c));
    assert(flag_n == 0);
    assert(flag_c == carry8(x, y, flag_in_c));

    assert(out16 == (x16 + y16 + flag_in_c));
    assert(flag16_s == out16[15]);
    assert(flag16_z == (out16 == 0));
    assert(flag16_5 == flag_in_5);
    assert(flag16_h == halfcarry16(x16, y16, flag_in_c));
    assert(flag16_3 == flag_in_3);
    assert(flag16_v == overflow16(x16, y16, flag_in_c));
    assert(flag16_n == 0);
    assert(flag16_c == carry16(x16, y16, flag_in_c));
  end

  if (func == `ALU_FUNC_SUB || func == `ALU_FUNC_CP) begin
    assert(out == (x - y));
    assert(flag_s == out[7]);
    assert(flag_z == (out == 0));
    assert(flag_5 == flag_in_5);
    assert(flag_h == halfcarry8(x, ~y, 1));
    assert(flag_3 == flag_in_3);
    assert(flag_v == overflow8(x, ~y, 1));
    assert(flag_n == 1);
    assert(flag_c == carry8(x, ~y, 1));

    assert(out16 == (x16 - y16));
    assert(flag16_s == out16[15]);
    assert(flag16_z == (out16 == 0));
    assert(flag16_5 == flag_in_5);
    assert(flag16_h == halfcarry16(x16, ~y16, 1));
    assert(flag16_3 == flag_in_3);
    assert(flag16_v == overflow16(x16, ~y16, 1));
    assert(flag16_n == 1);
    assert(flag16_c == carry16(x16, ~y16, 1));
  end

  if (func == `ALU_FUNC_SBC) begin
    assert(out == (x - y - flag_in_c));
    assert(flag_s == out[7]);
    assert(flag_z == (out == 0));
    assert(flag_5 == flag_in_5);
    assert(flag_h == halfcarry8(x, ~y, ~flag_in_c));
    assert(flag_3 == flag_in_3);
    assert(flag_v == overflow8(x, ~y, ~flag_in_c));
    assert(flag_n == 1);
    assert(flag_c == carry8(x, ~y, ~flag_in_c));

    assert(out16 == (x16 - y16 - flag_in_c));
    assert(flag16_s == out16[15]);
    assert(flag16_z == (out16 == 0));
    assert(flag16_5 == flag_in_5);
    assert(flag16_h == halfcarry16(x16, ~y16, ~flag_in_c));
    assert(flag16_3 == flag_in_3);
    assert(flag16_v == overflow16(x16, ~y16, ~flag_in_c));
    assert(flag16_n == 1);
    assert(flag16_c == carry16(x16, ~y16, ~flag_in_c));
  end

  if (func == `ALU_FUNC_AND) begin
    assert(flag_h == 1);
    assert(flag_n == 0);
    assert(flag_c == 0);
    assert(out == (x & y));
    assert(flag_s == out[7]);
    assert(flag_z == (out == 0));
    assert(flag_v == parity8(out));
    assert(flag_5 == flag_in_5);
    assert(flag_3 == flag_in_3);
  end

  if (func == `ALU_FUNC_XOR) begin
    assert(flag_h == 0);
    assert(flag_n == 0);
    assert(flag_c == 0);
    assert(out == (x ^ y));
    assert(flag_s == out[7]);
    assert(flag_z == (out == 0));
    assert(flag_v == parity8(out));
    assert(flag_5 == flag_in_5);
    assert(flag_3 == flag_in_3);
  end

  if (func == `ALU_FUNC_OR) begin
    assert(flag_h == 0);
    assert(flag_n == 0);
    assert(flag_c == 0);
    assert(out == (x | y));
    assert(flag_s == out[7]);
    assert(flag_z == (out == 0));
    assert(flag_v == parity8(out));
    assert(flag_5 == flag_in_5);
    assert(flag_3 == flag_in_3);
  end

  if (func == `ALU_FUNC_RR) begin
    assert(out == {flag_in_c, x[7:1]});
    assert(flag_s == out[7]);
    assert(flag_z == (out == 0));
    assert(flag_5 == flag_in_5);
    assert(flag_h == 0);
    assert(flag_3 == flag_in_3);
    assert(flag_v == parity8(out));
    assert(flag_n == 0);
    assert(flag_c == x[0]);
  end

  if (func == `ALU_FUNC_RRC) begin
    assert(out == {x[0], x[7:1]});
    assert(flag_s == out[7]);
    assert(flag_z == (out == 0));
    assert(flag_5 == flag_in_5);
    assert(flag_h == 0);
    assert(flag_3 == flag_in_3);
    assert(flag_v == parity8(out));
    assert(flag_n == 0);
    assert(flag_c == x[0]);
  end

  if (func == `ALU_FUNC_RL) begin
    assert(out == {x[6:0], flag_in_c});
    assert(flag_s == out[7]);
    assert(flag_z == (out == 0));
    assert(flag_5 == flag_in_5);
    assert(flag_h == 0);
    assert(flag_3 == flag_in_3);
    assert(flag_v == parity8(out));
    assert(flag_n == 0);
    assert(flag_c == x[7]);
  end

  if (func == `ALU_FUNC_RLC) begin
    assert(out == {x[6:0], x[7]});
    assert(flag_s == out[7]);
    assert(flag_z == (out == 0));
    assert(flag_5 == flag_in_5);
    assert(flag_h == 0);
    assert(flag_3 == flag_in_3);
    assert(flag_v == parity8(out));
    assert(flag_n == 0);
    assert(flag_c == x[7]);
  end
end

`endif

endmodule
