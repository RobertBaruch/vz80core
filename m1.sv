`ifndef _m1_sv_
`define _m1_sv_

`default_nettype none

`include "z80.vh"
`include "edgelord.sv"

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
    output logic [2:0] tcycle,
    output logic done
);

// Clones the clk without exposing clk to combinatorial logic.
logic clk_state;
edgelord edgelord(
    .clk(clk),
    .reset(reset),
    .clk_state(clk_state)
);

// The data here needs to be the output of a transparent latch,
// because during T3 and T4 the refresh address, not the PC,
// is on the address lines.
logic [7:0] latched_data;
assign rdata = (tcycle == 3 || tcycle == 4) ? latched_data : D;

logic latched_nwait;

always @(posedge clk) begin
    if (reset) begin
        tcycle <= 0;  // inactive
        latched_data <= 0;
    end else begin
        case (tcycle)
            0: tcycle <= activate ? 1 : 0;
            1: tcycle <= 2;
            2: tcycle <= !latched_nwait ? 2 : 3;
            3: tcycle <= 4;
            4: tcycle <= activate ? 1 : 0;
            default: tcycle <= 0;
        endcase

        if (tcycle == 2) latched_data <= D;
    end
end

always @(negedge clk) begin
    latched_nwait <= tcycle == 2 && nWAIT;
end

always @(*) begin
    case (tcycle)
        1: begin  // T1
            A = pc;
            nMREQ = clk_state;
            nRD = clk_state;
            nM1 = 0;
            nRFSH = 1;
            done = 0;
        end
        2: begin  // T2
            A = pc;
            nMREQ = 0;
            nRD = 0;
            nM1 = 0;
            nRFSH = 1;
            done = 0;
        end
        3: begin  // T3
            A = refresh_addr;
            nMREQ = clk_state;
            nRD = 1;
            nM1 = 1;
            nRFSH = 0;
            done = 0;
        end
        4: begin  // T4
            A = refresh_addr;
            nMREQ = ~clk_state;
            nRD = 1;
            nM1 = 1;
            nRFSH = 0;
            done = ~clk_state;
        end
        default: begin
            A = 0;
            nMREQ = 1;
            nRD = 1;
            nM1 = 1;
            nRFSH = 1;
            done = 0;
        end
    endcase

    if (reset) begin
        A = 0;
        nMREQ = 1;
        nRD = 1;
        nM1 = 1;
        nRFSH = 1;
        done = 0;
    end
end


`ifdef MCYCLE_FORMAL

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
    if (tcycle == 2 && !clk) assume(D == 8'hFE);
    else assume(D == 8'h00);

    // nMREQ must be 0, nRFSH must be 1, and nM1 must be 0 if nRD is 0.
    if (!nRD) assert(!nMREQ && nRFSH && !nM1);

    if (nMREQ) assert(nRD);  // nRD must be 1 if nMREQ is 1.
    if (!nMREQ) assert(!nRD || !nRFSH); // We must be refreshing or reading if nMREQ is 0.
    if (did_read && tcycle == 4) assert(rdata == 8'hFE); // rdata must contain correct data.
    assert(!(!nM1 && !nRFSH)); // nM1 and nRFSH may not be simultaneously 0.
    if (!nRFSH) assert(A == refresh_addr);
    if (!nM1) assert(A == pc);

    // Ensure nWAIT works
    cover(cycle == 20 && done && did_read);
end

`endif

endmodule

`endif // _m1_sv_