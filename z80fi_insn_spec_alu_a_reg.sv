// ADD/ADC/SUB/SBC/AND/XOR/OR/CP A, r
//
// Performs an ALU operation on A and the given register.

`default_nettype none

`include "z80.vh"
`include "z80fi.vh"

module z80fi_insn_spec_alu_a_reg(
    `Z80FI_INSN_SPEC_IO
);

wire [2:0] op          = z80fi_insn[5:3];
wire [2:0] r           = z80fi_insn[2:0];

assign spec_valid = z80fi_valid &&
    z80fi_insn_len == 1 &&
    z80fi_insn[7:0] == 8'b10?????? &&
    r != 6;

`Z80FI_SPEC_SIGNALS
assign spec_signals = `SPEC_REG_IP | `SPEC_REG_AF;

wire [7:0] operand =
    (r == `REG_A) ? z80fi_reg_a_in :
    (r == `REG_B) ? z80fi_reg_b_in :
    (r == `REG_C) ? z80fi_reg_c_in :
    (r == `REG_D) ? z80fi_reg_d_in :
    (r == `REG_E) ? z80fi_reg_e_in :
    (r == `REG_H) ? z80fi_reg_h_in :
    (r == `REG_L) ? z80fi_reg_l_in : 0;

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

assign spec_reg_a_out = op == `ALU_FUNC_CP ? z80fi_reg_a_in : result;
assign spec_reg_f_out =
    {flag_s, flag_z, flag_5, flag_h, flag_3, flag_v, flag_n, flag_c};

assign spec_reg_ip_out = z80fi_reg_ip_in + 1;

endmodule