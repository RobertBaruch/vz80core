`ifndef _instr_decoder_vh_
`define _instr_decoder_vh_

`default_nettype none
`timescale 1us/100 ns

`include "z80.vh"

module instr_decoder(
    input logic [15:0] instr,
    input logic [1:0] instr_len,
    output logic [7:0] group
);

always @(*) begin
    if (instr_len == 0) group <= `INSN_GROUP_NEED_MORE_BYTES;
    else if (instr_len == 1) begin
        case (instr[7:0])
            8'h01, 8'h11, 8'h21, 8'h31:
                group <= `INSN_GROUP_LD_DD_IMMED;
            8'h02, 8'h12:
                group <= `INSN_GROUP_LD_BCDE_A;
            8'h06, 8'h0E, 8'h16, 8'h1E, 8'h26, 8'h2E, 8'h3E:
                group <= `INSN_GROUP_LD_REG_IMMED;
            8'h36:
                group <= `INSN_GROUP_LD_HL_IMMED;
            8'h7F, 8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D,
            8'h47, 8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45,
            8'h4F, 8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D,
            8'h57, 8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55,
            8'h5F, 8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D,
            8'h67, 8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65,
            8'h6F, 8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D:
                group <= `INSN_GROUP_LD_REG_REG;
            8'h32:
                group <= `INSN_GROUP_LD_EXTADDR_A;
            8'h3A:
                group <= `INSN_GROUP_LD_A_EXTADDR;
            8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h77:
                group <= `INSN_GROUP_LD_HL_REG;
            8'hCB, 8'hDD, 8'hED, 8'hFD:
                group <= `INSN_GROUP_NEED_MORE_BYTES;
            default:
                group <= `INSN_GROUP_ILLEGAL_INSTR;
        endcase
    end else begin
        case (instr[15:0])
            16'h4BED, 16'h5BED, 16'h6BED, 16'h7BED:
                group <= `INSN_GROUP_LD_DD_EXTADDR;
            16'h46DD, 16'h4EDD, 16'h56DD, 16'h5EDD,
            16'h66DD, 16'h6EDD, 16'h7EDD,
            16'h46FD, 16'h4EFD, 16'h56FD, 16'h5EFD,
            16'h66FD, 16'h6EFD, 16'h7EFD:
                group <= `INSN_GROUP_LD_REG_IXIY;
            default:
                group <= `INSN_GROUP_ILLEGAL_INSTR;
        endcase
    end
end

endmodule

`endif // _instr_decoder_vh_
