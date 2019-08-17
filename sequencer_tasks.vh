`ifndef _sequencer_tasks_vh_
`define _sequencer_tasks_vh_

`include "z80.vh"

// Index of tasks:
//
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
    next_mem_rd = 1;

    `ifdef Z80_FORMAL
        if (local_n == 1) begin
            next_z80fi_mem_rd = 1;
            next_z80fi_bus_raddr = local_addr;
        end else begin
            next_z80fi_mem_rd2 = 1;
            next_z80fi_bus_raddr2 = local_addr;
        end
    `endif
end
endtask

// task_read_io(addr)
//
// Reads a byte of I/O with the given address.
task task_read_io;
    input [15:0] local_addr;
begin
    next_addr = local_addr;
    next_mem_rd = 0;
    next_io_rd = 1;

    `ifdef Z80_FORMAL
        next_z80fi_io_rd = 1;
        next_z80fi_bus_raddr = local_addr;
    `endif
end
endtask

// task_collect_data(n)
// Collect the data read from memory. n is the
// number of the read in this instruction, starting from 1.
// The collected data is in next_collected_data.
task task_collect_data;
    input [1:0] local_n;
begin
    if (local_n == 1) next_collected_data[7:0] = bus_rdata;
    else next_collected_data[15:8] = bus_rdata;

    `ifdef Z80_FORMAL
        if (local_n == 1) next_z80fi_bus_rdata = bus_rdata;
        else next_z80fi_bus_rdata2 = bus_rdata;
    `endif
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
    next_mem_rd = 0;
    next_mem_wr = 1;
    next_bus_wdata = local_data;
end
endtask

task task_write_mem_done;
    input [1:0] local_n;
begin
    next_mem_wr = 0;

    `ifdef Z80_FORMAL
        if (local_n == 1) begin
            next_z80fi_mem_wr = 1;
            next_z80fi_bus_waddr = addr;
            next_z80fi_bus_wdata = bus_wdata;
        end else begin
            next_z80fi_mem_wr2 = 1;
            next_z80fi_bus_waddr2 = addr;
            next_z80fi_bus_wdata2 = bus_wdata;
        end
    `endif
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
    next_mem_rd = 0;
    next_io_rd = 0;
    next_io_wr = 1;
    next_bus_wdata = local_data;
end
endtask

task task_write_io_done;
begin
    next_io_wr = 0;

    `ifdef Z80_FORMAL
        next_z80fi_io_wr = 1;
        next_z80fi_bus_waddr = addr;
        next_z80fi_bus_wdata = bus_wdata;
    `endif
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
        f_rdata[`FLAG_5_NUM],
        1'b0, // H
        f_rdata[`FLAG_3_NUM],
        _alu_parity8(left ? {a[7:4], m[7:4]} : {a[7:4], m[3:0]}), // V
        1'b0, // N
        f_rdata[`FLAG_C_NUM]
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
end
endtask

task task_jump_relative;
    input [15:0] offset;
begin
    next_z80_reg_ip = next_z80_reg_ip + offset;
end
endtask

task task_set_im;
    input [1:0] mode;
begin
    next_z80_reg_im = mode;
end
endtask

// task_done must be run at the end of an instruction, otherwise the
// instruction will never end!
task task_done;
    next_done = 1;
endtask

`endif // _sequencer_tasks_vh_
