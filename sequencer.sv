`ifndef _sequencer_sv_
`define _sequencer_sv_

`include "z80.vh"
`include "registers.sv"
`include "ir_registers.sv"
`include "alu.sv"
`include "sequencer_program.sv"

`default_nettype none
`timescale 1us/1us

module sequencer(
    input logic reset,
    input logic clk,
    input logic [7:0] bus_rdata,
    input logic mcycle_done,
    input logic [2:0] mcycle,
    input logic [2:0] tcycle,

    output logic done,
    output logic [15:0] addr,
    output logic mem_wr,
    output logic mem_rd,
    output logic io_wr,
    output logic io_rd,
    output logic [7:0] bus_wdata,
    output logic opcode_fetch

`ifdef Z80_FORMAL
    ,
    `Z80_REGS_OUTPUTS
    ,
    `Z80FI_OUTPUTS
`endif
);

`ifdef Z80_FORMAL
`Z80FI_REGS
assign z80fi_reg_ip = z80_reg_ip;
assign z80fi_reg_a = z80_reg_a;
assign z80fi_reg_b = z80_reg_b;
assign z80fi_reg_c = z80_reg_c;
assign z80fi_reg_d = z80_reg_d;
assign z80fi_reg_e = z80_reg_e;
assign z80fi_reg_h = z80_reg_h;
assign z80fi_reg_l = z80_reg_l;
assign z80fi_reg_f = z80_reg_f;
assign z80fi_reg_a2 = z80_reg_a2;
assign z80fi_reg_b2 = z80_reg_b2;
assign z80fi_reg_c2 = z80_reg_c2;
assign z80fi_reg_d2 = z80_reg_d2;
assign z80fi_reg_e2 = z80_reg_e2;
assign z80fi_reg_h2 = z80_reg_h2;
assign z80fi_reg_l2 = z80_reg_l2;
assign z80fi_reg_f2 = z80_reg_f2;
assign z80fi_reg_ix = z80_reg_ix;
assign z80fi_reg_iy = z80_reg_iy;
assign z80fi_reg_sp = z80_reg_sp;
assign z80fi_reg_i = z80_reg_i;
assign z80fi_reg_r = z80_reg_r;
assign z80fi_reg_iff1 = z80_reg_iff1;
assign z80fi_reg_iff2 = z80_reg_iff2;
assign z80fi_reg_im = z80_reg_im;
`Z80FI_NEXT_STATE
`endif

logic gated_iff1;
logic gated_iff2;
logic delayed_enable_interrupts; // output from ir_registers module
assign gated_iff1 = z80_reg_iff1 & !reset & !disable_interrupts & !enable_interrupts & !delayed_enable_interrupts;
assign gated_iff2 = z80_reg_iff2 & !reset & !disable_interrupts & !enable_interrupts & !delayed_enable_interrupts;

// Interrupt mode
logic [1:0] z80_reg_im;

logic `reg_select reg_wnum;
logic `reg_select reg1_rnum;
logic `reg_select reg2_rnum;
logic [15:0] reg_wdata;
logic [15:0] reg1_rdata; // output from registers module
logic [15:0] reg2_rdata; // output from registers module
logic reg_wr;
logic [7:0] _z80_reg_f; // output from registers module
logic [7:0] f_wdata;
logic f_wr;
logic block_inc;
logic block_dec;
logic block_compare;
logic ex_de_hl;
logic ex_af_af2;
logic exx;

logic i_wr;
logic [7:0] i_wdata;
logic r_wr;
logic [7:0] r_wdata;
logic [7:0] z80_reg_i; // output from ir_registers module
logic [7:0] z80_reg_r; // output from ir_registers module
logic z80_reg_iff1;  // output from ir_registers module
logic z80_reg_iff2;  // output from ir_registers module
logic enable_interrupts;
logic disable_interrupts;
logic accept_nmi;
logic ret_from_nmi;

//
// State variables
//

// insn represents the entire instruction, little-endian.
// Maximum 4 bytes. Ex: LD IY, (AABB) -> AA BB 2A FD.
// The op is just that part of the instruction needed to
// decode the operation. Ex: LD IY, (AABB) -> 2A FD.
logic [31:0] insn;
logic [2:0] insn_len;
logic [1:0] op_len;
logic [1:0] next_op_len;
logic [15:0] stored_data;
logic [1:0] stored_data_len;
logic add_to_insn;
logic add_to_op;
logic add_to_store_data;
logic [2:0] next_cycle;

logic [15:0] z80_reg_ip;

logic [2:0] state;

//
// Next state variables
//

logic [1:0] next_z80_reg_im;
logic next_done;

