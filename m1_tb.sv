// Run with:
//           iverilog -g2012 -o m1_tb m1_tb.sv
//           vvp m1_tb
//           gtkwave m1_tb.vcd

`default_nettype none
`timescale 1us/1us

`include "m1.sv"

module m1_tb;

    reg reset = 1;
    reg clk = 0;
    reg active = 0;
    reg [15:0] pc = 0;
    reg [15:0] refresh_addr = 0;
    reg [7:0] D = 0;
    reg nWAIT;

    logic [15:0] A;
    logic nMREQ;
    logic nRD;
    logic nM1;
    logic nRFSH;
    logic [7:0] data_out;
    logic done;

m1 m1(
    .clk(clk),
    .reset(reset),
    .active(active),
    .pc(pc),
    .refresh_addr(refresh_addr),
    .D(D),
    .nWAIT(nWAIT),
    .A(A),
    .nMREQ(nMREQ),
    .nRD(nRD),
    .nM1(nM1),
    .nRFSH(nRFSH),
    .data_out(data_out),
    .done(done)
);

always #5 clk=~clk;

initial begin
    $dumpfile("m1_tb.vcd");
    $dumpvars;

    #15
    reset = 0;
    active = 1;
    pc = 16'h1234;
    refresh_addr = 16'hFEDC;
    D = 8'h89;
    nWAIT = 1;

    #100
    $finish;
end

endmodule
