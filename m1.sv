`ifndef _m1_sv_
`define _m1_sv_

`default_nettype none

`include "z80.vh"

// m1 handles signal control for the M1 memory read cycle.
module m1(
    input logic clk,
    input logic reset,
    input logic activate,
    input logic [15:0] pc,
    input logic [15:0] refresh_addr,
    input logic [7:0] D,
    input logic nWAIT,

    output logic [15:0] A,
    output logic nMREQ,
    output logic nRD,
    output logic nM1,
    output logic nRFSH,
    output logic [7:0] rdata,
    output logic done
);

logic [1:0] phase;
logic go;

// nMREQ and nRD are the only output signals that can change on
// both positive and negative edge of the clock, so they need
// to be split out and multiplexed together.
//
// The go signal also needs to be split out (but not necessarily
// multiplexed).
logic nMREQ_0;
logic nMREQ_1;
logic nRD_0;
logic nRD_1;
logic go_0;
logic go_1;

// Internal nM1 and nRFSH signals so we can guarantee they are 1 on reset.
logic _nM1;
logic _nRFSH;

assign nM1 = reset || _nM1;
assign nRFSH = reset || _nRFSH;
assign nMREQ = reset || (clk ? nMREQ_0 : nMREQ_1);
assign nRD = reset || (clk ? nRD_0 : nRD_1);
assign go = clk ? go_0 : go_1;

always @(posedge clk) begin
    if (reset) begin
        A <= 0;
        nMREQ_0 <= 1;
        nRD_0 <= 1;
        _nM1 <= 1;
        _nRFSH <= 1;
        done <= 0;
        go_0 <= 0;
    end else if ((activate && phase == 0) || go_1) begin
        case (phase)
            0: begin // T1
                go_0 <= 1;
                done <= 0;
                A <= pc;
                nMREQ_0 <= 1;
                nRD_0 <= 1;
                _nM1 <= 0;
                _nRFSH <= 1;
            end
            1: begin // T2
                A <= pc;
                nMREQ_0 <= 0;
                nRD_0 <= 0;
                _nM1 <= 0;
                _nRFSH <= 1;
            end
            2: begin // T3
                A <= refresh_addr;
                nMREQ_0 <= 1;
                nRD_0 <= 1;
                _nM1 <= 1;
                _nRFSH <= 0;
                rdata <= D;
            end
            3: begin // T4
                A <= refresh_addr;
                nMREQ_0 <= 0;
                nRD_0 <= 1;
                _nM1 <= 1;
                _nRFSH <= 0;
                done <= 1;
                go_0 <= 0;
            end
        endcase
    end else begin
        A <= 0;
        nMREQ_0 <= 1;
        nRD_0 <= 1;
        _nM1 <= 1;
        _nRFSH <= 1;
        done <= 0;
        go_0 <= 0;
    end
end

always @(negedge clk) begin
    if (reset) begin
        phase <= 0;
        nMREQ_1 <= 1;
        nRD_1 <= 1;
        go_1 <= 0;
    end else if (go_0) begin
        case (phase)
            0: begin // T1
                go_1 <= 1;
                nMREQ_1 <= 0;
                nRD_1 <= 0;
                phase <= 1;
            end
            1: begin // T2
                nMREQ_1 <= 0;
                nRD_1 <= 0;
                if (nWAIT) phase <= 2;
            end
            2: begin // T3
                nMREQ_1 <= 0;
                nRD_1 <= 1;
                phase <= 3;
            end
            3: begin // T4
                nMREQ_1 <= 1;
                nRD_1 <= 1;
                phase <= 0;
                go_1 <= 0;
            end
        endcase
    end else begin
        phase <= 0;
        nMREQ_1 <= 1;
        nRD_1 <= 1;
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

always @(posedge clk) begin
    cycle_reg <= do_reset ? 1 : cycle_reg + (cycle_reg != 255);
end

reg did_read = 0;

always @(posedge clk) begin
    if (!nRD) did_read <= 1;
end

always @(*) begin
    assume(reset == cycle < 4);
    assume(activate == (cycle == 5 && !clk));
    assume(pc == 16'h1234);
    assume(refresh_addr == 16'h6789);
    assume(D == 8'hFE);
end

always @(*) begin
    // nMREQ must be 0, nRFSH must be 1, and nM1 must be 0 if nRD is 0.
    if (!nRD) assert(!nMREQ && nRFSH && !nM1);

    if (nMREQ) assert(nRD);  // nRD must be 1 if nMREQ is 1.
    if (!nMREQ) assert(!nRD || !nRFSH); // We must be refreshing or reading if nMREQ is 0.
    if (!go && did_read) assert(rdata == D); // rdata must contain correct data.
    assert(!(!nM1 && !nRFSH)); // nM1 and nRFSH may not be simultaneously 0.
    if (!nRFSH) assert(A == refresh_addr);
    if (!nM1) assert(A == pc);

    if (!reset) begin
        if (go && clk && phase == 0) assert(A == pc && !nM1);
        if (go && clk && phase == 1) assert(A == pc && !nM1);
        if (go && clk && phase == 2) assert(A == refresh_addr && !nRFSH);
        if (go && clk && phase == 3) assert(A == refresh_addr && !nRFSH);
    end

    // Ensure nWAIT works
    cover(cycle > 10 && !go && did_read);
end

`endif

endmodule

`endif // _m1_sv_