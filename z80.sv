`default_nettype none
`timescale 1us/1us

`ifdef Z80_FORMAL
`include "z80fi.vh"
`endif

`include "sequencer.sv"
`include "mcycle.sv"

// The z80. We've only implemented the basic signals so far.
module z80(
    input logic CLK,
    input logic nRESET,
    input logic nWAIT,
    input logic [7:0] READ_D,
    input logic nBUSRQ,

    output logic nMREQ,
    output logic nIORQ,
    output logic nRD,
    output logic nWR,
    output logic nM1,
    output logic nRFSH,
    output logic nBUSAK,
    output logic [15:0] A,
    output logic [7:0] WRITE_D

`ifdef Z80_FORMAL
    ,
    `Z80FI_OUTPUTS
`endif
);

logic reset;
assign reset = !nRESET;

logic latched_busreq;
logic stall_cycle;

logic next_busreq;
assign next_busreq = mcycle_done && latched_busreq;
assign stall_cycle = !reset && (next_busreq || !nBUSAK);

always @(posedge CLK) begin
    if (reset) begin
        nBUSAK <= 1;
        latched_busreq <= 0;

    end else begin
        latched_busreq <= !nBUSRQ;
        if (next_busreq) nBUSAK <= 0;
        else if (!latched_busreq && !nBUSAK) nBUSAK <= 1;
    end
end

logic mcycle_done;
logic [2:0] _mcycle;
logic [2:0] tcycle;
logic extra_tcycle;
logic waitstated;
logic mem_wr;
logic mem_rd;
logic io_wr;
logic io_rd;
logic extend_cycle;
logic internal_cycle;
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
    .stall_cycle(stall_cycle),
    .waitstated(waitstated),

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
assign cycle = (opcode_fetch || reset) ? `CYCLE_M1 :
               (mem_wr || mem_rd) ? `CYCLE_RDWR_MEM :
               (io_wr || io_rd) ? `CYCLE_RDWR_IO :
               internal_cycle ? `CYCLE_INTERNAL :
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
    .waitstated(waitstated),
    .done(mcycle_done)
);

endmodule