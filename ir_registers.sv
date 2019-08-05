`ifndef _ir_registers_sv_
`define _ir_registers_sv_

`include "z80.vh"

module ir_registers(
    input logic reset,
    input logic clk,

    // Writing
    input logic i_wr,
    input logic [7:0] i_in,
    input logic r_wr,
    input logic [7:0] r_in,

    input logic enable_interrupts,
    input logic disable_interrupts,
    input logic accept_nmi,
    input logic ret_from_nmi,

    output logic [7:0] reg_i,
    output logic [7:0] reg_r,

    // Interrupt enable flags.
    output logic iff1,
    output logic iff2
);

logic [7:0] _i;
logic [7:0] _r;

assign reg_i = _i;
assign reg_r = _r;

always @(posedge clk or posedge reset) begin
  if (reset) begin
    _i <= 0;
    _r <= 0;
    iff1 <= 0;
    iff2 <= 0;
  end else begin
    if (i_wr) _i <= i_in;
    if (r_wr) _r <= r_in;

    if (enable_interrupts) begin
      iff1 <= 1;
      iff2 <= 1;
    end else if (disable_interrupts) begin
      iff1 <= 0;
      iff2 <= 0;
    end else if (accept_nmi) begin
      iff1 <= 0;
      iff2 <= iff1;
    end else if (ret_from_nmi) begin
      iff1 <= iff2;
    end
  end
end

endmodule

`endif // _ir_registers_sv_
