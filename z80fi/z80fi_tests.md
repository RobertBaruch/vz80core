z80fi_cover:
  Ensures that the processor can read and write memory several times.

z80fi_coverage:
  Ensures that the z80fi_insn_spec_* modules uniquely handle
  each instruction (checking spec_valid).

z80fi_insn_spec_*:
  Ensures that the specified instructions executed by the core, via
  z80fi_testbench and z80fi_insn_check, conform to the spec.
  If there's a warmup failure, check the result of the cover
  statement, because maybe the instruction just fails to execute.
  Also check the elements of spec_valid.
  If all else fails, use sequencer_tb.sv to debug what's going on,
  since a warmup failure means that spec_valid never went high.

sequencer_tb.sv:
  A simple testbench to execute an instruction, for debugging.