`include "z80fi_insn_check.sv"
`include "z80fi_wrapper.sv"

`define Z80_FORMAL
`ifndef Z80_FORMAL_RESET_CYCLES
`define Z80_FORMAL_RESET_CYCLES 1
`define Z80_FORMAL_CHECK_CYCLE 20
`define Z80_FORMAL_CHECKER z80fi_insn_check
`endif

module z80fi_testbench (
	input clk, reset
);
	`Z80FI_WIRES

`ifdef YOSYS
	assume property (reset == $initstate);
`endif

	reg [7:0] cycle_reg = 0;
	wire [7:0] cycle = reset ? 0 : cycle_reg;

	(* gclk *) reg formal_timestep;

	always @(posedge formal_timestep)
		assume (clk == !$past(clk));

	always @(posedge clk) begin
		cycle_reg <= reset ? 1 : cycle_reg + (cycle_reg != 255);
	end

	`Z80_FORMAL_CHECKER checker_inst (
		.clk  (clk),
		.reset  (cycle < `Z80_FORMAL_RESET_CYCLES),
`ifdef Z80_FORMAL_CHECK_CYCLE
		.check  (cycle == `Z80_FORMAL_CHECK_CYCLE),
`endif
		`Z80FI_CONN
	);

	z80fi_wrapper wrapper (
		.clk (clk),
		.reset (cycle < `Z80_FORMAL_RESET_CYCLES),
		`Z80FI_CONN
	);
endmodule