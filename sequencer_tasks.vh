`ifndef _sequencer_tasks_vh_
`define _sequencer_tasks_vh_

`include "z80.vh"

// Index of tasks:
//
// task_done()
// task_read_mem(n, addr)      // requires delay with task_collect_data(n)
// task_collect_data(n)
// task_write_mem(n, addr, data)  // requires delay with task_write_mem_done(n)
// task_write_mem_done(n)
// task_read_reg8(n, rnum)
// task_read_reg16(n, rnum)
// task_write_reg8(rnum, data)
// task_write_reg16(rnum, data)
// task_write_reg_pair(rnum, data)

// task_read_mem(n, addr)
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
            next_z80fi_mem_raddr = local_addr;
        end else begin
            next_z80fi_mem_rd2 = 1;
            next_z80fi_mem_raddr2 = local_addr;
        end
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
    if (local_n == 1) next_collected_data[7:0] = mem_rdata;
    else next_collected_data[15:8] = mem_rdata;

    `ifdef Z80_FORMAL
        if (local_n == 1) next_z80fi_mem_rdata = mem_rdata;
        else next_z80fi_mem_rdata2 = mem_rdata;
    `endif
end
endtask

// task_write_mem(addr, data)
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
    next_mem_wdata = local_data;
end
endtask

task task_write_mem_done;
    input [1:0] local_n;
begin
    next_mem_wr = 0;

    `ifdef Z80_FORMAL
        if (local_n == 1) begin
            next_z80fi_mem_wr = 1;
            next_z80fi_mem_waddr = addr;
            next_z80fi_mem_wdata = mem_wdata;
        end else begin
            next_z80fi_mem_wr2 = 1;
            next_z80fi_mem_waddr2 = addr;
            next_z80fi_mem_wdata2 = mem_wdata;
        end
    `endif
end
endtask

task task_read_reg16;
    input [1:0] local_n;
    input [3:0] local_rnum;
begin
    if (local_n == 1) reg1_rnum = local_rnum;
    else reg2_rnum = local_rnum;

    `ifdef Z80_FORMAL
        if (local_n == 1) begin
            next_z80fi_reg1_rd = 1;
            next_z80fi_reg1_rnum = local_rnum;
            next_z80fi_reg1_rdata = reg1_rdata;
        end else begin
            next_z80fi_reg2_rd = 1;
            next_z80fi_reg2_rnum = local_rnum;
            next_z80fi_reg2_rdata = reg2_rdata;
        end
    `endif
end
endtask

task task_read_reg8;
    input [1:0] local_n;
    input [2:0] local_rnum;
begin
    task_read_reg16(local_n, {1'b0, local_rnum});
end
endtask

task task_read_reg_pair;
    input [1:0] local_n;
    input [1:0] local_rnum;
begin
    task_read_reg16(local_n, {2'b10, local_rnum});
end
endtask

task task_write_reg16;
    input `reg_select local_wnum;
    input [15:0] local_data;
begin
    next_reg_wr = 1;
    reg_wnum = local_wnum;
    reg_wdata = local_data;

    `ifdef Z80_FORMAL
        next_z80fi_reg_wr = 1;
        next_z80fi_reg_wnum = local_wnum;
        next_z80fi_reg_wdata = local_data;
    `endif
end
endtask

task task_write_reg8;
    input [2:0] local_wnum;
    input [7:0] local_data;
begin
    task_write_reg16({1'b0, local_wnum}, {8'b0, local_data});
end
endtask

task task_write_reg_pair;
    input [1:0] local_wnum;
    input [15:0] local_data;
begin
    task_write_reg16({2'b10, local_wnum}, local_data);
end
endtask

task task_read_i;
begin
    `ifdef Z80_FORMAL
        next_z80fi_i_rd = 1;
        next_z80fi_i_rdata = i_rdata;
    `endif
end
endtask

task task_write_i;
    input [7:0] local_data;
begin
    next_i_wr = 1;
    i_wdata = local_data;
    `ifdef Z80_FORMAL
        next_z80fi_i_wr = 1;
        next_z80fi_i_wdata = local_data;
    `endif
end
endtask

task task_read_iff2;
begin
    `ifdef Z80_FORMAL
        next_z80fi_iff2_rd = 1;
        next_z80fi_iff2_rdata = iff2;
    `endif
end
endtask


task task_read_r;
begin
    `ifdef Z80_FORMAL
        next_z80fi_r_rd = 1;
        next_z80fi_r_rdata = r_rdata;
    `endif
end
endtask

task task_write_r;
    input [7:0] local_data;
begin
    next_r_wr = 1;
    r_wdata = local_data;
    `ifdef Z80_FORMAL
        next_z80fi_r_wr = 1;
        next_z80fi_r_wdata = local_data;
    `endif
end
endtask

task task_read_f;
begin
    `ifdef Z80_FORMAL
        next_z80fi_f_rd = 1;
        next_z80fi_f_rdata = f_rdata;
    `endif
end
endtask

task task_write_f;
    input [7:0] local_data;
begin
    next_f_wr = 1;
    f_wdata = local_data;
    `ifdef Z80_FORMAL
        next_z80fi_f_wr = 1;
        next_z80fi_f_wdata = local_data;
    `endif
end
endtask

task task_done;
    next_done = 1;
endtask

`endif // _sequencer_tasks_vh_
