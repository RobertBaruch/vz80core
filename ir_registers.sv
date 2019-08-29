`ifndef _ir_registers_sv_
`define _ir_registers_sv_

`include "z80.vh"

`default_nettype none
`timescale 1us/1us

module ir_registers(
    input logic reset,
    input logic clk,

    // Writing
    input logic i_wr,
    input logic [7:0] i_in,
    input logic r_wr,
    input logic [7:0] r_in,

    input logic enable_interrupts,
    input logic disable_interrupts,
    input logic accept_nmi,
    input logic ret_from_nmi,
    // instruction will complete on next clock posedge.
    input logic next_insn_done,

    output logic [7:0] reg_i,
    output logic [7:0] reg_r,

    // Interrupt enable flags.
    output logic iff1,
    output logic iff2,
    output logic delayed_enable_interrupts
);

logic [7:0] _i;
logic [7:0] _r;
assign reg_i = _i;
assign reg_r = _r;

// * disable_interrupts must disable interrupts during its execution.
//   We implement this by gating the "internal" iff1 and iff2 signals
//   by !disable_interrupts, also resetting them on the clock.
//
// * enable_interrupts must not enable interrupts until after the
//   execution of the _following_ instruction, and must also disable
//   interrupts during its execution and the execution of the following
//   instruction.
always @(posedge clk or posedge reset) begin
  if (reset) begin
    _i <= 0;
    _r <= 0;
    iff1 <= 0;
    iff2 <= 0;
    delayed_enable_interrupts <= 0;

  end else begin
    if (i_wr) _i <= i_in;
    if (r_wr) _r <= r_in;

    if (disable_interrupts) begin
      iff1 <= 0;
      iff2 <= 0;
      delayed_enable_interrupts <= 0;

    end else if (enable_interrupts) begin
      iff1 <= 1;
      iff2 <= 1;
      delayed_enable_interrupts <= 1;

    end else if (accept_nmi) begin
      iff1 <= 0;
      iff2 <= iff1;
      delayed_enable_interrupts <= 0;

    end else if (ret_from_nmi) begin
      iff1 <= iff2;
      delayed_enable_interrupts <= 0;

    end else if (next_insn_done && delayed_enable_interrupts) begin
      delayed_enable_interrupts <= 0;
    end

  end
end

`ifdef IR_REGISTERS_FORMAL

initial assume(reset);

logic past_valid;
initial	past_valid = 0;
always @(posedge clk) past_valid <= 1;

// Not really "since", because when EI happens, we set this to 1.
logic [2:0] instrs_since_ei;
initial instrs_since_ei = 0;

// Count the number of next_insn_done transitions since
// the last enable_interrupts. Note that disable_interrupts
// cancels this, since it will immediately disable interrupts.
always @(posedge clk or posedge reset) begin
  if (reset) begin
    instrs_since_ei <= 0;
  end else begin
    if (disable_interrupts)
      instrs_since_ei <= 0;
    else if (next_insn_done && enable_interrupts)
      instrs_since_ei <= 1;
    else if (next_insn_done && instrs_since_ei > 0)
      instrs_since_ei <= instrs_since_ei + 1;
  end
end

logic [1:0] tests;
wire testing_ei = tests[0];
wire testing_di = tests[1];

// These tests look only at the internal iff1 and iff2 signals, because
// iff1 and iff2 are effectively generated asynchronously, independent
// of the clock or reset.
always @(posedge clk) begin
  assume(!accept_nmi);
  assume(!ret_from_nmi);

  // State that we execute one and only one test.
  assume(tests == (tests & -tests) && tests != 0);

  // State that reset and disable_interrupts happen at the same time,
  // and we don't trigger enabling interrupts.
  if (reset) assume(disable_interrupts && !enable_interrupts);

  // State that we will not disable and enable interrupts at the
  // same time.
  if (!reset) assume(!(disable_interrupts && enable_interrupts));

  // State that execution of EI takes only one cycle.
  if (enable_interrupts && !reset) assume(next_insn_done);

  // State that execution of DI takes only one cycle.
  if (disable_interrupts && !reset) assume(next_insn_done);

  if (past_valid) begin
    // State that we do not switch tests midway.
    if ($past(testing_ei)) assume(testing_ei);
    if ($past(testing_di)) assume(testing_di);

    if (testing_ei) begin
      // State that we only have 6 instructions.
      assume(instrs_since_ei < 7);

      // Ensure that the EI instruction enables interrupts. Note that
      // the internal signals are gated!
      if (instrs_since_ei == 1) assert(iff1 && iff2);

      // Ensure that the EI instruction enables interrupts after
      // the next instruction.
      if (instrs_since_ei == 2) assert(iff1 && iff2);
    end

    if (testing_di) begin
      // State that we somehow end up in a state where iff1 or iff2 are set.
      if (!reset && !disable_interrupts) assume(iff1 || iff2);

      // Ensure that DI causes iff1 and iff2 to reset.
      if (disable_interrupts) assert(!iff1 && !iff2);
    end

    // Show us how to enable interrupts.
    cover(iff1 && iff2);
  end
end


`endif

endmodule

`endif // _ir_registers_sv_
