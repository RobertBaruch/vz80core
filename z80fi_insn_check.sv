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
        // Force the instruction under test to appear, as if by
        // magic.
        assume(spec_valid);

        // Check that if we were supposed to read or write memory,
        // we did.
        assert(spec_mem_rd == mem_rd);
        assert(spec_mem_rd2 == mem_rd2);
        assert(spec_mem_wr == mem_wr);
        assert(spec_mem_wr2 == mem_wr2);

        // Check that we read from the right locations if we
        // were supposed to read from memory.
        if (spec_mem_rd) assert(spec_mem_raddr == mem_raddr);
        if (spec_mem_rd2) assert(spec_mem_raddr2 == mem_raddr2);

        // Check that we wronte the correct values to the right
        // locations if we were supposed to write memory.
        if (spec_mem_wr) begin
            assert(spec_mem_waddr == mem_waddr);
            assert(spec_mem_wdata == mem_wdata);
        end
        if (spec_mem_wr2) begin
            assert(spec_mem_waddr2 == mem_waddr2);
            assert(spec_mem_wdata2 == mem_wdata2);
        end

        // Check that the instruction pointer (aka IP or PC) points
        // to the right place after the instruction executes.
        assert(reg_ip_out == (spec_reg_ip ? spec_reg_ip_out : z80fi_reg_ip_in));

        // Check that all the registers either didn't change if they're
        // not supposed to, or did change to the correct value.
        assert(reg_a_out == (spec_reg_a ? spec_reg_a_out : z80fi_reg_a_in));
        assert(reg_b_out == (spec_reg_b ? spec_reg_b_out : z80fi_reg_b_in));
        assert(reg_c_out == (spec_reg_c ? spec_reg_c_out : z80fi_reg_c_in));
        assert(reg_d_out == (spec_reg_d ? spec_reg_d_out : z80fi_reg_d_in));
        assert(reg_e_out == (spec_reg_e ? spec_reg_e_out : z80fi_reg_e_in));
        assert(reg_h_out == (spec_reg_h ? spec_reg_h_out : z80fi_reg_h_in));
        assert(reg_l_out == (spec_reg_l ? spec_reg_l_out : z80fi_reg_l_in));
        assert(reg_ix_out == (spec_reg_ix ? spec_reg_ix_out : z80fi_reg_ix_in));
        assert(reg_iy_out == (spec_reg_iy ? spec_reg_iy_out : z80fi_reg_iy_in));
        assert(reg_sp_out == (spec_reg_sp ? spec_reg_sp_out : z80fi_reg_sp_in));
        assert(reg_i_out == (spec_reg_i ? spec_reg_i_out : z80fi_reg_i_in));
        assert(reg_r_out == (spec_reg_r ? spec_reg_r_out : z80fi_reg_r_in));
        assert(reg_f_out == (spec_reg_f ? spec_reg_f_out : z80fi_reg_f_in));
        assert(reg_iff1_out == (spec_reg_iff1 ? spec_reg_iff1_out : z80fi_reg_iff1_in));
        assert(reg_iff2_out == (spec_reg_iff2 ? spec_reg_iff2_out : z80fi_reg_iff2_in));
    end
end
`endif

endmodule
