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
        // Make sure we can generate the instruction under test.
        cover(spec_valid);
        // Make sure we can generate the instruction under test
        // during the check cycle (typically the last cycle).
        cover(check && spec_valid);
    end
    if (!reset && check) begin
        // Force the instruction under test to appear, as if by
        // magic.
        assume(spec_valid);

        // Check that if we were supposed to read or write memory
        // or I/O, we did.
        assert(spec_mem_rd == mem_rd);
        assert(spec_mem_rd2 == mem_rd2);
        assert(spec_mem_wr == mem_wr);
        assert(spec_mem_wr2 == mem_wr2);
        assert(spec_io_rd == io_rd);
        assert(spec_io_wr == io_wr);

        // Check that we read from the right locations if we
        // were supposed to read from memory or I/O.
        if (spec_mem_rd) assert(spec_bus_raddr == bus_raddr);
        if (spec_mem_rd2) assert(spec_bus_raddr2 == bus_raddr2);
        if (spec_io_rd) assert(spec_bus_raddr == bus_raddr);

        // Check that we wrote the correct values to the right
        // locations if we were supposed to write memory or I/O.
        if (spec_mem_wr) begin
            assert(spec_bus_waddr == bus_waddr);
            assert(spec_bus_wdata == bus_wdata);
        end
        if (spec_mem_wr2) begin
            assert(spec_bus_waddr2 == bus_waddr2);
            assert(spec_bus_wdata2 == bus_wdata2);
        end
        if (spec_io_wr) begin
            assert(spec_bus_waddr == bus_waddr);
            assert(spec_bus_wdata == bus_wdata);
        end

        // Check that the instruction pointer (aka IP or PC) points
        // to the right place after the instruction executes.
        assert(reg_ip_out == (spec_reg_ip ? spec_reg_ip_out : z80fi_reg_ip_in));

        // Check that all the registers either didn't change if they're
        // not supposed to, or did change to the correct value.
        assert(reg_a_out == (spec_reg_a ? spec_reg_a_out : z80fi_reg_a_in));

        // Separate out the flags to separate asserts for easier debugging.
        // S Z 5 H 3 V N C
        assert(reg_f_out[7] == (spec_reg_f ? spec_reg_f_out[7] : z80fi_reg_f_in[7]));
        assert(reg_f_out[6] == (spec_reg_f ? spec_reg_f_out[6] : z80fi_reg_f_in[6]));
        assert(reg_f_out[5] == (spec_reg_f ? spec_reg_f_out[5] : z80fi_reg_f_in[5]));
        assert(reg_f_out[4] == (spec_reg_f ? spec_reg_f_out[4] : z80fi_reg_f_in[4]));
        assert(reg_f_out[3] == (spec_reg_f ? spec_reg_f_out[3] : z80fi_reg_f_in[3]));
        assert(reg_f_out[2] == (spec_reg_f ? spec_reg_f_out[2] : z80fi_reg_f_in[2]));
        assert(reg_f_out[1] == (spec_reg_f ? spec_reg_f_out[1] : z80fi_reg_f_in[1]));
        assert(reg_f_out[0] == (spec_reg_f ? spec_reg_f_out[0] : z80fi_reg_f_in[0]));

        assert(reg_b_out == (spec_reg_b ? spec_reg_b_out : z80fi_reg_b_in));
        assert(reg_c_out == (spec_reg_c ? spec_reg_c_out : z80fi_reg_c_in));
        assert(reg_d_out == (spec_reg_d ? spec_reg_d_out : z80fi_reg_d_in));
        assert(reg_e_out == (spec_reg_e ? spec_reg_e_out : z80fi_reg_e_in));
        assert(reg_h_out == (spec_reg_h ? spec_reg_h_out : z80fi_reg_h_in));
        assert(reg_l_out == (spec_reg_l ? spec_reg_l_out : z80fi_reg_l_in));
        assert(reg_a2_out == (spec_reg_a2 ? spec_reg_a2_out : z80fi_reg_a2_in));
        assert(reg_f2_out == (spec_reg_f2 ? spec_reg_f2_out : z80fi_reg_f2_in));
        assert(reg_b2_out == (spec_reg_b2 ? spec_reg_b2_out : z80fi_reg_b2_in));
        assert(reg_c2_out == (spec_reg_c2 ? spec_reg_c2_out : z80fi_reg_c2_in));
        assert(reg_d2_out == (spec_reg_d2 ? spec_reg_d2_out : z80fi_reg_d2_in));
        assert(reg_e2_out == (spec_reg_e2 ? spec_reg_e2_out : z80fi_reg_e2_in));
        assert(reg_h2_out == (spec_reg_h2 ? spec_reg_h2_out : z80fi_reg_h2_in));
        assert(reg_l2_out == (spec_reg_l2 ? spec_reg_l2_out : z80fi_reg_l2_in));
        assert(reg_ix_out == (spec_reg_ix ? spec_reg_ix_out : z80fi_reg_ix_in));
        assert(reg_iy_out == (spec_reg_iy ? spec_reg_iy_out : z80fi_reg_iy_in));
        assert(reg_sp_out == (spec_reg_sp ? spec_reg_sp_out : z80fi_reg_sp_in));
        assert(reg_i_out == (spec_reg_i ? spec_reg_i_out : z80fi_reg_i_in));
        assert(reg_r_out == (spec_reg_r ? spec_reg_r_out : z80fi_reg_r_in));

        assert(reg_iff1_out == (spec_reg_iff1 ? spec_reg_iff1_out : z80fi_reg_iff1_in));
        assert(reg_iff2_out == (spec_reg_iff2 ? spec_reg_iff2_out : z80fi_reg_iff2_in));
    end
end
`endif

endmodule
