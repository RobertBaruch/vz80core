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


def bit(i: int, l: int) -> str:
    """Constructs a bit string of length l whose i'th bit is set.
    """
    return f"{l}'b" + "".join("1" if x == l - i - 1 else "0" for x in range(l))


# z80fi_signals.vh

# Define all the formal interface signals. Format is {name, bits}.
z80fi_signals = [("valid", 1), ("insn", 32), ("insn_len", 3), ("pc_rdata", 16),
                 ("pc_wdata", 16), ("reg1_rd", 1), ("reg1_rnum", 4),
                 ("reg2_rnum", 4), ("reg1_rdata", 16), ("reg2_rd", 1),
                 ("reg2_rdata", 16), ("reg_wr", 1), ("reg_wnum", 4),
                 ("reg_wdata", 16), ("mem_rd", 1), ("mem_raddr", 16),
                 ("mem_rdata", 8), ("mem_rd2", 1), ("mem_raddr2", 16),
                 ("mem_rdata2", 8), ("mem_wr", 1), ("mem_waddr", 16),
                 ("mem_wdata", 8), ("mem_wr2", 1), ("mem_waddr2", 16),
                 ("mem_wdata2", 8), ("i_rd", 1), ("i_wr", 1), ("i_rdata", 8),
                 ("i_wdata", 8), ("r_rd", 1), ("r_wr", 1), ("r_rdata", 8),
                 ("r_wdata", 8), ("f_rd", 1), ("f_wr", 1), ("f_rdata", 8),
                 ("f_wdata", 8), ("iff1_rd", 1), ("iff1_rdata", 1),
                 ("iff2_rd", 1), ("iff2_rdata", 1)]

# In addition to valid, insn, and insn_len, all _rdata signals need to
# be listed here.
z80fi_spec_inputs = [
    "valid", "insn", "insn_len", "pc_rdata", "reg1_rdata", "reg2_rdata",
    "mem_rdata", "mem_rdata2", "i_rdata", "r_rdata", "f_rdata", "iff1_rdata",
    "iff2_rdata"
]
z80fi_spec_outputs = [
    s[0] for s in z80fi_signals if s[0] not in z80fi_spec_inputs
]

# These signals are generally single-bit signals indicating whether the
# corresponding data (e.g. _rdata, _wdata, _raddr, etc) are modified/need
# to be checked.
z80fi_action_signals = [
    "reg1_rd", "reg2_rd", "reg_wr", "mem_rd", "mem_rd2", "mem_wr", "mem_wr2",
    "i_rd", "i_wr", "r_rd", "r_wr", "f_rd", "f_wr", "iff1_rd", "iff2_rd"
]

z80fi_spec_signals = "\n".join([
    f"| `define SPEC_{s.upper()} {bit(i, len(z80fi_action_signals))}"
    for i, s in enumerate(z80fi_action_signals)
])
z80fi_action_assignments = "; \\\n".join([
    f"| assign spec_{s} = spec_signals[{i}]"
    for i, s in enumerate(z80fi_action_signals)
]) + ";"

z80fi_spec_wires = "| logic [0:0] valid = !reset && z80fi_valid; \\\n"  # WIRE
# Skip valid, which we already added above.
z80fi_spec_wires += " \\\n".join([
    f"| logic [{s[1]-1}:0] {s[0]} = z80fi_{s[0]};"  # WIRE
    for s in z80fi_signals[1:] if s[0] in z80fi_spec_inputs
]) + " \\\n| \\\n"
z80fi_spec_wires += " \\\n".join([
    f"| logic [{s[1]-1}:0] {s[0]} = z80fi_{s[0]};"  # WIRE
    for s in z80fi_signals if s[0] in z80fi_spec_outputs
]) + " \\\n| \\\n"
# Add valid, which outputs doesn't have.
z80fi_spec_wires += "| logic [0:0] spec_valid; \\\n"
z80fi_spec_wires += " \\\n".join([
    f"| logic [{s[1]-1}:0] spec_{s[0]};" for s in z80fi_signals
    if s[0] in z80fi_spec_outputs
])

