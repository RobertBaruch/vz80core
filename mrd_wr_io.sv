`ifndef _mrd_wr_io_sv_
`define _mrd_wr_io_sv_

`default_nettype none

`include "z80.vh"

// mrd_wr_io handles signal control for non-M1 I/O read and write cycles.
module mrd_wr_io(
    input logic clk,
    input logic reset,
    input logic activate,
    input logic [15:0] pc,
    input logic [7:0] D_in,
    input logic [7:0] wdata,
    input logic rd,
    input logic wr,
    input logic nWAIT,

    output logic [15:0] A,
    output logic nIORQ,
    output logic nRD,
    output logic nWR,
    output logic [7:0] D_out,
    output logic data_out_en,
    output logic [7:0] rdata,
    output logic done
);

logic [1:0] phase;
logic go;
logic do_rd;
logic do_wr;

// nIORQ, nRD, nWR and data_out_en can change on both positive and negative
// edge of the clock, so they need to be split out and multiplexed
// together.
//
// The go signal also needs to be split out (but not necessarily
// multiplexed).
logic nIORQ_0;
logic nIORQ_1;
logic nRD_0;
logic nRD_1;
logic nWR_0;
logic nWR_1;
logic data_out_en_0;
logic data_out_en_1;
logic go_0;
logic go_1;

assign nIORQ = reset || (clk ? nIORQ_0 : nIORQ_1);
assign nRD = reset || (clk ? nRD_0 : nRD_1);
assign nWR = reset || (clk ? nWR_0 : nWR_1);
assign data_out_en = !reset && (clk ? data_out_en_0 : data_out_en_1);
assign go = clk ? go_0 : go_1;

always @(posedge clk) begin
    if (reset) begin
        A <= 0;
        nIORQ_0 <= 1;
        nRD_0 <= 1;
        nWR_0 <= 1;
        data_out_en_0 <= 0;
        done <= 0;
        go_0 <= 0;
        do_rd <= 0;
        do_wr <= 0;
    end else if ((activate && phase == 0) || go_1) begin
        case (phase)
            0: begin // T1
                do_rd <= rd;
                do_wr <= wr;
                go_0 <= 1;
                A <= pc;
                done <= 0;
                nIORQ_0 <= 1;
                nRD_0 <= 1;
                nWR_0 <= 1;
                data_out_en_0 <= 0;
                D_out <= wdata;
            end
            1: begin // T2
                nIORQ_0 <= 0;
                nRD_0 <= !do_rd;
                nWR_0 <= !do_wr;
                data_out_en_0 <= do_wr;
            end
            2: begin // Twait
                nIORQ_0 <= 0;
                nRD_0 <= !do_rd;
                nWR_0 <= !do_wr;
                data_out_en_0 <= do_wr;
            end
            3: begin // T3
                nIORQ_0 <= 0;
                nRD_0 <= !do_rd;
                nWR_0 <= !do_wr;
                data_out_en_0 <= do_wr;
                done <= 1;
            end
        endcase
    end else begin
        A <= 0;
        nIORQ_0 <= 1;
        nRD_0 <= 1;
        nWR_0 <= 1;
        data_out_en_0 <= 0;
        done <= 0;
        go_0 <= 0;
        do_rd <= 0;
        do_wr <= 0;
    end
end

always @(negedge clk) begin
    if (reset) begin
        phase <= 0;
        nIORQ_1 <= 1;
        nRD_1 <= 1;
        nWR_1 <= 1;
        data_out_en_1 <= 0;
        go_1 <= 0;
    end else if (go_0) begin
        case (phase)
            0: begin // T1
                go_1 <= 1;
                nIORQ_1 <= 1;
                nRD_1 <= 1;
                nWR_1 <= 1;
                data_out_en_1 <= do_wr;
                phase <= 1;
            end
            1: begin // T2
                nIORQ_1 <= 0;
                nRD_1 <= !do_rd;
                nWR_1 <= !do_wr;
                data_out_en_1 <= do_wr;
                phase <= 2;
            end
            2: begin // Twait
                nIORQ_1 <= 0;
                nRD_1 <= !do_rd;
                nWR_1 <= !do_wr;
                data_out_en_1 <= do_wr;
                if (nWAIT) phase <= 3;
            end
            3: begin // T3
                nIORQ_1 <= 1;
                nRD_1 <= 1;
                nWR_1 <= 1;
                data_out_en_1 <= do_wr;
                rdata <= D_in;
                phase <= 0;
                go_1 <= 0;
            end
        endcase
    end else begin
        phase <= 0;
        nIORQ_1 <= 1;
        nRD_1 <= 1;
        nWR_1 <= 1;
        data_out_en_1 <= 0;
        go_1 <= 0;
    end
end

`ifdef FORMAL

reg do_reset;

`ifdef YOSYS
	assume property (do_reset == $initstate);
`endif

reg [7:0] cycle_reg = 0;
wire [7:0] cycle = do_reset ? 0 : cycle_reg;
(* gclk *) reg formal_timestep;

always @(posedge formal_timestep)
    assume (clk == !$past(clk));

always @(posedge clk) begin
    cycle_reg <= do_reset ? 1 : cycle_reg + (cycle_reg != 255);
end

reg did_read = 0;
reg did_write = 0;

always @(posedge clk) begin
    if (!nRD) did_read <= 1;
    if (!nWR) did_write <= 1;
end

always @(*) begin
    assume(reset == cycle < 4);
    assume(activate == (cycle == 5 && !clk));
    assume(pc == 16'h1234);
    assume(D_in == 8'hFE);
    assume(wdata == 8'h67);
end

always @(*) begin
    assume(!(rd && wr)); // rd and wr should be mutually exclusive
    if (activate) assume(rd || wr); // We want to test either read or write cycle.

    assert(!(!nRD && data_out_en)); // We cannot have nRD=0 with data_out_en=1.
    assert(!(!nRD && !nWR)); // We cannot have nRD=0 with nWR=0.
    assert(!nIORQ == (!nRD || !nWR)); // nIORQ should follow nRD or nWR.
    if (!nWR) assert(data_out_en);
    if (data_out_en) assert(D_out == wdata);
    if (!reset && go) assert(A == pc);
    if (!go && did_read) assert(rdata == D_in);

    // Ensure nWAIT for read and write works
    cover(cycle > 10 && done && did_read);
    cover(cycle > 10 && done && did_write);
end

`endif

endmodule

`endif // _mrd_wr_io_sv_