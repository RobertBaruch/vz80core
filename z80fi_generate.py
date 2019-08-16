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
z80fi_signals = [("valid", 1), ("insn", 32), ("insn_len", 3),
                 ("bus_raddr", 16), ("bus_rdata", 8), ("bus_raddr2", 16),
                 ("bus_rdata2", 8), ("bus_waddr", 16), ("bus_wdata", 8),
                 ("bus_waddr2", 16), ("bus_wdata2", 8), ("mem_rd", 1),
                 ("mem_rd2", 1), ("mem_wr", 1), ("mem_wr2", 1), ("io_rd", 1),
                 ("io_wr", 1)]

# These are the signals which are registers, so they don't have to be
# registered again. z80fi signals will be generated for z80fi_{register}_in and
# z80fi_{register}_out.
z80fi_registers = [("reg_ip", 16), ("reg_a", 8), ("reg_f", 8), ("reg_b", 8),
                   ("reg_c", 8), ("reg_d", 8), ("reg_e", 8), ("reg_h", 8),
                   ("reg_l", 8), ("reg_a2", 8), ("reg_f2", 8), ("reg_b2", 8),
                   ("reg_c2", 8), ("reg_d2", 8), ("reg_e2", 8), ("reg_h2", 8),
                   ("reg_l2", 8), ("reg_ix", 16), ("reg_iy", 16),
                   ("reg_sp", 16), ("reg_i", 8), ("reg_r", 8), ("reg_iff1", 1),
                   ("reg_iff2", 1)]
z80fi_registers_in = [(f"{s[0]}_in", s[1]) for s in z80fi_registers]
z80fi_registers_out = [(f"{s[0]}_out", s[1]) for s in z80fi_registers]

# In addition to valid, insn, and insn_len, all _rdata signals need to
# be listed here.
z80fi_spec_inputs = ["valid", "insn", "insn_len", "bus_rdata", "bus_rdata2"]
z80fi_spec_outputs = [
    s[0] for s in z80fi_signals if s[0] not in z80fi_spec_inputs
]

# These signals are generally single-bit signals indicating whether the
# corresponding data (e.g. _rdata, _wdata, _raddr, etc) are modified/need
# to be checked. The reg_X signals are just for the spec, to let
# the insn_check known which registers may change.
#
# In the insn_spec file, use, for example:
#
# `Z80FI_SPEC_SIGNALS
# assign spec_signals = `SPEC_REG_A | `SPEC_MEM_RD;
#
# This indicates that register A changes, and a memory read happens.
#
# If a register changes, or a write happens, you must also specify the
# expected change. For example, for register A:
#
# assign spec_reg_a_out = ...;
z80fi_action_signals = [("mem_rd", 1), ("mem_rd2", 1), ("mem_wr", 1),
                        ("mem_wr2", 1), ("io_rd", 1), ("io_wr", 1)]

# Z80FI_SPEC_SIGNALS
z80fi_spec_signals = "\n".join([
    f"| `define SPEC_{s[0].upper()} {bit(i, len(z80fi_action_signals + z80fi_registers))}"
    for i, s in enumerate(z80fi_action_signals + z80fi_registers)
])
z80fi_action_assignments = "; \\\n".join([
    f"| assign spec_{s[0]} = spec_signals[{i}]"
    for i, s in enumerate(z80fi_action_signals + z80fi_registers)
]) + ";"

# Z80FI_INSN_SPEC_IO are the I/O for z80fi_insn_spec files: inputs for the
# z80fi signals, and outputs for the spec signals.

z80fi_spec_io = ", \\\n".join([
    f"| input [{s[1]-1}:0] z80fi_{s[0]}" if s[0] in z80fi_spec_inputs else
    f"| output logic [{s[1]-1}:0] spec_{s[0]}" for s in z80fi_signals
]) + ", \\\n"
z80fi_spec_io += ", \\\n".join(
    [f"| input [{s[1]-1}:0] z80fi_{s[0]}"
     for s in z80fi_registers_in]) + ", \\\n"
z80fi_spec_io += ", \\\n".join(
    [f"| output logic [{s[1]-1}:0] spec_{s[0]}"
     for s in z80fi_registers_out]) + ", \\\n"
z80fi_spec_io += ", \\\n".join(
    [f"| output logic [0:0] spec_{s[0]}" for s in z80fi_registers])

# The Z80FI_SPEC_WIRES are connections to Z80FI_INPUTS and Z80FI_INSN_SPEC_IO:

z80fi_spec_wires = "| wire [0:0] valid = !reset && z80fi_valid; \\\n"
# Skip valid, which we already added above.
z80fi_spec_wires += " \\\n".join([
    f"| wire [{s[1]-1}:0] {s[0]} = z80fi_{s[0]};"
    for s in z80fi_signals + z80fi_registers_in + z80fi_registers_out
    if s[0] != "valid"
]) + " \\\n| \\\n"

# Add valid, which z80fi_spec_outputs doesn't have.
z80fi_spec_wires += "| logic [0:0] spec_valid; \\\n"
z80fi_spec_wires += "; \\\n".join([
    f"| logic [{s[1]-1}:0] spec_{s[0]}"
    for s in z80fi_signals + z80fi_registers_out if s[0] != "valid"
]) + "; \\\n"
z80fi_spec_wires += "; \\\n".join(
    [f"| logic [0:0] spec_{s[0]}" for s in z80fi_registers]) + ";"

