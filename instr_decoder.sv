`ifndef _instr_decoder_vh_
`define _instr_decoder_vh_

`include "z80.vh"

// Give an instruction (in little-endian order) and its op_len
// (the instruction length without any operands), determine
// what its total length (including operands) should be, and
// what group it's in.
module instr_decoder(
    input logic [31:0] instr,
    input logic [1:0] op_len,
    output logic [2:0] len,
    output logic [7:0] group
);

always @(*) begin
    if (op_len == 0) begin
        group <= `INSN_GROUP_NEED_MORE_BYTES;
        len <= 1;
    end
    if (op_len == 1) begin
        case (instr[7:0])
            8'h00: begin
                group <= `INSN_GROUP_NOP;
                len <= 1;
            end
            8'h01, 8'h11, 8'h21, 8'h31: begin
                group <= `INSN_GROUP_LD_DD_NN;
                len <= 3;
            end
            8'h02, 8'h12: begin
                group <= `INSN_GROUP_LD_IND_BCDE_A;
                len <= 1;
            end
            8'h04, 8'h0C, 8'h14, 8'h1C, 8'h24, 8'h2C, 8'h3C,
            8'h05, 8'h0D, 8'h15, 8'h1D, 8'h25, 8'h2D, 8'h3D: begin
                group <= `INSN_GROUP_INC_DEC_REG;
                len <= 1;
            end
            8'h27: begin
                group <= `INSN_GROUP_DAA;
                len <= 1;
            end
            8'h2F: begin
                group <= `INSN_GROUP_CPL;
                len <= 1;
            end
            8'h34, 8'h35: begin
                group <= `INSN_GROUP_INC_DEC_IND_HL;
                len <= 1;
            end
            8'h0A, 8'h1A: begin
                group <= `INSN_GROUP_LD_A_IND_BCDE;
                len <= 1;
            end
            8'h06, 8'h0E, 8'h16, 8'h1E, 8'h26, 8'h2E, 8'h3E: begin
                group <= `INSN_GROUP_LD_REG_N;
                len <= 2;
            end
            8'h22: begin
                group <= `INSN_GROUP_LD_IND_NN_HL;
                len <= 3;
            end
            8'h2A: begin
                group <= `INSN_GROUP_LD_HL_IND_NN;
                len <= 3;
            end
            8'h36: begin
                group <= `INSN_GROUP_LD_IND_HL_N;
                len <= 2;
            end
            8'h7F, 8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D,
            8'h47, 8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45,
            8'h4F, 8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D,
            8'h57, 8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55,
            8'h5F, 8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D,
            8'h67, 8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65,
            8'h6F, 8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D: begin
                group <= `INSN_GROUP_LD_REG_REG;
                len <= 1;
            end
            8'h32: begin
                group <= `INSN_GROUP_LD_IND_NN_A;
                len <= 3;
            end
            8'h3A: begin
                group <= `INSN_GROUP_LD_A_IND_NN;
                len <= 3;
            end
            8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77: begin
                group <= `INSN_GROUP_LD_IND_HL_REG;
                len <= 1;
            end
            8'hC1, 8'hD1, 8'hE1, 8'hF1: begin
                group <= `INSN_GROUP_POP_QQ;
                len <= 1;
            end
            8'hC5, 8'hD5, 8'hE5, 8'hF5: begin
                group <= `INSN_GROUP_PUSH_QQ;
                len <= 1;
            end
            8'h08: begin
                group <= `INSN_GROUP_EX_AF_AF2;
                len <= 1;
            end
            8'hE3: begin
                group <= `INSN_GROUP_EX_IND_SP_HL;
                len <= 1;
            end
            8'hEB: begin
                group <= `INSN_GROUP_EX_DE_HL;
                len <= 1;
            end
            8'hD9: begin
                group <= `INSN_GROUP_EXX;
                len <= 1;
            end
            8'hF9: begin
                group <= `INSN_GROUP_LD_SP_HL;
                len <= 1;
            end
            8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h87,
            8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8F,
            8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h97,
            8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9F,
            8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA7,
            8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAF,
            8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB7,
            8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBF: begin
                group <= `INSN_GROUP_ALU_A_REG;
                len <= 1;
            end
            8'h86, 8'h8E, 8'h96, 8'h9E, 8'hA6, 8'hAE, 8'hB6, 8'hBE: begin
                group <= `INSN_GROUP_ALU_A_IND_HL;
                len <= 1;
            end
            8'hC6, 8'hCE, 8'hD6, 8'hDE, 8'hE6, 8'hEE, 8'hF6, 8'hFE: begin
                group <= `INSN_GROUP_ALU_A_N;
                len <= 2;
            end
            8'hCB, 8'hDD, 8'hED, 8'hFD: begin
                group <= `INSN_GROUP_NEED_MORE_BYTES;
                len <= 2;
            end
            default: begin
                group <= `INSN_GROUP_ILLEGAL_INSTR;
                len <= 1;
            end
        endcase
    end else begin
        case (instr[15:0])
            16'h4BED, 16'h5BED, 16'h6BED, 16'h7BED: begin
                group <= `INSN_GROUP_LD_DD_IND_NN;
                len <= 4;
            end
            16'h44ED: begin
                group <= `INSN_GROUP_NEG;
                len <= 2;
            end
            16'h43ED, 16'h53ED, 16'h63ED, 16'h73ED: begin
                group <= `INSN_GROUP_LD_IND_NN_DD;
                len <= 4;
            end
            16'h46DD, 16'h4EDD, 16'h56DD, 16'h5EDD,
            16'h66DD, 16'h6EDD, 16'h7EDD,
            16'h46FD, 16'h4EFD, 16'h56FD, 16'h5EFD,
            16'h66FD, 16'h6EFD, 16'h7EFD: begin
                group <= `INSN_GROUP_LD_REG_IDX_IXIY;
                len <= 3;
            end
            16'h70DD, 16'h71DD, 16'h72DD, 16'h73DD,
            16'h74DD, 16'h75DD, 16'h77DD,
            16'h70FD, 16'h71FD, 16'h72FD, 16'h73FD,
            16'h74FD, 16'h75FD, 16'h77FD: begin
                group <= `INSN_GROUP_LD_IDX_IXIY_REG;
                len <= 3;
            end
            16'h21DD, 16'h21FD: begin
                group <= `INSN_GROUP_LD_IXIY_NN;
                len <= 4;
            end
            16'h2ADD, 16'h2AFD: begin
                group <= `INSN_GROUP_LD_IXIY_IND_NN;
                len <= 4;
            end
            16'h34DD, 16'h34FD, 16'h35DD, 16'h35FD: begin
                group <= `INSN_GROUP_INC_DEC_IDX_IXIY;
                len <= 3;
            end
            16'h36DD, 16'h36FD: begin
                group <= `INSN_GROUP_LD_IDX_IXIY_N;
                len <= 4;
            end
            16'hE3DD, 16'hE3FD: begin
                group <= `INSN_GROUP_EX_IND_SP_IXIY;
                len <= 2;
            end
            16'hE1DD, 16'hE1FD: begin
                group <= `INSN_GROUP_POP_IXIY;
                len <= 2;
            end
            16'hE5DD, 16'hE5FD: begin
                group <= `INSN_GROUP_PUSH_IXIY;
                len <= 2;
            end
            16'h22DD, 16'h22FD: begin
                group <= `INSN_GROUP_LD_IND_NN_IXIY;
                len <= 4;
            end
            16'h86DD, 16'h8EDD, 16'h96DD, 16'h9EDD,
            16'hA6DD, 16'hAEDD, 16'hB6DD, 16'hBEDD,
            16'h86FD, 16'h8EFD, 16'h96FD, 16'h9EFD,
            16'hA6FD, 16'hAEFD, 16'hB6FD, 16'hBEFD: begin
                group <= `INSN_GROUP_ALU_A_IDX_IXIY;
                len <= 3;
            end
            16'h47ED: begin
                group <= `INSN_GROUP_LD_I_A;
                len <= 2;
            end
            16'h4FED: begin
                group <= `INSN_GROUP_LD_R_A;
                len <= 2;
            end
            16'h57ED: begin
                group <= `INSN_GROUP_LD_A_I;
                len <= 2;
            end
            16'h5FED: begin
                group <= `INSN_GROUP_LD_A_R;
                len <= 2;
            end
            16'hF9DD, 16'hF9FD: begin
                group <= `INSN_GROUP_LD_SP_IXIY;
                len <= 2;
            end
            16'hA0ED: begin
                group <= `INSN_GROUP_LDI;
                len <= 2;
            end
            16'hA1ED: begin
                group <= `INSN_GROUP_CPI;
                len <= 2;
            end
            16'hA8ED: begin
                group <= `INSN_GROUP_LDD;
                len <= 2;
            end
            16'hA9ED: begin
                group <= `INSN_GROUP_CPD;
                len <= 2;
            end
            16'hB0ED: begin
                group <= `INSN_GROUP_LDIR;
                len <= 2;
            end
            16'hB1ED: begin
                group <= `INSN_GROUP_CPIR;
                len <= 2;
            end
            16'hB8ED: begin
                group <= `INSN_GROUP_LDDR;
                len <= 2;
            end
            16'hB9ED: begin
                group <= `INSN_GROUP_CPDR;
                len <= 2;
            end
            default: begin
                group <= `INSN_GROUP_ILLEGAL_INSTR;
                len <= 2;
            end
        endcase
    end
end

endmodule

`endif // _instr_decoder_vh_
