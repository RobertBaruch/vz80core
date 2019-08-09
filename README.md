vz80

Not much documentation here, since it's still a work in progress
and will likely change radically from time to time. Still, there's
some information in each file, and especially in z80fi_tests.md.

Generally tests are run as:

sudo sby -f <sby-file>

Changing the z80fi (Z80 Formal Interface) requires running
z80fi_generate.py to generate lots of macros for bunches of
signals.

Adding a new z80fi_insn_spec*.sv file also requires running the
generator, since it creates the corresponding .sby file and adds
the new instruction to the coverage test.
