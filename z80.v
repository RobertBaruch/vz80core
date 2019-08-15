`default_nettype none
`timescale 1us/100 ns

`define Z80_FORMAL
`ifdef Z80_FORMAL
`include "z80fi.vh"
`endif

`include "sequencer.sv"

// The z80. We've only implemented the basic signals so far.
module z80(
    input CLK,
    input nRESET,
    input [7:0] READ_D,

    output nRD,
    output nWR,
    output [15:0] A,
    output [7:0] WRITE_D

`ifdef Z80_FORMAL
    ,
    `Z80FI_OUTPUTS
`endif
);

wire reset = !nRESET;
wire write_mem;
wire read_mem;
logic done;

assign nRD = !read_mem;
assign nWR = !write_mem;

sequencer sequencer(
    .reset(reset),
    .clk(CLK),
    .bus_rdata(READ_D),
    .done(done),
    .addr(A),
    .write_mem(write_mem),
    .read_mem(read_mem),
    .bus_wdata(WRITE_D)

`ifdef Z80_FORMAL
    ,
    `Z80FI_CONN
`endif
);

`ifdef FORMAL
    always @(*) assert(!(write_mem && read_mem));
`endif

endmodule