`ifndef _instr_decoder_vh_
`define _instr_decoder_vh_

`include "z80.vh"

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
            16'h36DD, 16'h36FD: begin
                group <= `INSN_GROUP_LD_IDX_IXIY_N;
                len <= 4;
            end
            16'h22DD, 16'h22FD: begin
                group <= `INSN_GROUP_LD_IND_NN_IXIY;
                len <= 4;
            end
            16'h47ED: begin
                group <= `INSN_GROUP_LD_I_A;
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
            default: begin
                group <= `INSN_GROUP_ILLEGAL_INSTR;
                len <= 2;
            end
        endcase
    end
end

endmodule

`endif // _instr_decoder_vh_
