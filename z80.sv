`default_nettype none
`timescale 1us/1us

`ifdef Z80_FORMAL
`include "z80fi.vh"
`endif

`include "sequencer.sv"
`include "mcycle.sv"

// The z80. We've only implemented the basic signals so far.
module z80(
    input CLK,
    input nRESET,
    input nWAIT,
    input [7:0] READ_D,

    output nMREQ,
    output nIORQ,
    output nRD,
    output nWR,
    output nM1,
    output nRFSH,
    output [15:0] A,
    output [7:0] WRITE_D

`ifdef Z80_FORMAL
    ,
    `Z80FI_OUTPUTS
`endif
);

logic reset;
assign reset = !nRESET;

logic mcycle_done;
logic [2:0] _mcycle;
logic [2:0] tcycle;
logic extra_tcycle;
logic mem_wr;
logic mem_rd;
logic io_wr;
logic io_rd;
logic extend_cycle;
logic [2:0] internal_cycle;
logic opcode_fetch;
logic data_out_en;
logic done;
logic [15:0] seq_addr;
logic [7:0] seq_rdata;
logic [7:0] seq_wdata;
logic [15:0] refresh_addr = 16'hFACE;

// The sequencer communicates with the mcycle module to do what it needs to, namely:
//
// 1. Do an opcode fetch (i.e. read memory in an M1 cycle)
// 2. Read or write memory
// 3. Read or write I/O
sequencer sequencer(
    .reset(reset),
    .clk(CLK),
    .bus_rdata(seq_rdata),
    .mcycle_done(mcycle_done),
    .mcycle(_mcycle),
    .tcycle(tcycle),
    .extra_tcycle(extra_tcycle),

    .addr(seq_addr),
    .mem_wr(mem_wr),
    .mem_rd(mem_rd),
    .io_wr(io_wr),
    .io_rd(io_rd),
    .extend_cycle(extend_cycle),
    .internal_cycle(internal_cycle),
    .bus_wdata(seq_wdata),
    .opcode_fetch(opcode_fetch)

`ifdef Z80_FORMAL
    ,
    `Z80FI_CONN
`endif
);

logic [2:0] cycle;
assign cycle = opcode_fetch ? `CYCLE_M1 :
               (mem_wr || mem_rd) ? `CYCLE_RDWR_MEM :
               (io_wr || io_rd) ? `CYCLE_RDWR_IO :
               internal_cycle == 5 ? `CYCLE_INTERNAL :
               internal_cycle == 4 ? `CYCLE_INTERNAL4 :
               internal_cycle == 3 ? `CYCLE_INTERNAL3 :
               `CYCLE_NONE;

mcycle mcycle(
    .clk(CLK),
    .reset(reset),
    .pc(seq_addr),
    .refresh_addr(refresh_addr),
    .D_in(READ_D),
    .wdata(seq_wdata),
    .rd(mem_rd || io_rd),
    .wr(mem_wr || io_wr),
    .nWAIT(nWAIT),
    .cycle(cycle),
    .extend_cycle(extend_cycle),

    .A(A),
    .nMREQ(nMREQ),
    .nIORQ(nIORQ),
    .nRD(nRD),
    .nWR(nWR),
    .nM1(nM1),
    .nRFSH(nRFSH),
    .D_out(WRITE_D),
    .data_out_en(data_out_en),
    .rdata(seq_rdata),
    ._mcycle(_mcycle),
    .tcycle(tcycle),
    .extra_tcycle(extra_tcycle),
    .done(mcycle_done)
);

endmodule