# vz80core, a formally-verified Z80 core written in Verilog.

> *The rules of magic were about as regular as the instruction set on a Z80.*<br/>
> -- *Wizard's Bane*, Rick Cook, 1997

Not much documentation here, since it's still a work in progress and will likely change radically from time to time. Still, there's some information in each file, as well as in `z80fi_tests.md`.

## Prerequisites

You will need:
* yosys
* Symbiyosys
* yices2
* boolector

Follow the [instructions to install these](https://symbiyosys.readthedocs.io/en/latest/quickstart.html). It is highly recommended to follow those instructions, especially for yosys since the git repo has many more fixes than the official release.

## Running formal verification

Individual tests are run as:

`sby -f *sby-file*`

`-f` tells `sby` to overwrite the output directory, rather than
immediately quit if it already exists.

Changing the signals included in z80fi (Z80 Formal Interface) requires running `z80fi_generate.py` to generate lots of macros for bunches of signals.

Adding a new `z80fi_insn_spec*.sv` file also requires running the generator, since it creates the corresponding .sby file and adds the new instruction to the coverage test.

Running `make` in the `z80fi` directory will run all the tests. Using `make -jN`, where `N` is one less than the number of processors you have, is highly recommended so that more than one test runs at the same time. On my machine, each test can last anywhere between 30 and 45 minutes.

## Modules

* `alu8`, `alu16`

  Implements an 8-bit and a 16-bit combinatorial Arithmetic Logic Unit, with flags output. Makes no attempt to be subtle or space-efficient.

  The 8-bit ALU implements addition, addition with carry, subtraction, subtraction with borrow, AND, XOR, OR, rotate arithmetic and logical right and left, and shift arithmetic and logical right and left.

  The 16-bit ALU implements addition, addition with carry, subtraction, and subtraction with borrow.

  Used in:
  * `sequencer`

* `edgelord`

  Reproduces the clock signal without using the clock signal in combinatorial logic. This is a good thing in FPGAs, where the clock is a special signal that might get badly routed if it has to go through anything other than the clock inputs of flipflops.

  Used in:
  * `m1`
  * `mrd_wr_io`
  * `mrd_wr_mem`

* `instr_decoder`

  Given a sequence of at most 4 bytes, and an instruction length between 0 and 2, determine if the instruction needs more bytes, is illegal, or is legal. If legal, determine its general group and the total number of bytes it needs, including its operands.

  Used in:
  * `sequencer_program`

* `instr_ixiy_bits_decoder`

  Given the 4th byte in an IX/IY bits instruction (`DDCB` or `FDCB`), determine if the instruction is legal or not, and if legal, what its general group is.

  Note that this module is included in `instr_decoder.sv`.

  Used in:
  * `sequencer_program`

* `registers`

  Holds the `A`, `B`, `C`, `D`, `E`, `H`, `L`, `F`, `A'`, `B'`, `C'`, `D'`, `E'`, `H'`, `L'`, `F'`, `IX`, `IY`, and `SP` registers. Can write them individually or as paired registers. Continuously outputs onto two busses one register or register pair. Can also implement higher-level functions such as exchanges and block increments.

  Used in:
  * `sequencer`

* `ir_registers`

  Holds the I and R registers and the IFF1 and IFF2 flipflops. Can write the I and R registers, and can manipulate the IFF flipflops for the `EI`, `DI`, and `RETN` instructions, and for nonmaskable interrupts.

  Used in:
  * `sequencer`

* `m1`, `mrd_wr_io`, `mrd_wr_mem`

  Implements timing for the M1 machine cycle, and cycles for reading and writing I/O and memory.

  Used in:
  * `mcycle`

  Uses:
  * `edgelord`

* `mcycle`

  Merges timing and signals from `m1`, `mrd_wr_io`, and `mrd_wr_mem`.

  Used in:
  * `z80`

  Uses:
  * `m1`
  * `mrd_wr_io`
  * `mrd_wr_mem`

* `sequencer_program`

  A strictly combinatorial module. Implements a kind of microinstruction to determine what should happen on the next clock cycle.

  Used in:
  * `sequencer`

  Uses:
  * `instr_decoder`
  * `instr_ixiy_bits_decoder`

* `sequencer`

  Implements the main logic of the Z80 by presenting signals to `sequencer_program` and executing its desires.

  Used in:
  * `z80`

  Uses:
  * `alu8`
  * `alu16`
  * `ir_registers`
  * `registers`
  * `sequencer_program`

* `z80`

  Primarily a conversion layer between `sequencer` and the Z80's pins. Also kicks off the various machine cycles requested by the sequencer.

  Uses:
  * `mcycle`
  * `sequencer`

### Ancillary files

* `sequencer_tasks.vh`

  Contains tasks used by `sequencer_program`.

* `z80.vh`

  Contains all constants, a few functions, and some bundles of signals useful for passing the contents of all registers around during debugging or tests.

## Some useful documents

* [Rodnay Zaks, Programming the Z80](https://archive.org/details/Programming_the_Z-80_2nd_Edition_1980_Rodnay_Zaks)
* [Mostek Z80 Processor Technical Manual](http://datasheets.chipdb.org/Mostek/3880.pdf)
* [Zilog Z80 Family User Manual](https://archive.org/details/Zilog_Z80_Family_user_manual) (note: filled with typos)
* [The Undocumented Z80 Documented](http://datasheets.chipdb.org/Zilog/Z80/z80-documented-0.90.pdf)
