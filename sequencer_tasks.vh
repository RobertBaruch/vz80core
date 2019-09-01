`ifndef _sequencer_tasks_vh_
`define _sequencer_tasks_vh_

`include "z80.vh"

// Index of tasks:
//
// task_idle()
// task_done()
// task_read_mem(n, addr)         // requires one cycle delay with task_collect_data(n)
// task_collect_data(n)
// task_write_mem(n, addr, data)  // requires one cycle delay with task_write_mem_done(n)
// task_write_mem_done(n)
// task_read_io(addr)             // requires one cycle delay with task_collect_data(1)
// task_write_io(addr, data)      // requires one cycle delay with task_write_io_done()
// task_write_io_done()
// task_read_reg(n, rnum)
// task_write_reg(rnum, data)
// task_write_i(data)  // write the I register
// task_write_r(data)  // write the R register
// task_write_f(data)  // write the Flags register
// task_block_inc()
// task_block_dec()
// task_compare_block_inc()
// task_compare_block_dec()
// task_ex_de_hl()
// task_ex_af_af2()
// task_exx()
// task_alu8_op(func, x, y)
// task_alu16_op(func, x, y)
// task_rotate_decimal(left, acc, mem, addr) // For RRD/RLD insns.
// task_jump(addr)
// task_jump_relative(offset)
// task_enable_interrupts()
// task_disable_interrupts()
// task_accept_nmi()
// task_ret_from_nmi()
// task_set_im(mode)

// task_idle has the sequencer_program do nothing except request that the
// next cycle be an M1 cycle.
task task_idle;
begin
    next_cycle = `CYCLE_M1;
    next_addr = addr;
    next_z80_reg_ip = z80_reg_ip;
    add_to_insn = 0;
    add_to_op = 0;
    add_to_store_data = 0;
    next_state = state;
    bus_wdata = 0;
    mem_wr = 0;
    mem_rd = 0;
    io_wr = 0;
    io_rd = 0;
    extend_cycle = 0;
    reg1_rnum = 0;
    reg2_rnum = 0;
    reg_wr = 0;
    reg_wnum = 0;
    reg_wdata = 0;
    f_wr = 0;
    f_wdata = 0;
    block_inc = 0;
    block_dec = 0;
    block_compare = 0;
    ex_de_hl = 0;
    ex_af_af2 = 0;
    exx = 0;
    alu8_x = 0;
    alu8_y = 0;
    alu8_func = 0;
    alu16_x = 0;
    alu16_y = 0;
    alu16_func = 0;
    i_wr = 0;
    i_wdata = 0;
    r_wr = 0;
    r_wdata = 0;
    enable_interrupts = 0;
    disable_interrupts = reset;
    accept_nmi = 0;
    ret_from_nmi = 0;
    next_z80_reg_im = z80_reg_im;
    done = 0;
    jumped = 0;
end
endtask

// task_read_mem(n, addr)
//
// n is 1 or 2, depending on whether you're reading for the first time
// in the instruction, or the second time (not including instruction
// bytes).
//
// Set up to read memory at the given address. n is the
// number of the read in this instruction, starting from 1.
// n makes no difference in the logic, but does matter to
// formal.
task task_read_mem;
    input [1:0] local_n;
    input [15:0] local_addr;
begin
    next_addr = local_addr;
    mem_rd = 1;
end
endtask

// task_read_io(addr)
//
// Reads a byte of I/O with the given address.
task task_read_io;
    input [15:0] local_addr;
begin
    next_addr = local_addr;
    mem_rd = 0;
    io_rd = 1;
end
endtask

// task_collect_data(n)
// Collect the data read from memory. n is the
// number of the read in this instruction, starting from 1.
// The collected data is in next_stored_data.
task task_collect_data;
    input [1:0] local_n;
begin
    /*if (local_n == 1) begin
        next_stored_data = {stored_data[15:8], bus_rdata};
    end else begin
        next_stored_data = {bus_rdata, stored_data[7:0]};
    end */
    add_to_store_data = 1;
end
endtask

// task_write_mem(n, addr, data)
//
// n is 1 or 2, depending on whether you're writing for the first time
// in the instruction, or the second time.
//
// You must delay one cycle before continuing (or ending) the instruction,
// with task_write_mem_done(n).
task task_write_mem;
    input [1:0] local_n;
    input [15:0] local_addr;
    input [7:0] local_data;
begin
    next_addr = local_addr;
    mem_rd = 0;
    mem_wr = 1;
    bus_wdata = local_data;
end
endtask

task task_write_mem_done;
    input [1:0] local_n;
begin
    mem_wr = 0;
end
endtask

// task_write_io(addr, data)
//
// You must delay one cycle before continuing (or ending) the instruction,
// with task_write_io_done().
task task_write_io;
    input [15:0] local_addr;
    input [7:0] local_data;
begin
    next_addr = local_addr;
    mem_rd = 0;
    io_rd = 0;
    io_wr = 1;
    bus_wdata = local_data;
end
endtask

task task_write_io_done;
begin
    io_wr = 0;
end
endtask

// task_read_reg places the given register on the given
// register output bus (there are two of them, 1 and 2). Remember that
// if you need the register output for more than one cycle, you
// have to read it again. This doesn't cost anything.
task task_read_reg;
    input [1:0] local_n;
    input `reg_select local_rnum;
begin
    if (local_n == 1) reg1_rnum = local_rnum;
    else reg2_rnum = local_rnum;
end
endtask

// task_write_reg writes the given register with the given data
// on the next positive edge of the clock. If writing an 8-bit
// register, the upper 8 bits of the data are ignored.
task task_write_reg;
    input `reg_select local_wnum;
    input [15:0] local_data;
