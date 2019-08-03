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

// The inputs to the instruction. Later we assert that the
// actual outputs (given in z80fi_*) conform to the spec
// (given in spec_*).
wire        valid      = !reset && z80fi_valid;
wire [31:0] insn       = z80fi_insn;
wire [2:0]  insn_len   = z80fi_insn_len;
wire [15:0] pc_rdata   = z80fi_pc_rdata;
wire [15:0] reg1_rdata = z80fi_reg1_rdata;
wire [15:0] reg2_rdata = z80fi_reg2_rdata;
wire [7:0]  mem_rdata  = z80fi_mem_rdata;
wire [7:0]  mem_rdata2 = z80fi_mem_rdata2;
wire [7  : 0] i_rdata  = z80fi_i_rdata;
wire [7  : 0] r_rdata  = z80fi_r_rdata;
wire [7  : 0] f_rdata  = z80fi_f_rdata;

// Actual outputs
wire             reg1_rd    = z80fi_reg1_rd;
wire `reg_select reg1_rnum  = z80fi_reg1_rnum;
wire             reg2_rd    = z80fi_reg2_rd;
wire `reg_select reg2_rnum  = z80fi_reg2_rnum;
wire             reg_wr     = z80fi_reg_wr;
wire `reg_select reg_wnum   = z80fi_reg_wnum;
wire [15:0]      reg_wdata  = z80fi_reg_wdata;
wire [15:0]      pc_wdata   = z80fi_pc_wdata;
wire             mem_rd     = z80fi_mem_rd;
wire [15:0]      mem_raddr  = z80fi_mem_raddr;
wire             mem_rd2    = z80fi_mem_rd2;
wire [15:0]      mem_raddr2 = z80fi_mem_raddr2;
wire             mem_wr     = z80fi_mem_wr;
wire [15:0]      mem_waddr  = z80fi_mem_waddr;
wire [7:0]       mem_wdata  = z80fi_mem_wdata;
wire             mem_wr2    = z80fi_mem_wr2;
wire [15:0]      mem_waddr2 = z80fi_mem_waddr2;
wire [7:0]       mem_wdata2 = z80fi_mem_wdata2;
wire [0  : 0]    i_rd       = z80fi_i_rd;      
wire [0  : 0]    i_wr       = z80fi_i_wr;       
wire [7  : 0]    i_wdata    = z80fi_i_wdata;    
wire [0  : 0]    r_rd       = z80fi_r_rd;       
wire [0  : 0]    r_wr       = z80fi_r_wr;       
wire [7  : 0]    r_wdata    = z80fi_r_wdata;    
wire [0  : 0]    f_rd       = z80fi_f_rd;       
wire [0  : 0]    f_wr       = z80fi_f_wr;       
wire [7  : 0]    f_wdata    = z80fi_f_wdata;

// Spec outputs
wire             spec_valid;
wire             spec_reg1_rd;
wire `reg_select spec_reg1_rnum;
wire             spec_reg2_rd;
wire `reg_select spec_reg2_rnum;
wire             spec_reg_wr;
wire `reg_select spec_reg_wnum;
wire [15:0]      spec_reg_wdata;
wire [15:0]      spec_pc_wdata;
wire             spec_mem_rd;
wire [15:0]      spec_mem_raddr;
wire             spec_mem_rd2;
wire [15:0]      spec_mem_raddr2;
wire             spec_mem_wr;
wire [15:0]      spec_mem_waddr;
wire [7:0]       spec_mem_wdata;
wire             spec_mem_wr2;
wire [15:0]      spec_mem_waddr2;
wire [7:0]       spec_mem_wdata2;
wire [0  : 0]    spec_i_rd;       
wire [0  : 0]    spec_i_wr;       
wire [7  : 0]    spec_i_rdata;    
wire [7  : 0]    spec_i_wdata;    
wire [0  : 0]    spec_r_rd;       
wire [0  : 0]    spec_r_wr;       
wire [7  : 0]    spec_r_rdata;    
wire [7  : 0]    spec_r_wdata;    
wire [0  : 0]    spec_f_rd;       
wire [0  : 0]    spec_f_wr;       
wire [7  : 0]    spec_f_rdata;    
wire [7  : 0]    spec_f_wdata;

`Z80_FORMAL_INSN_MODEL insn_spec(
    .z80fi_valid      ( valid          ),
    .z80fi_insn       ( insn           ),
    .z80fi_insn_len   ( insn_len       ),
    .z80fi_pc_rdata   ( pc_rdata       ),
    .z80fi_reg1_rdata ( reg1_rdata     ),
    .z80fi_reg2_rdata ( reg2_rdata     ),
    .z80fi_mem_rdata  ( mem_rdata      ),
    .z80fi_mem_rdata2 ( mem_rdata2     ),
    .z80fi_i_rdata     ( i_rdata   ),
    .z80fi_r_rdata     ( r_rdata   ),
    .z80fi_f_rdata     ( f_rdata   ),

    .spec_valid       ( spec_valid     ),
    .spec_reg1_rd     ( spec_reg1_rd   ),
    .spec_reg1_rnum   ( spec_reg1_rnum ),
    .spec_reg2_rd     ( spec_reg2_rd   ),
    .spec_reg2_rnum   ( spec_reg2_rnum ),
    .spec_reg_wr      ( spec_reg_wr    ),
    .spec_reg_wnum    ( spec_reg_wnum  ),
    .spec_reg_wdata   ( spec_reg_wdata ),
    .spec_pc_wdata    ( spec_pc_wdata  ),
    .spec_mem_rd      ( spec_mem_rd    ),
    .spec_mem_raddr   ( spec_mem_raddr ),
    .spec_mem_rd2     ( spec_mem_rd2   ),
    .spec_mem_raddr2  ( spec_mem_raddr2),
    .spec_mem_wr      ( spec_mem_wr    ),
    .spec_mem_waddr   ( spec_mem_waddr ),
    .spec_mem_wdata   ( spec_mem_wdata ),
    .spec_mem_wr2     ( spec_mem_wr2   ),
    .spec_mem_waddr2  ( spec_mem_waddr2),
    .spec_mem_wdata2  ( spec_mem_wdata2),
    .spec_i_rd        ( spec_i_rd      ),
    .spec_i_wr        ( spec_i_wr      ),
    .spec_i_wdata     ( spec_i_wdata   ),
    .spec_r_rd        ( spec_r_rd      ),
    .spec_r_wr        ( spec_r_wr      ),
    .spec_r_wdata     ( spec_r_wdata   ),
    .spec_f_rd        ( spec_f_rd      ),
    .spec_f_wr        ( spec_f_wr      ),
    .spec_f_wdata     ( spec_f_wdata   )
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
            assert(spec_mem_wdata == mem_wdata);
        end

        if (spec_i_wr) assert(spec_i_wdata == i_wdata);
        if (spec_r_wr) assert(spec_r_wdata == r_wdata);
        if (spec_f_wr) assert(spec_f_wdata == f_wdata);
        assert(spec_pc_wdata == pc_wdata);
    end
end
`endif

endmodule