z80fi_spec_conns = ", \\\n".join(
    [f"| .z80fi_{s} ({s})" for s in z80fi_spec_inputs]) + ", \\\n"
z80fi_spec_conns += "| .spec_valid (spec_valid), \\\n"
z80fi_spec_conns += ", \\\n".join(
    [f"| .spec_{s} (spec_{s})" for s in z80fi_spec_outputs])

z80fi_inputs = ", \\\n".join(
    [f"| input [{s[1]-1}:0] z80fi_{s[0]}" for s in z80fi_signals])
z80fi_outputs = ", \\\n".join(
    [f"| output logic [{s[1]-1}:0] z80fi_{s[0]}" for s in z80fi_signals])
z80fi_wires = "; \\\n".join(
    [f"| logic [{s[1]-1}:0] z80fi_{s[0]}" for s in z80fi_signals]) + ";"

z80fi_next_state = "; \\\n".join(
    [f"| logic [{s[1]-1}:0] next_z80fi_{s[0]}" for s in z80fi_signals]) + ";"
z80fi_reset_state = "; \\\n".join(
    [f"| z80fi_{s[0]} <= 0" for s in z80fi_signals]) + ";"
z80fi_load_next_state = "; \\\n".join(
    [f"| z80fi_{s[0]} <= next_z80fi_{s[0]}" for s in z80fi_signals]) + ";"

# Special case: we skip the first element, valid, which must be set to 0.
z80fi_retain_next_state = "; \\\n".join(
    [f"| next_z80fi_{s[0]} = z80fi_{s[0]}" for s in z80fi_signals][1:]) + ";"

z80fi_init_next_state = "; \\\n".join(
    [f"| next_z80fi_{s[0]} = 0" for s in z80fi_signals]) + ";"
z80fi_conn = ", \\\n".join(
    [f"| .z80fi_{s[0]} (z80fi_{s[0]})" for s in z80fi_signals])
z80fi_spec_io = ", \\\n".join([
    f"| input [{s[1]-1}:0] z80fi_{s[0]}" if s[0] in z80fi_spec_inputs else
    f"| output logic [{s[1]-1}:0] spec_{s[0]}" for s in z80fi_signals
])

with open("z80fi_signals.vh", "w") as f:
    print_dedent(
        f"""| // DO NOT EDIT -- auto-generated from z80fi_generate.py
        |
        | `define Z80FI_INPUTS \\
        {z80fi_inputs}
        |
        | `define Z80FI_OUTPUTS \\
        {z80fi_outputs}
        |
        | `define Z80FI_WIRES \\
        {z80fi_wires}
        |
        | `define Z80FI_NEXT_STATE \\
        {z80fi_next_state}
        |
        | `define Z80FI_RESET_STATE \\
        {z80fi_reset_state}
        |
        | `define Z80FI_LOAD_NEXT_STATE \\
        {z80fi_load_next_state}
        |
        | `define Z80FI_RETAIN_NEXT_STATE \\
        | next_z80fi_valid = 0; \\
        {z80fi_retain_next_state}
        |
        | `define Z80FI_INIT_NEXT_STATE \\
        {z80fi_init_next_state}
        |
        | `define Z80FI_CONN \\
        {z80fi_conn}
        |
        | `define Z80FI_INSN_SPEC_IO \\
        | output logic [0:0] spec_valid, \\
        {z80fi_spec_io}
        |
        {z80fi_spec_signals}
        |
        | `define Z80FI_SPEC_SIGNALS \\
        | logic [{len(z80fi_action_signals)-1}:0] spec_signals; \\
        {z80fi_action_assignments}
        |
        | `define Z80FI_SPEC_WIRES \\
        {z80fi_spec_wires}
        |
        | `define Z80FI_SPEC_CONNS \\
        {z80fi_spec_conns}
        """,
        file=f)

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
        | z80fi_signals.vh
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
            | z80fi_signals.vh
            | z80fi_testbench.sv
            | z80fi_insn_check.sv
            | {spec}.sv
            | z80fi_wrapper.sv
            | z80.vh
            | z80.v
            | sequencer.sv
            | sequencer_tasks.vh
            | registers.sv
            | ir_registers.sv
            | instr_decoder.sv
            """,
            file=f)