# Z80FI_SPEC_CONNS are module connections to Z80FI_INSN_SPEC_IO.

z80fi_spec_conns = ", \\\n".join([
    f"| .z80fi_{s[0]} ({s[0]})"
    if s[0] in z80fi_spec_inputs else f"| .spec_{s[0]} (spec_{s[0]})"
    for s in z80fi_signals
]) + ", \\\n"
z80fi_spec_conns += "| .spec_valid (spec_valid), \\\n"
z80fi_spec_conns += ", \\\n".join(
    [f"| .z80fi_{s[0]} (z80fi_{s[0]})" for s in z80fi_registers_in]) + ", \\\n"
z80fi_spec_conns += ", \\\n".join([
    f"| .spec_{s[0]} (spec_{s[0]})"
    for s in z80fi_registers_out + z80fi_registers
])

# Z80FI_INPUTS, Z80FI_OUTPUTS, Z80FI_WIRES

z80fi_inputs = ", \\\n".join([
    f"| input [{s[1]-1}:0] z80fi_{s[0]}"
    for s in z80fi_signals + z80fi_registers_in + z80fi_registers_out
])
z80fi_outputs = ", \\\n".join([
    f"| output logic [{s[1]-1}:0] z80fi_{s[0]}"
    for s in z80fi_signals + z80fi_registers_in + z80fi_registers_out
])
z80fi_wires = "; \\\n".join([
    f"| logic [{s[1]-1}:0] z80fi_{s[0]}"
    for s in z80fi_signals + z80fi_registers_in + z80fi_registers_out
]) + ";"

# Z80FI_NEXT_STATE, Z80FI_RESET_STATE, Z80FI_LOAD_NEXT_STATE
# include registers_in but not registers_out.

z80fi_next_state = "; \\\n".join([
    f"| logic [{s[1]-1}:0] next_z80fi_{s[0]}"
    for s in z80fi_signals + z80fi_registers_in
]) + ";"
z80fi_reset_state = "; \\\n".join(
    [f"| z80fi_{s[0]} <= 0" for s in z80fi_signals + z80fi_registers_in]) + ";"
z80fi_load_next_state = "; \\\n".join([
    f"| z80fi_{s[0]} <= next_z80fi_{s[0]}"
    for s in z80fi_signals + z80fi_registers_in
]) + ";"

# Z80FI_RETAIN_NEXT_STATE, includes registers_in but not registers_out.
# Special case: we skip "valid" which must be set to 0.

z80fi_retain_next_state = "; \\\n".join([
    f"| next_z80fi_{s[0]} = z80fi_{s[0]}"
    for s in z80fi_signals + z80fi_registers_in if s[0] != "valid"
]) + ";"

# Z80_INIT_NEXT_STATE, which also sets registers_in to their values.

z80fi_init_next_state = "; \\\n".join(
    [f"| next_z80fi_{s[0]} = 0" for s in z80fi_signals]) + "; \\\n"
z80fi_init_next_state += "; \\\n".join(
    [f"| next_z80fi_{s[0]}_in = z80_{s[0]}" for s in z80fi_registers]) + ";"

# Z80FI_CONN, module connections for Z80FI_OUTPUTS.
z80fi_conn = ", \\\n".join([
    f"| .z80fi_{s[0]} (z80fi_{s[0]})"
    for s in z80fi_signals + z80fi_registers_in + z80fi_registers_out
])

# Z80FI_REG_ASSIGN assigns register values to z80fi_regs.
z80fi_reg_assign = "; \\\n".join(
    [f"| assign z80fi_{s[0]}_out = z80_{s[0]}" for s in z80fi_registers]) + ";"

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
        | `define Z80FI_REG_ASSIGN \\
        {z80fi_reg_assign}
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
        | logic [{len(z80fi_action_signals + z80fi_registers)-1}:0] spec_signals; \\
        {z80fi_action_assignments} \\
        | wire [15:0] z80fi_reg_bc_in = {{z80fi_reg_b_in, z80fi_reg_c_in}}; \\
        | wire [15:0] z80fi_reg_de_in = {{z80fi_reg_d_in, z80fi_reg_e_in}}; \\
        | wire [15:0] z80fi_reg_hl_in = {{z80fi_reg_h_in, z80fi_reg_l_in}}; \\
        | wire [15:0] z80fi_reg_af_in = {{z80fi_reg_a_in, z80fi_reg_f_in}}; \\
        | wire [15:0] z80fi_reg_bc2_in = {{z80fi_reg_b2_in, z80fi_reg_c2_in}}; \\
        | wire [15:0] z80fi_reg_de2_in = {{z80fi_reg_d2_in, z80fi_reg_e2_in}}; \\
        | wire [15:0] z80fi_reg_hl2_in = {{z80fi_reg_h2_in, z80fi_reg_l2_in}}; \\
        | wire [15:0] z80fi_reg_af2_in = {{z80fi_reg_a2_in, z80fi_reg_f2_in}};
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
            | cover
            | bmc
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
            | alu.sv
            | sequencer.sv
            | sequencer_tasks.vh
            | registers.sv
            | ir_registers.sv
            | instr_decoder.sv
            """,
            file=f)
