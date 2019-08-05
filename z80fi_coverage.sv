// DO NOT EDIT -- auto-generated from z80fi_generate.py

`include "z80fi_isa_coverage.sv"

module coverage(
    input [31:0] insn,
    input [2:0] insn_len
);

wire [22:0] insn_valid;

isa_coverage isa_coverage(
    .insn(insn),
    .insn_len(insn_len),
    .valid(insn_valid)
);

`ifdef FORMAL
always_comb begin
  // check one-hot conditions
  assert(insn_valid == (insn_valid  & -insn_valid ));
end
`endif

endmodule

