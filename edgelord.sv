`ifndef _edgelord_sv_
`define _edgelord_sv_

`default_nettype none

// module edgelord outputs the state of the clock without using
// the clock in combinatorial logic. This is a good thing in
// FPGAs, where the clock is a special signal that might get
// badly routed if it has to go through anything other than the
// clock inputs of flipflops.
//
// The reset signal MUST be held high for both edges,
// otherwise the clk_state will be inverted.
module edgelord(
    input logic clk,
    input logic reset,

    output clk_state
);

logic pos;
logic neg;
assign clk_state = reset || !(pos ^ neg);

always @(posedge clk) begin
    if (reset) pos <= 0;
    else pos <= !(pos ^ clk_state);
end

always @(negedge clk) begin
    if (reset) neg <= 0;
    else neg <= neg ^ clk_state;
end

`ifdef EDGELORD_FORMAL

reg do_reset;

`ifdef YOSYS
	assume property (do_reset == $initstate);
`endif

reg [7:0] cycle_reg = 0;
wire [7:0] cycle = do_reset ? 0 : cycle_reg;

always @(posedge clk) begin
    cycle_reg <= do_reset ? 1 : cycle_reg + (cycle_reg != 255);
end

always @(*) begin
    assume(reset == cycle < 2);
    if (!reset) assert(clk == clk_state);
end

`endif // EDGELORD_FORMAL

endmodule

`endif // _edgelord_sv_