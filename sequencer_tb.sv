// Run with:
//           iverilog -g2012 -o sequencer_tb sequencer_tb.sv
//           vvp sequencer_tb
//           gtkwave sequencer_tb.vcd

`include "sequencer.sv"

`default_nettype none
`timescale 1us/1us

module sequencer_tb;

reg reset = 1;
reg clk = 0;
logic [7:0] bus_rdata;
logic mcycle_done;

logic done;
logic [15:0] addr;
logic mem_wr;
logic mem_rd;
logic io_wr;
logic io_rd;
logic [7:0] bus_wdata;
logic opcode_fetch;

sequencer sequencer(
    .reset(reset),
    .clk(clk),
    .bus_rdata(bus_rdata),
    .mcycle_done(mcycle_done),

    .done(done),
    .addr(addr),
    .mem_wr(mem_wr),
    .mem_rd(mem_rd),
    .io_wr(io_wr),
    .io_rd(io_rd),
    .bus_wdata(bus_wdata),
    .opcode_fetch(opcode_fetch)
);

always #1 clk=~clk;

always begin
    mcycle_done = 0;
    #6 mcycle_done = 1;
    #2 ;
end

always @(*) begin
    case (addr)
        0: bus_rdata = 8'h00;  // NOP
        1: bus_rdata = 8'h0C;  // INC C
        2: bus_rdata = 8'h0E;  // LD C, 0x10
        3: bus_rdata = 8'h10;
        4: bus_rdata = 8'h21;  // LD HL, 0x1234
        5: bus_rdata = 8'h12;
        6: bus_rdata = 8'h34;
        7: bus_rdata = 8'h4E;  // LD C, (HL)
        8: bus_rdata = 8'h71;  // LD (HL), C
        9: bus_rdata = 8'h00;  // NOP
        10: bus_rdata = 8'h00;  // NOP
        11: bus_rdata = 8'h00;  // NOP
        12: bus_rdata = 8'h00;  // NOP
        13: bus_rdata = 8'h00;  // NOP
        14: bus_rdata = 8'h00;  // NOP
        15: bus_rdata = 8'h00;  // NOP
        default: bus_rdata = 8'hFF;
    endcase
end

initial begin
    $dumpfile("sequencer_tb.vcd");
    $dumpvars;

    #2
    reset = 0;

    #120
    $finish;
end

endmodule
