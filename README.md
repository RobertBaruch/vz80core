vz80

Not much documentation here, since it's still a work in progress
and will likely change radically from time to time. Still, there's
some information in each file, and especially in z80fi_tests.md.

You will need:
* yosys
* Symbiyosys
* yices2
* boolector

Follow the [instructions to install](https://symbiyosys.readthedocs.io/en/latest/quickstart.html). It is highly recommended to follow those, especially for yosys since the git repo has many more fixes than the official release.

Generally tests are run as:

sudo sby -f <sby-file>

Changing the z80fi (Z80 Formal Interface) requires running
z80fi_generate.py to generate lots of macros for bunches of
signals.

Adding a new z80fi_insn_spec*.sv file also requires running the
generator, since it creates the corresponding .sby file and adds
the new instruction to the coverage test.

Some useful books:

* [Rodnay Zaks, Programming the Z80](https://archive.org/details/Programming_the_Z-80_2nd_Edition_1980_Rodnay_Zaks)
* [Zilog Z80 Family User Manual](https://archive.org/details/Zilog_Z80_Family_user_manual)
*