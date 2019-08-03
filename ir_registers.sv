`ifndef _ir_registers_sv_
`define _ir_registers_sv_

`default_nettype none
`timescale 1us/100 ns

`include "z80.vh"

module ir_registers(
    input logic reset,
    input logic clk,

    // Writing
    input logic i_wr,
    input logic [7:0] i_in,
    input logic r_wr,
    input logic [7:0] r_in,

    output logic [7:0] reg_i,
    output logic [7:0] reg_r
);

logic [7:0] _i;
logic [7:0] _r;

assign reg_i = _i;
assign reg_r = _r;

always @(posedge clk or posedge reset) begin
  if (reset) begin
    _i <= 0;
    _r <= 0;
  end else begin
    if (i_wr) _i <= i_in;
    if (r_wr) _r <= r_in;
  end
end

endmodule

`endif // _ir_registers_sv_
