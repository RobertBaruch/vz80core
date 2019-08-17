// EI/DI
//
// Enable or disable interrupts. Enabling is delayed by one
// instruction.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_ei_di(
    `Z80FI_INSN_SPEC_IO
);

wire       enable      = z80fi_insn[3];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b1111?011;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_IFF1 | `SPEC_REG_IFF2;

// Here we can only test what happens immediately after the instruction
// completes. Since the effect of EI is delayed by one instruction, we
// can't test that here. Instead, we rely on the formal tests for
// the ir_registers module to test that.
assign spec_reg_iff1_out = enable ? 1 : 0;
assign spec_reg_iff2_out = enable ? 1 : 0;

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

endmodule