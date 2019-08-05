`default_nettype none

`include "z80fi.vh"
`include "z80.vh"

`ifndef Z80_FORMAL_INSN_MODEL
`define Z80_FORMAL_INSN_MODEL dummy
module dummy(
`Z80FI_INSN_SPEC_IO
);
endmodule
`endif

module z80fi_insn_check(
    input clk,
    input reset,
    input check,
    `Z80FI_INPUTS
);

`Z80FI_SPEC_WIRES

`Z80_FORMAL_INSN_MODEL insn_spec(
    `Z80FI_SPEC_CONNS
);

`ifdef FORMAL
always @(*) begin
    if (!reset) begin
        cover(spec_valid);
        cover(check && spec_valid);
    end
    if (!reset && check) begin
        assume(spec_valid);
        assert(spec_reg1_rd == reg1_rd);
        assert(spec_reg2_rd == reg2_rd);
        assert(spec_reg_wr == reg_wr);
        assert(spec_mem_rd == mem_rd);
        assert(spec_mem_rd2 == mem_rd2);
        assert(spec_mem_wr == mem_wr);
        assert(spec_mem_wr2 == mem_wr2);
        assert(spec_i_rd == i_rd);
        assert(spec_i_wr == i_wr);
        assert(spec_r_rd == r_rd);
        assert(spec_r_wr == r_wr);
        assert(spec_f_rd == f_rd);
        assert(spec_f_wr == f_wr);
        assert(spec_iff1_rd == iff1_rd);
        assert(spec_iff2_rd == iff2_rd);

        if (spec_reg1_rd) assert(spec_reg1_rnum == reg1_rnum);
        if (spec_reg2_rd) assert(spec_reg2_rnum == reg2_rnum);
        if (spec_reg_wr) begin
            assert(spec_reg_wnum == reg_wnum);
            assert(spec_reg_wdata == reg_wdata);
        end
        if (spec_mem_rd) assert(spec_mem_raddr == mem_raddr);
        if (spec_mem_rd2) assert(spec_mem_raddr2 == mem_raddr2);
        if (spec_mem_wr) begin
            assert(spec_mem_waddr == mem_waddr);
            assert(spec_mem_wdata == mem_wdata);
        end
        if (spec_mem_wr2) begin
            assert(spec_mem_waddr2 == mem_waddr2);
            assert(spec_mem_wdata2 == mem_wdata2);
        end

        if (spec_i_wr) assert(spec_i_wdata == i_wdata);
        if (spec_r_wr) assert(spec_r_wdata == r_wdata);
        if (spec_f_wr) assert(spec_f_wdata == f_wdata);
        assert(spec_pc_wdata == pc_wdata);
    end
end
`endif

endmodule
