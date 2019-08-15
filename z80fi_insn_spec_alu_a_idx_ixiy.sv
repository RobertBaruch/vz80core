// ADD/ADC/SUB/SBC/XOR/AND/OR/CP A, (IX/IY + d)
//
// Performs an ALU operation on A and the byte at the memory
// location in IX/IY + d.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_alu_a_idx_ixiy(
    `Z80FI_INSN_SPEC_IO
);

wire [15:0] d          = { {8{z80fi_insn[23]}}, z80fi_insn[23:16]};
wire [2:0] op          = z80fi_insn[13:11];
wire       iy          = z80fi_insn[5];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 3 &&
    z80fi_insn[15:0] == 16'b10???110_11?11101;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_AF | `SPEC_MEM_RD;

wire [7:0] operand = z80fi_mem_rdata;

wire carry_in =
    (op != `ALU_FUNC_ADD && op != `ALU_FUNC_SUB && op != `ALU_FUNC_CP) &&
    ((z80fi_reg_f_in & `FLAG_C_BIT) != 0);

wire [7:0] result =
    (op == `ALU_FUNC_ADD) ? z80fi_reg_a_in + operand :
    (op == `ALU_FUNC_ADC) ? z80fi_reg_a_in + operand + carry_in :
    (op == `ALU_FUNC_SUB || op == `ALU_FUNC_CP) ? z80fi_reg_a_in - operand :
    (op == `ALU_FUNC_SBC) ? z80fi_reg_a_in - operand - carry_in :
    (op == `ALU_FUNC_AND) ? z80fi_reg_a_in & operand :
    (op == `ALU_FUNC_XOR) ? z80fi_reg_a_in ^ operand :
    (op == `ALU_FUNC_OR) ? z80fi_reg_a_in | operand : 0;

wire is_logical = (op == `ALU_FUNC_AND || op == `ALU_FUNC_XOR || op == `ALU_FUNC_OR);
wire is_sub = (op == `ALU_FUNC_SUB || op == `ALU_FUNC_SBC || op == `ALU_FUNC_CP);

wire flag_s = result[7];
wire flag_z = (result == 8'b0);
wire flag_5 = (z80fi_reg_f_in & `FLAG_5_BIT) != 0;
// h is set for AND, reset for XOR and OR.
wire flag_h = (op == `ALU_FUNC_AND) ||
    !is_logical && halfcarry8(z80fi_reg_a_in, is_sub ? ~operand : operand, is_sub ^ carry_in);
wire flag_3 = (z80fi_reg_f_in & `FLAG_3_BIT) != 0;
wire flag_v = is_logical ? parity8(result) :
    overflow8(z80fi_reg_a_in, is_sub ? ~operand : operand, is_sub ^ carry_in);
wire flag_n = is_sub;
wire flag_c = is_logical ? 1'b0 :
    carry8(z80fi_reg_a_in, is_sub ? ~operand : operand, is_sub ^ carry_in);

assign spec_mem_raddr = (iy ? z80fi_reg_iy_in : z80fi_reg_ix_in) + d;
assign spec_reg_a_out = op == `ALU_FUNC_CP ? z80fi_reg_a_in : result;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 3;

endmodule