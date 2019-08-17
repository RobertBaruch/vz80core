`default_nettype none
`timescale 1us/100 ns

`ifdef Z80_FORMAL
`include "z80fi.vh"
`endif

`include "sequencer.sv"

// The z80. We've only implemented the basic signals so far.
module z80(
    input CLK,
    input nRESET,
    input [7:0] READ_D,

    output nMREQ,
    output nIORQ,
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
wire mem_wr;
wire mem_rd;
wire io_wr;
wire io_rd;
logic done;

assign nRD = !(mem_rd || io_rd);
assign nWR = !(mem_wr || io_wr);
assign nMREQ = !(mem_rd || mem_wr);
assign nIORQ = !(io_rd || io_wr);

sequencer sequencer(
    .reset(reset),
    .clk(CLK),
    .bus_rdata(READ_D),
    .done(done),
    .addr(A),
    .mem_wr(mem_wr),
    .mem_rd(mem_rd),
    .io_wr(io_wr),
    .io_rd(io_rd),
    .bus_wdata(WRITE_D)

`ifdef Z80_FORMAL
    ,
    `Z80FI_CONN
`endif
);

`ifdef FORMAL
    always @(*) begin
        assert(!(mem_wr && mem_rd));
        assert(!(io_wr && io_rd));
        assert(!((mem_wr || mem_rd) && (io_wr || io_rd)));
    end
`endif

endmodule