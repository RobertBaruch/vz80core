// Run with: 
//           iverilog -g2009 -o sequencer_tb sequencer_tb.sv
//           vvp sequencer_tb
//           gtkwave sequencer_tb.vcd

`default_nettype none
`timescale 1us/100 ns

`include "sequencer.sv"

module sequencer_tb;

    reg reset = 1;
    reg clk = 0;
    logic [7:0] mem_data;
    logic done;

    logic [15:0] addr;
    logic write_mem;
    logic read_mem;
    logic [7:0] write_data;


sequencer sequencer(
    .reset(reset),
    .clk(clk),
    .mem_data(mem_data),
    .done(done),
    .addr(addr),
    .write_mem(write_mem),
    .read_mem(read_mem),
    .write_data(write_data)
);

always #1 clk=~clk;

always @(*) begin
    if (addr == 0) mem_data = 8'h22;
    else if (addr == 1) mem_data = 8'h99;
    else if (addr == 2) mem_data = 8'hAA;
    else if (addr == 3) mem_data = 8'hBB;
    else if (addr == 4) mem_data = 8'hCC;
    else if (addr == 5) mem_data = 8'hDD;
    else mem_data = addr[7:0]^addr[15:8];
end

initial begin
    $dumpfile("sequencer_tb.vcd");
    $dumpvars;

    #2
    reset = 0;

    #20
    $finish;
end

endmodule