logic [15:0] next_z80_reg_ip;

logic [2:0] next_state;

logic [15:0] next_addr;
logic [7:0] _bus_wdata;

registers registers(
    .reset(reset),
    .clk(clk),

    .write_en(reg_wr && mcycle_done),
    .dest(reg_wnum),
    .in(reg_wdata),

    .src1(reg1_rnum),
    .out1(reg1_rdata),

    .src2(reg2_rnum),
    .out2(reg2_rdata),

    .reg_f(_z80_reg_f),
    .f_in(f_wdata),
    .f_wr(f_wr && mcycle_done),

    .block_inc(block_inc && mcycle_done),
    .block_dec(block_dec && mcycle_done),
    .block_compare(block_compare && mcycle_done),

    .ex_de_hl(ex_de_hl && mcycle_done),
    .ex_af_af2(ex_af_af2 && mcycle_done),
    .exx(exx && mcycle_done)

`ifdef Z80_FORMAL
    ,
    `Z80_REGS_CONN
`endif
);

ir_registers ir_registers(
    .reset(reset),
    .clk(clk),

    .i_wr(i_wr && mcycle_done),
    .i_in(i_wdata),
    .r_wr(r_wr && mcycle_done),
    .r_in(r_wdata),

    .reg_i(z80_reg_i),
    .reg_r(z80_reg_r),
    .enable_interrupts(enable_interrupts && mcycle_done),
    .disable_interrupts(disable_interrupts && mcycle_done),
    .accept_nmi(accept_nmi && mcycle_done),
    .ret_from_nmi(ret_from_nmi && mcycle_done),
    .next_insn_done(next_done),

    .iff1(z80_reg_iff1),
    .iff2(z80_reg_iff2),
    .delayed_enable_interrupts(delayed_enable_interrupts)
);

logic [7:0] alu8_x;
logic [7:0] alu8_y;
logic [3:0] alu8_func;
logic [7:0] alu8_out; // output from alu8 module
logic [7:0] alu8_f_out;  // output from alu8 module

alu8 alu8(
    .x(alu8_x),
    .y(alu8_y),
    .func(alu8_func),
    .f_in(_z80_reg_f),
    .out(alu8_out),
    .f(alu8_f_out)
);

logic [15:0] alu16_x;
logic [15:0] alu16_y;
logic [3:0] alu16_func;
logic [7:0] alu16_f_out; // output from alu16 module
logic [15:0] alu16_out; // output from alu16 module

alu16 alu16(
    .x(alu16_x),
    .y(alu16_y),
    .func(alu16_func),
    .f_in(_z80_reg_f),
    .out(alu16_out),
    .f(alu16_f_out)
);

sequencer_program sequencer_program(
    .reset(reset),
    .addr(addr),
    .bus_rdata(bus_rdata),
    .z80_reg_ip(z80_reg_ip),
    .insn(sequencer_insn),
    .insn_len(sequencer_insn_len), // length of instruction
    .op_len(sequencer_op_len), // length of opcode not including operand
    .state(state),
    .stored_data(sequencer_stored_data),
    .stored_data_len(sequencer_stored_data_len),
    .reg1_rdata(reg1_rdata),
    .reg2_rdata(reg2_rdata),
    .z80_reg_f(_z80_reg_f),
    .alu8_out(alu8_out),
    .alu8_f_out(alu8_f_out),
    .alu16_out(alu16_out),
    .alu16_f_out(alu16_f_out),
    .z80_reg_i(z80_reg_i),
    .z80_reg_r(z80_reg_r),
    .z80_reg_iff1(z80_reg_iff1),
    .z80_reg_iff2(z80_reg_iff2),
    .z80_reg_im(z80_reg_im),

    // This is the next cycle we want.
    .next_cycle(next_cycle),
    // This is the next address we want.
    .next_addr(next_addr),
    // This is the next IP we want.
    .next_z80_reg_ip(next_z80_reg_ip),
    // We want to add bus_rdata, when it's ready, to the insn.
    .add_to_insn(add_to_insn),
    // We also want to increment op_len when we add to the insn.
    .add_to_op(add_to_op),
    // We want to add bus_rdata, when it's ready, to stored_data.
    .add_to_store_data(add_to_store_data),
    // This is the next state we want in handling a multi-state instruction.
    .next_state(next_state),

    .bus_wdata(_bus_wdata),
    // We want to write bus_wdata at memory location next_addr.
    .mem_wr(mem_wr),
    // We want to read bus_rdata at memory location next_addr.
    .mem_rd(mem_rd),
    // We want to write bus_wdata at I/O location next_addr.
    .io_wr(io_wr),
    // We want to read bus_rdata at I/O location next_addr.
    .io_rd(io_rd),
    // The register to put on bus 1.
    .reg1_rnum(reg1_rnum),
    // The register to put on bus 2.
    .reg2_rnum(reg2_rnum),
    // We want to write a register.
    .reg_wr(reg_wr),
    .reg_wnum(reg_wnum),
    .reg_wdata(reg_wdata),
    // We want to write flags.
    .f_wr(f_wr),
    .f_wdata(f_wdata),
    // We want to do one of these things:
    .block_inc(block_inc),
    .block_dec(block_dec),
    .block_compare(block_compare),
    .ex_de_hl(ex_de_hl),
    .ex_af_af2(ex_af_af2),
    .exx(exx),
    // We want to do an alu8 op.
    .alu8_x(alu8_x),
    .alu8_y(alu8_y),
    .alu8_func(alu8_func),
    // We want to do an alu16 op.
    .alu16_x(alu16_x),
    .alu16_y(alu16_y),
    .alu16_func(alu16_func),
    // We want to write the I register.
    .i_wr(i_wr),
    .i_wdata(i_wdata),
    // We want to write the R register.
    .r_wr(r_wr),
    .r_wdata(r_wdata),
    // We want to do one of these things:
    .enable_interrupts(enable_interrupts),
    .disable_interrupts(disable_interrupts),
    .accept_nmi(accept_nmi),
    .ret_from_nmi(ret_from_nmi),
    // The next IM we want.
    .next_z80_reg_im(next_z80_reg_im),
    // We are done with this instruction after all the things we asked for
    // are done (so the next cycle will be an M1).
    .done(done)
);

logic [31:0] sequencer_insn;
logic [2:0] sequencer_insn_len;
logic [1:0] sequencer_op_len;
logic [15:0] sequencer_stored_data;
logic [1:0] sequencer_stored_data_len;
logic latched_add_to_insn;
logic latched_add_to_store_data;
logic latched_add_to_op;

assign opcode_fetch = mcycle_done && next_cycle == `CYCLE_M1;

always @(*) begin
    sequencer_insn = insn;
    sequencer_insn_len = insn_len;
    sequencer_op_len = op_len;
    sequencer_stored_data = stored_data;
    sequencer_stored_data_len = stored_data_len;

    if (latched_add_to_insn) begin
        case (insn_len)
            0: sequencer_insn = {24'b0, bus_rdata};
            1: sequencer_insn = {16'b0, bus_rdata, insn[7:0]};
            2: sequencer_insn = {8'b0, bus_rdata, insn[15:0]};
            default: sequencer_insn = {bus_rdata, insn[23:0]};
        endcase
        sequencer_insn_len = insn_len + 1;
        if (latched_add_to_op) sequencer_op_len = op_len + 1;
    end

    if (latched_add_to_store_data) begin
        if (stored_data_len == 0) sequencer_stored_data = {8'b0, bus_rdata};
        else sequencer_stored_data = {bus_rdata, stored_data[7:0]};
        sequencer_stored_data_len = stored_data_len + 1;
    end
end

logic latched_reset;
logic latched_mem_rd;
logic latched_mem_wr;
logic latched_io_rd;
logic latched_io_wr;

always @(posedge clk) begin
    latched_reset <= reset;

    if (reset || latched_reset) begin
        z80_reg_im <= 0;

        insn <= 0;
        insn_len <= 0;
        op_len <= 0;
        stored_data <= 0;
        stored_data_len <= 0;

        z80_reg_ip <= 0;

        state <= 0;

        addr <= 0;
        latched_add_to_insn <= 0;
        latched_add_to_store_data <= 0;
        latched_add_to_op <= 0;
        latched_mem_rd <= 0;
        latched_mem_wr <= 0;
        latched_io_rd <= 0;
        latched_io_wr <= 0;

        bus_wdata <= 0;

        `ifdef Z80_FORMAL
            `Z80FI_RESET_STATE
        `endif
    end else begin
        if ((mcycle == `CYCLE_M1 && tcycle == 1) ||
            (mcycle == `CYCLE_RDWR_MEM && tcycle == 2) ||
            (mcycle == `CYCLE_RDWR_IO && tcycle == 7)) begin

            latched_add_to_insn <= add_to_insn;
            latched_add_to_store_data <= add_to_store_data;
            latched_add_to_op <= add_to_op;

        end else if (mcycle == `CYCLE_M1 && tcycle == 2) begin

            stored_data <= sequencer_stored_data;
            stored_data_len <= sequencer_stored_data_len;
            insn <= sequencer_insn;
            insn_len <= sequencer_insn_len;
            op_len <= sequencer_op_len;

            latched_add_to_insn <= 0;
            latched_add_to_store_data <= 0;
            latched_add_to_op <= 0;

        end else if (done && mcycle_done) begin // instruction is complete
            insn <= 0;
            insn_len <= 0;
            op_len <= 0;
            stored_data <= 0;
            stored_data_len <= 0;
            state <= 0;
            latched_add_to_insn <= 0;
            latched_add_to_store_data <= 0;
            latched_add_to_op <= 0;
            latched_mem_rd <= mem_rd;
            latched_mem_wr <= mem_wr;
            latched_io_rd <= io_rd;
            latched_io_wr <= io_wr;

            z80_reg_im <= next_z80_reg_im;
            z80_reg_ip <= next_z80_reg_ip;
            addr <= next_z80_reg_ip;

        end else if (mcycle_done) begin // instruction not complete, cycle complete
            z80_reg_im <= next_z80_reg_im;
            z80_reg_ip <= next_z80_reg_ip;
            state <= next_state;
            addr <= next_addr;

            stored_data <= sequencer_stored_data;
            stored_data_len <= sequencer_stored_data_len;
            insn <= sequencer_insn;
            insn_len <= sequencer_insn_len;
            op_len <= sequencer_op_len;

            latched_add_to_insn <= 0;
            latched_add_to_store_data <= 0;
            latched_add_to_op <= 0;
            latched_mem_rd <= mem_rd;
            latched_mem_wr <= mem_wr;
            latched_io_rd <= io_rd;
            latched_io_wr <= io_wr;

            if (mem_wr || io_wr) bus_wdata <= _bus_wdata;
            else bus_wdata <= 0;

        end

        `ifdef Z80_FORMAL
        if (mcycle_done) begin
            if (!latched_add_to_insn && latched_mem_rd && mcycle == `CYCLE_RDWR_MEM) begin
                if (!z80fi_mem_rd) begin
                    z80fi_mem_rd <= 1;
                    z80fi_bus_rdata <= bus_rdata;
                    z80fi_bus_raddr <= addr;
                end else begin
                    z80fi_mem_rd2 <= 1;
                    z80fi_bus_rdata2 <= bus_rdata;
                    z80fi_bus_raddr2 <= addr;
                end
            end
            if (latched_mem_wr && mcycle == `CYCLE_RDWR_MEM) begin
                if (!z80fi_mem_wr) begin
                    z80fi_mem_wr <= 1;
                    z80fi_bus_wdata <= bus_wdata;
                    z80fi_bus_waddr <= addr;
                end else begin
                    z80fi_mem_wr2 <= 1;
                    z80fi_bus_wdata2 <= bus_wdata;
                    z80fi_bus_waddr2 <= addr;
                end
            end
            if (latched_io_rd && mcycle == `CYCLE_RDWR_IO) begin
                z80fi_io_rd <= 1;
                z80fi_bus_rdata <= bus_rdata;
                z80fi_bus_raddr <= addr;
            end
            if (latched_io_wr && mcycle == `CYCLE_RDWR_IO) begin
                z80fi_io_wr <= 1;
                z80fi_bus_wdata <= bus_wdata;
                z80fi_bus_waddr <= addr;
            end

            if (done) begin
                z80fi_insn <= sequencer_insn;
                z80fi_insn_len <= sequencer_insn_len;
            end
        end

        // We just finished an instruction and haven't yet
        // started executing the instruction to be read during
        // this cycle. Note that if z80fi_insn_len is zero,
        // it means we've just reset.
        if (insn_len == 0 && z80fi_insn_len != 0 && mcycle == `CYCLE_M1 && tcycle == 1) begin
            z80fi_valid <= 1;
            z80fi_reg_ip_out <= z80_reg_ip;
            z80fi_reg_a_out <= z80_reg_a;
            z80fi_reg_b_out <= z80_reg_b;
            z80fi_reg_c_out <= z80_reg_c;
            z80fi_reg_d_out <= z80_reg_d;
            z80fi_reg_e_out <= z80_reg_e;
            z80fi_reg_h_out <= z80_reg_h;
            z80fi_reg_l_out <= z80_reg_l;
            z80fi_reg_f_out <= z80_reg_f;
            z80fi_reg_a2_out <= z80_reg_a2;
            z80fi_reg_b2_out <= z80_reg_b2;
            z80fi_reg_c2_out <= z80_reg_c2;
            z80fi_reg_d2_out <= z80_reg_d2;
            z80fi_reg_e2_out <= z80_reg_e2;
            z80fi_reg_h2_out <= z80_reg_h2;
            z80fi_reg_l2_out <= z80_reg_l2;
            z80fi_reg_f2_out <= z80_reg_f2;
            z80fi_reg_ix_out <= z80_reg_ix;
            z80fi_reg_iy_out <= z80_reg_iy;
            z80fi_reg_sp_out <= z80_reg_sp;
            z80fi_reg_i_out <= z80_reg_i;
            z80fi_reg_r_out <= z80_reg_r;
            z80fi_reg_iff1_out <= z80_reg_iff1;
            z80fi_reg_iff2_out <= z80_reg_iff2;
            z80fi_reg_im_out <= z80_reg_im;
        end

        // In the previous tcycle we set up all the z80fi outputs.
        // Now we can tear them all down and load up the current
        // state of the registers.
        if (insn_len == 0 && mcycle == `CYCLE_M1 && tcycle == 2) begin
            z80fi_valid <= 0;
            z80fi_insn <= 0;
            z80fi_insn_len <= 0;
            z80fi_mem_rd <= 0;
            z80fi_mem_rd2 <= 0;
            z80fi_mem_wr <= 0;
            z80fi_mem_wr2 <= 0;
            z80fi_io_rd <= 0;
            z80fi_io_wr <= 0;
            z80fi_bus_rdata <= 0;
            z80fi_bus_rdata2 <= 0;
            z80fi_bus_wdata <= 0;
            z80fi_bus_wdata2 <= 0;
            z80fi_bus_raddr <= 0;
            z80fi_bus_raddr2 <= 0;
            z80fi_bus_waddr <= 0;
            z80fi_bus_waddr2 <= 0;
            z80fi_reg_ip_in <= z80_reg_ip;
            z80fi_reg_a_in <= z80_reg_a;
            z80fi_reg_b_in <= z80_reg_b;
            z80fi_reg_c_in <= z80_reg_c;
            z80fi_reg_d_in <= z80_reg_d;
            z80fi_reg_e_in <= z80_reg_e;
            z80fi_reg_h_in <= z80_reg_h;
            z80fi_reg_l_in <= z80_reg_l;
            z80fi_reg_f_in <= z80_reg_f;
            z80fi_reg_a2_in <= z80_reg_a2;
            z80fi_reg_b2_in <= z80_reg_b2;
            z80fi_reg_c2_in <= z80_reg_c2;
            z80fi_reg_d2_in <= z80_reg_d2;
            z80fi_reg_e2_in <= z80_reg_e2;
            z80fi_reg_h2_in <= z80_reg_h2;
            z80fi_reg_l2_in <= z80_reg_l2;
            z80fi_reg_f2_in <= z80_reg_f2;
            z80fi_reg_ix_in <= z80_reg_ix;
            z80fi_reg_iy_in <= z80_reg_iy;
            z80fi_reg_sp_in <= z80_reg_sp;
            z80fi_reg_i_in <= z80_reg_i;
            z80fi_reg_r_in <= z80_reg_r;
            z80fi_reg_iff1_in <= z80_reg_iff1;
            z80fi_reg_iff2_in <= z80_reg_iff2;
            z80fi_reg_im_in <= z80_reg_im;
        end
        `endif
    end
end

`ifdef SEQUENCER_FORMAL

logic past_valid;
initial past_valid = 0;
always @(posedge clk) past_valid <= 1;

(* anyconst *) reg [7:0] mem0;
(* anyconst *) reg [7:0] mem1;
(* anyconst *) reg [7:0] mem2;
(* anyconst *) reg [7:0] mem3;
(* anyconst *) reg [7:0] mem4;
reg [7:0] mem5;
initial mem5 = 0;


always @(posedge clk) begin
    if (mem_wr && addr == 5) mem5 <= bus_wdata;
    if (addr == 0) assume(bus_rdata == mem0);
    if (addr == 1) assume(bus_rdata == mem1);
    if (addr == 2) assume(bus_rdata == mem2);
    if (addr == 3) assume(bus_rdata == mem3);
    if (addr == 4) assume(bus_rdata == mem4);
end

initial assume(reset == 1);
always @(posedge clk) begin
    if (past_valid) begin
        assume(reset == 0);
        assert(!(mem_wr && mem_rd)); // yeah don't do that
        assert(!(io_wr && io_rd));
        assert(!((mem_wr || mem_rd) && (io_wr || io_rd)));
        cover(mem_rd);
        cover(mem_wr);
        cover(io_rd);
        cover(io_wr);
        cover(opcode_fetch);
        cover(z80_reg_b == 0 && z80_reg_c == 8'hAA);
        cover(mem5 == 8'hBC);
    end
end

`endif

endmodule

`endif // _sequencer_sv_