begin
    reg_wr = 1;
    reg_wnum = local_wnum;
    reg_wdata = local_data;
end
endtask

// Sets up the registers to do a block increment operation on the
// next positive edge of the clock.
task task_block_inc;
begin
    block_inc = 1;
end
endtask

// Sets up the registers to do a block decrement operation on the
// next positive edge of the clock.
task task_block_dec;
begin
    block_dec = 1;
end
endtask

// Sets up the registers to do a compare block increment operation on the
// next positive edge of the clock.
task task_compare_block_inc;
begin
    block_inc = 1;
    block_compare = 1;
end
endtask

// Sets up the registers to do a compare block decrement operation on the
// next positive edge of the clock.
task task_compare_block_dec;
begin
    block_dec = 1;
    block_compare = 1;
end
endtask

// Sets up the registers to exchange DE and HL on the
// next positive edge of the clock.
task task_ex_de_hl;
begin
    ex_de_hl = 1;
end
endtask

// Sets up the registers to exchange AF and AF2 on the
// next positive edge of the clock.
task task_ex_af_af2;
begin
    ex_af_af2 = 1;
end
endtask

// Sets up the registers to exchange BC, DE, HL and BC2, DE2, HL2
// on the next positive edge of the clock.
task task_exx;
begin
    exx = 1;
end
endtask

// task_write_i writes the I register on the next positive edge of the clock.
task task_write_i;
    input [7:0] local_data;
begin
    i_wr = 1;
    i_wdata = local_data;
end
endtask

// task_write_r writes the R register on the next positive edge of the clock.
task task_write_r;
    input [7:0] local_data;
begin
    r_wr = 1;
    r_wdata = local_data;
end
endtask

// task_write_f writes the Flags register on the next positive edge of the clock.
task task_write_f;
    input [7:0] local_data;
begin
    f_wr = 1;
    f_wdata = local_data;
end
endtask

task task_alu8_compare;
    input [7:0] local_x;
    input [7:0] local_y;
begin
    alu8_x = local_x;
    alu8_y = local_y;
    alu8_func = `ALU_FUNC_SUB;
end
endtask

task task_alu8_op;
    input [3:0] local_op;
    input [7:0] local_x;
    input [7:0] local_y;
begin
    alu8_x = local_x;
    alu8_y = local_y;
    alu8_func = local_op;
end
endtask

task task_alu16_op;
    input [2:0] local_op;
    input [15:0] local_x;
    input [15:0] local_y;
begin
    alu16_x = local_x;
    alu16_y = local_y;
    alu16_func = local_op;
end
endtask

task task_rotate_decimal;
    input left;
    input [7:0] a;
    input [7:0] m;
    input [15:0] addr;
begin
    task_write_reg(`REG_A, left ? {a[7:4], m[7:4]} : {a[7:4], m[3:0]});
    task_write_mem(1, addr, left ? {m[3:0], a[3:0]} : {a[3:0], m[7:4]});
    task_write_f({
        a[7], // S
        a[7:4] == 0 && (left ? m[7:4] : m[3:0]) == 0, // Z
        flag_5,
        1'b0, // H
        flag_3,
        _parity8(left ? {a[7:4], m[7:4]} : {a[7:4], m[3:0]}), // V
        1'b0, // N
        flag_c
    });
end
endtask

task task_disable_interrupts;
begin
    disable_interrupts = 1;
end
endtask

task task_enable_interrupts;
begin
    enable_interrupts = 1;
end
endtask

task task_accept_nmi;
begin
    accept_nmi = 1;
end
endtask

task task_ret_from_nmi;
begin
    ret_from_nmi = 1;
end
endtask

task task_jump;
    input [15:0] local_addr;
begin
    next_z80_reg_ip = local_addr;
    jumped = 1;
end
endtask

task task_jump_relative;
    input [15:0] offset;
begin
    next_z80_reg_ip = next_z80_reg_ip + offset;
    jumped = 1;
end
endtask

task task_set_im;
    input [1:0] mode;
begin
    next_z80_reg_im = mode;
end
endtask

task task_next_cycle_internal;
begin
    next_cycle = `CYCLE_INTERNAL;
    internal_cycle = 5;
end
endtask

task task_next_cycle_internal4;
begin
    next_cycle = `CYCLE_INTERNAL4;
    internal_cycle = 4;
end
endtask

task task_next_cycle_internal3;
begin
    next_cycle = `CYCLE_INTERNAL3;
    internal_cycle = 3;
end
endtask

task task_extend_cycle;
begin
    next_cycle = `CYCLE_EXTENDED;
    extend_cycle = 1;
end
endtask

// task_done must be run at the end of an instruction, otherwise the
// instruction will never end!
task task_done;
begin
    done = 1;
    next_cycle = `CYCLE_M1;
    // mem_rd = 0;
    add_to_insn = 0;
    add_to_op = 0;
    next_state = 0;
    // if (!jumped) next_z80_reg_ip = z80_reg_ip + 1;
    next_addr = next_z80_reg_ip;
end
endtask

`endif // _sequencer_tasks_vh_
