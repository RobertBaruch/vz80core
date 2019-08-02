#!/usr/bin/env python3
#
# Generates files that depend on z80fi_spec* files.

import os
import re


def print_dedent(s: str, **kwargs) -> None:
    """Dedents the given string.

    For multi-line strings, mark the margin of the output with
    a pipe character '|' followed by a space.
    """
    for line in s.split("\n"):
        m = re.match(r"^\s*\| ?(.*)", line)
        if m:
            print(m.group(1), **kwargs)
        else:
            print("", **kwargs)


specs = set()
entries = os.scandir(".")
for entry in entries:
    if entry.is_file() and entry.name.startswith(
            "z80fi_insn_spec_") and entry.name.endswith(".sv"):
        specs.add(entry.name[:-3])

# z80fi_coverage.sby

with open("z80fi_coverage.sby", "w") as f:
    print_dedent(
        """| # DO NOT EDIT -- auto-generated from z80fi_generate.py
        |
        | [options]
        | mode bmc
        | depth 1
        |
        | [engines]
        | smtbmc yices
        |
        | [script]
        | verilog_defines -D Z80_FORMAL
        | read_verilog -sv -formal z80fi_coverage.sv
        | prep -flatten -top coverage
        |
        | [files]
        | z80fi.vh
        | z80fi_coverage.sv
        | z80fi_isa_coverage.sv
        | z80.vh""",
        file=f)
    for spec in specs:
        print(f"{spec}.sv", file=f)

# z80fi_coverage.sv

with open("z80fi_coverage.sv", "w") as f:
    print_dedent(
        f"""| // DO NOT EDIT -- auto-generated from z80fi_generate.py
        |
        | `include "z80fi_isa_coverage.sv"
        |
        | module coverage(
        |     input [31:0] insn,
        |     input [2:0] insn_len
        | );
        |
        | wire [{len(specs)-1}:0] insn_valid;
        |
        | isa_coverage isa_coverage(
        |     .insn(insn),
        |     .insn_len(insn_len),
        |     .valid(insn_valid)
        | );
        |
        | `ifdef FORMAL
        | always_comb begin
        |   // check one-hot conditions
        |   assert(insn_valid == (insn_valid  & -insn_valid ));
        | end
        | `endif
        |
        | endmodule
        """,
        file=f)

# z80fi_isa_coverage.sv

with open("z80fi_isa_coverage.sv", "w") as f:
    print("// DO NOT EDIT -- auto-generated from z80fi_generate.py", file=f)
    print("", file=f)
    for spec in specs:
        print(f'`include "{spec}.sv"', file=f)
    print_dedent(
        f"""
        | module isa_coverage(
        |     input [31:0] insn,
        |     input [2:0] insn_len,
        |     output [{len(specs)-1}:0] valid
        | );
        """,
        file=f)
    for i, spec in enumerate(specs):
        print_dedent(
            f"""
            | {spec} {spec[6:]}(
            |     .z80fi_valid(1'b1),
            |     .z80fi_insn(insn),
            |     .z80fi_insn_len(insn_len),
            |     .z80fi_pc_rdata(16'h0000),
            |     .z80fi_reg1_rdata(16'h0000),
            |     .z80fi_reg2_rdata(16'h0000),
            |     .spec_valid(valid[{i}])
            | );
            """,
            file=f)
    print("endmodule", file=f)

# z80fi_spec*.sby

for spec in specs:
    with open(f"{spec}.sby", "w") as f:
        print_dedent(
            f"""| # DO NOT EDIT -- auto-generated from z80fi_generate.py
            |
            | [tasks]
            | bmc
            | cover
            |
            | [options]
            | bmc: mode bmc
            | cover: mode cover
            | expect pass,fail
            | append 0
            | tbtop wrapper.uut
            | depth 21
            | # skip 20
            |
            | [engines]
            | smtbmc boolector
            |
            | [script]
            | verilog_defines -D Z80_FORMAL=1
            | verilog_defines -D Z80_FORMAL_RESET_CYCLES=1
            | verilog_defines -D Z80_FORMAL_CHECK_CYCLE=20
            | verilog_defines -D Z80_FORMAL_CHECKER=z80_insn_check
            | verilog_defines -D Z80_FORMAL_INSN_MODEL={spec}
            | read_verilog -sv -formal {spec}.sv
            | read_verilog -sv -formal z80fi_testbench.sv
            | prep -flatten -nordff -top z80fi_testbench
            | chformal -early
            |
            | [files]
            | z80fi.vh
            | z80fi_testbench.sv
            | z80fi_insn_check.sv
            | {spec}.sv
            | z80fi_wrapper.sv
            | z80.vh
            | z80.v
            | sequencer.sv
            | registers.sv
            | instr_decoder.sv
            """,
            file=f)
