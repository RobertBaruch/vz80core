`ifndef _sequencer_sv_
`define _sequencer_sv_

`default_nettype none
`timescale 1us/100 ns

`include "z80.vh"
`include "z80fi.vh"
`include "registers.sv"
`include "instr_decoder.sv"

module sequencer(
    input logic reset,
    input logic clk,
    input logic [7:0] mem_data,
    output logic done,

    output logic [15:0] addr,
    output logic write_mem,
    output logic read_mem,
    output logic [7:0] write_data

`ifdef Z80_FORMAL
    ,
    `Z80_REGS_OUTPUTS
    ,
    `Z80FI_OUTPUTS
`endif
);

logic `reg_select regs_write_to;
logic `reg_select regs_read_from1;
logic `reg_select regs_read_from2;
logic [15:0] regs_in;
logic [15:0] regs_out1;
logic [15:0] regs_out2;
logic write_regs;
logic [7:0] flags_out;
logic [7:0] flags_in;
logic write_flags;
logic [7:0] group;

logic [3:0] state;
logic [15:0] scratch_addr;
logic [15:0] instr;
logic [1:0] instr_len;
logic [15:0] scratch_data;

logic [3:0] next_state;
logic [15:0] next_scratch_addr;
logic [15:0] next_instr;
logic [1:0] next_instr_len;
logic [15:0] next_scratch_data;

logic next_done;
logic [15:0] next_addr;
logic next_read_mem;
logic next_write_mem;
logic [7:0] next_write_data;

logic read_next_instr_byte;
logic next_read_next_instr_byte;

`ifdef Z80_FORMAL
`Z80FI_NEXT_STATE
`endif

registers registers(
    .reset(reset),
    .clk(clk),

    .write_en(write_regs),
    .dest(regs_write_to),
    .in(regs_in),

    .src1(regs_read_from1),
    .out1(regs_out1),

    .src2(regs_read_from2),
    .out2(regs_out2),

    .f_out(flags_out),
    .f_in(flags_in),
    .write_flags_en(write_flags)

`ifdef Z80_FORMAL
    ,
    `Z80_REGS_CONN
`endif
);

logic [15:0] use_instr;
logic [1:0] use_instr_len;

instr_decoder instr_decoder(
    .instr(use_instr),
    .instr_len(use_instr_len),
    .group(group)
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= 0;
        done <= 1;
        addr <= 0;
        read_mem <= 1;
        write_mem <= 0;
        write_data <= 0;
        scratch_addr <= 0;
        scratch_data <= 0;
        instr <= 0;
        instr_len <= 0;
        read_next_instr_byte <= 1;

        `ifdef Z80_FORMAL
        `Z80FI_RESET_STATE
        `endif

    end else begin
        state <= next_state;
        done <= next_done;
        addr <= next_addr;
        read_mem <= next_read_mem;
        write_mem <= next_write_mem;
        write_data <= next_write_data;
        scratch_addr <= next_scratch_addr;
        scratch_data <= next_scratch_data;
        instr <= next_instr;
        instr_len <= next_instr_len;
        read_next_instr_byte <= next_read_next_instr_byte;

        `ifdef Z80_FORMAL
        `Z80FI_LOAD_NEXT_STATE
        `endif

    end
end

// Macros that give the illusion of a procedural program.
// In reality, it just sets up the conditions for the
// action that the name of the macro implies. It also sets
// the z80fi signals so we can keep track of what happened.

task task_read_next_insn_byte;
begin
    next_addr = addr + 1;
    next_read_mem = 1;
end
endtask

// Use task_read_mem1 on the first read from memory (that isn't an
// instruction read).
// On the next state, be sure to use task_read_mem1_result(mem_data).

task task_read_mem1;
    input [15:0] local_addr;
begin
    next_addr = local_addr;                      
    next_read_mem = 1;                     
    `ifdef Z80_FORMAL                      
        next_z80fi_mem_rd = 1;             
        next_z80fi_mem_raddr = local_addr;   
    `endif                                 
end
endtask

task task_read_mem1_result;
    input [7:0] local_data;
begin
    `ifdef Z80_FORMAL                  
        next_z80fi_mem_rdata = local_data;   
    `endif                                 
end
endtask


// Use task_read_mem2 on the first read from memory (that isn't an
// instruction read).
// On the next state, be sure to use task_read_mem2_result(mem_data).

task task_read_mem2;
    input [15:0] local_addr;
begin
    next_addr = local_addr;                      
    next_read_mem = 1;                     
    `ifdef Z80_FORMAL                      
        next_z80fi_mem_rd2 = 1;             
        next_z80fi_mem_raddr2 = local_addr;   
    `endif                                 
end
endtask

task task_read_mem2_result;
    input [7:0] local_data;
begin
    `ifdef Z80_FORMAL                  
        next_z80fi_mem_rdata2 = local_data;   
    `endif                                 
end
endtask

// Use task_write_mem to write data at an address. On the next
// state be sure to call task_write_mem_done. Do not read from
// memory in the same state you are writing in!
task task_write_mem;
    input [15:0] local_addr;
    input [7:0] local_data;
begin
    next_addr = local_addr;  
    next_read_mem = 0;              
    next_write_mem = 1;              
    next_write_data = local_data;          
    `ifdef Z80_FORMAL                
        next_z80fi_mem_wr = 1;       
        next_z80fi_mem_waddr = local_addr;  
        next_z80fi_mem_wdata = local_data; 
    `endif                                 
end
endtask

task task_write_mem_done;
begin
    next_write_mem = 0;
end
endtask

// Use task_write_mem2 to write data at an address for the
// second write of an instruction. On the next state be sure
// to call task_write_mem2_done. Do not read from
// memory in the same state you are writing in!
task task_write_mem2;
    input [15:0] local_addr;
    input [7:0] local_data;
begin
    next_addr = local_addr;  
    next_read_mem = 0;              
    next_write_mem = 1;              
    next_write_data = local_data;          
    `ifdef Z80_FORMAL                
        next_z80fi_mem_wr2 = 1;       
        next_z80fi_mem_waddr2 = local_addr;  
        next_z80fi_mem_wdata2 = local_data; 
    `endif                                 
end
endtask

task task_write_mem2_done;
begin
    next_write_mem = 0;
end
endtask

task task_save_addr;
    input [15:0] local_addr;
begin
    next_scratch_addr = local_addr;
end
endtask

task task_read_reg1;
    input `reg_select local_reg;
begin
    regs_read_from1 = local_reg;                 
    `ifdef Z80_FORMAL                      
        next_z80fi_reg1_rd = 1;            
        next_z80fi_reg1_rnum = local_reg;        
        next_z80fi_reg1_rdata = regs_out1; 
    `endif                                 
end
endtask

task task_read_reg2;
    input `reg_select local_reg;
begin
    regs_read_from2 = local_reg;                 
    `ifdef Z80_FORMAL                      
        next_z80fi_reg2_rd = 1;            
        next_z80fi_reg2_rnum = local_reg;        
        next_z80fi_reg2_rdata = regs_out2; 
    `endif                                 
end
endtask

task task_write_reg;
    input `reg_select local_reg;
    input [15:0] local_data;
begin
    regs_write_to = local_reg;             
    write_regs = 1;                  
    regs_in = local_data;                  
    `ifdef Z80_FORMAL                
        next_z80fi_reg_wr = 1;       
        next_z80fi_reg_wnum = local_reg;   
        next_z80fi_reg_wdata = local_data; 
    `endif
end
endtask

// This should always be paired with task_read_next_insn_byte()
// except for the very last one in the instruction.
task task_append_insn_byte;
begin
    `ifdef Z80_FORMAL      
        // We use next_z80fi_insn_len here instead of
        // z80fi_insn_len because on the done signal,
        // z80fi_valid goes high and z80fi_insn_len
        // contains the instruction length of the last
        // instruction. However, we have collected zero
        // bytes in the next instruction, which means
        // we have to use next_z80fi_insn_len, which is
        // set to zero on done -- and then immediately
        // to one here, which is correct.
        case (next_z80fi_insn_len)
            0: begin
                next_z80fi_insn = {24'b0, mem_data};
                next_z80fi_pc_rdata = addr;
            end
            1: next_z80fi_insn[15:8] = mem_data;
            2: next_z80fi_insn[23:16] = mem_data;
            3: next_z80fi_insn[31:24] = mem_data;
            default: ;
        endcase
        next_z80fi_insn_len = next_z80fi_insn_len + 1;
    `endif    
end
endtask

// Use task_done to indicate that the instruction is done. The
// insn_len argument is the address to go to for the
// next instruction.

task task_done;
    input [15:0] local_addr;
begin
    next_done = 1;
    next_state = 0;
    next_read_mem = 1;                   
    next_read_next_instr_byte = 1;       
    next_instr_len = 0;                  
    next_addr = local_addr;                    
    `ifdef Z80_FORMAL                    
        next_z80fi_valid = 1;            
        next_z80fi_pc_wdata = local_addr; 
    `endif
end
endtask

always @(*) begin
    next_state = 0;
    next_done = 0;
    next_addr = addr;
    next_read_mem = 0;
    next_write_mem = 0;
    next_write_data = 0;
    next_scratch_addr = scratch_addr;
    next_scratch_data = scratch_data;
    next_read_next_instr_byte = 0;

    `ifdef Z80_FORMAL
    if (done) begin
        `Z80FI_INIT_NEXT_STATE
    end else begin
        `Z80FI_RETAIN_NEXT_STATE
    end
    `endif

    write_regs = 0;
    regs_write_to = 0;
    regs_read_from1 = 0;
    regs_read_from2 = 0;
    flags_in = 0;
    write_flags = 0;
    regs_in = 0;

    // if we have no instruction, or need another byte,
    // add the byte to the instruction and try it.
    // Otherwise keep the instruction.
    if (instr_len == 0 || read_next_instr_byte) begin
        use_instr_len = instr_len + 1;
        if (instr_len == 0) use_instr = {8'b0, mem_data};
        else use_instr = {mem_data, instr[7:0]};
        next_instr_len = instr_len + 1;
        next_instr = use_instr;
    end else begin
        use_instr_len = instr_len;
        use_instr = instr;
        next_instr_len = instr_len;
        next_instr = instr;
    end

    if (!reset) begin
        case (group)
            `INSN_GROUP_NEED_MORE_BYTES: begin
                next_read_next_instr_byte = 1;
                task_append_insn_byte();
                task_read_next_insn_byte();
            end

            `INSN_GROUP_LD_REG_REG:  // LD r, r'
                case (state)
                    0: begin
                        task_append_insn_byte();
                        task_read_reg1({1'b0, use_instr[2:0]});
                        task_write_reg({1'b0, use_instr[5:3]}, {8'b0, regs_out1[7:0]});
                        task_done(addr + 1);
                    end
                endcase

            `INSN_GROUP_LD_BCDE_A:  // LD (BC), A / LD (DE), A
                case (state)
                    0: begin
                        task_append_insn_byte();
                        task_read_reg1(`REG_A);
                        task_read_reg2(use_instr[4] ? `REG_DE : `REG_BC);
                        task_save_addr(addr + 1);
                        task_write_mem(regs_out2, regs_out1[7:0]);
                        next_state = 1;
                    end
                    1: begin
                        task_write_mem_done();
                        task_done(scratch_addr);
                    end
                endcase

            `INSN_GROUP_LD_REG_IMMED:  // LD r, n
                case (state)
                    0: begin
                        task_append_insn_byte();
                        task_read_next_insn_byte();
                        next_state = 1;
                    end
                    1: begin
                        task_append_insn_byte();
                        task_write_reg({1'b0, use_instr[5:3]}, {8'b0, mem_data});
                        task_done(addr + 1);
                    end
                endcase

            `INSN_GROUP_LD_HL_IMMED:  // LD (HL), n
                case (state)
                    0: begin
                        task_append_insn_byte();
                        task_read_next_insn_byte();
                        next_state = 1;
                    end
                    1: begin
                        task_append_insn_byte();
                        task_read_reg1(`REG_HL);
                        task_save_addr(addr + 1);
                        task_write_mem(regs_out1, mem_data);
                        next_state = 2;
                        end
                    2: begin
                        task_write_mem_done();
                        task_done(scratch_addr);
                    end
                endcase

            `INSN_GROUP_LD_HL_REG:  // LD (HL), r
                case (state)
                    0: begin
                        task_append_insn_byte();
                        task_read_reg1(`REG_HL);
                        task_read_reg2({1'b0, use_instr[2:0]});
                        task_save_addr(addr + 1);
                        task_write_mem(regs_out1, regs_out2[7:0]);
                        next_state = 1;
                    end
                    1: begin
                        task_write_mem_done();
                        task_done(scratch_addr);
                    end
                endcase

            `INSN_GROUP_LD_DD_IMMED:  // LD dd, nn
                case (state)
                    0: begin
                        task_append_insn_byte();
                        task_read_next_insn_byte();
                        next_state = 1;
                    end
                    1: begin
                        task_append_insn_byte();
                        task_read_next_insn_byte();
                        next_scratch_data = {8'b0, mem_data};
                        next_state = 2;
                    end
                    2: begin
                        task_append_insn_byte();
                        next_scratch_data[15:8] = mem_data;
                        task_write_reg({2'b10, use_instr[5:4]}, next_scratch_data);
                        task_done(addr + 1);
                    end
                endcase

            `INSN_GROUP_LD_A_EXTADDR:  // LD A, (nn)
                case (state)
                    0: begin
                        task_append_insn_byte();
                        task_read_next_insn_byte();
                        next_state = 1;
                    end
                    1: begin
                        task_append_insn_byte();
                        next_scratch_addr = {8'h00, mem_data};
                        task_read_next_insn_byte();
                        next_state = 2;
                    end
                    2: begin
                        task_append_insn_byte();
                        task_save_addr(addr + 1);
                        task_read_mem1({mem_data, scratch_addr[7:0]});
                        next_state = 3;
                    end
                    3: begin
                        task_read_mem1_result(mem_data);
                        task_write_reg(`REG_A, {8'b0, mem_data});
                        task_done(scratch_addr);
                    end
                endcase

            `INSN_GROUP_LD_EXTADDR_A:  // LD (nn), A
                case (state)
                    0: begin
                        task_append_insn_byte();
                        task_read_next_insn_byte();
                        next_state = 1;
                        end
                    1: begin
                        task_append_insn_byte();
                        next_scratch_addr = {8'h00, mem_data};
                        task_read_next_insn_byte();
                        next_state = 2;
                    end
                    2: begin
                        task_append_insn_byte();
                        task_save_addr(addr + 1);
                        task_read_reg1(`REG_A);
                        task_write_mem({mem_data, scratch_addr[7:0]}, regs_out1);
                        next_state = 3;
                    end
                    3: begin
                        task_write_mem_done();
                        task_done(scratch_addr);
                    end
                endcase

            `INSN_GROUP_LD_DD_EXTADDR: // LD dd, (nn)
                case (state)
                    0: begin
                        task_append_insn_byte();
                        task_read_next_insn_byte();
                        next_state = 1;
                    end
                    1: begin
                        task_append_insn_byte();
                        next_scratch_data = {8'h00, mem_data};
                        task_read_next_insn_byte();
                        next_state = 2;
                        end
                    2: begin
                        task_append_insn_byte();
                        task_save_addr(addr + 1);
                        // Set up the addr to read data from
                        task_read_mem1({mem_data, scratch_data[7:0]});
                        next_state = 3;
                    end
                    3: begin
                        // Put the mem data in the low byte of scratch data,
                        // read the next byte in memory.
                        task_read_mem1_result(mem_data);
                        task_read_mem2(addr + 1);
                        next_scratch_data = {8'b0, mem_data};
                        next_state = 4;
                    end
                    4: begin
                        // Put the mem data in the high byte of scratch data.
                        // Write it to the 16-bit register.
                        // Jump to the scratch addr.
                        task_read_mem2_result(mem_data);
                        next_scratch_data = {mem_data, scratch_data[7:0]};
                        task_write_reg({2'b10, use_instr[13:12]}, next_scratch_data);
                        task_done(scratch_addr);
                    end
                endcase

            `INSN_GROUP_LD_EXTADDR_DD: // LD dd, (nn)
                case (state)
                    0: begin
                        task_append_insn_byte(); // dd
                        task_read_next_insn_byte();
                        next_state = 1;
                    end
                    1: begin
                        task_append_insn_byte(); // nn
                        next_scratch_data = {8'h00, mem_data};
                        task_read_next_insn_byte();
                        next_state = 2;
                        end
                    2: begin
                        task_append_insn_byte(); // nn
                        task_save_addr(addr + 1);
                        task_read_reg1({2'b10, use_instr[13:12]});
                        next_scratch_data = {mem_data, scratch_data[7:0]} + 1;
                        task_write_mem({mem_data, scratch_data[7:0]}, regs_out1[7:0]);
                        next_state = 3;
                    end
                    3: begin
                        task_write_mem_done();
                        task_write_mem2(scratch_data, regs_out1[15:8]);
                        next_state = 4;
                    end
                    4: begin
                        task_write_mem2_done();
                        task_done(scratch_addr);
                    end
                endcase

            `INSN_GROUP_LD_REG_IXIY:  // LD r, (IX/IY + d)
                case (state)
                    0: begin
                        task_append_insn_byte();
                        task_read_next_insn_byte();
                        next_state = 1;
                    end
                    1: begin
                        task_append_insn_byte(); // d
                        task_read_reg1(use_instr[5] ? `REG_IY : `REG_IX);
                        task_save_addr(addr + 1);
                        task_read_mem1(regs_out1 + {8'b0, mem_data});
                        next_state = 2;
                    end
                    2: begin
                        task_read_mem1_result(mem_data);
                        task_write_reg({1'b0, use_instr[13:11]}, mem_data);
                        task_done(scratch_addr);
                    end
                endcase

            `INSN_GROUP_LD_IXIY_IMMED:  // LD (IX/IY + d), n
                case (state)
                    0: begin
                        task_append_insn_byte();
                        task_read_next_insn_byte();
                        next_state = 1;
                    end
                    1: begin
                        task_append_insn_byte(); // d
                        task_read_next_insn_byte();
                        task_read_reg1(use_instr[5] ? `REG_IY : `REG_IX);
                        task_save_addr(regs_out1 + {8'b0, mem_data});
                        next_state = 2;
                    end
                    2: begin
                        task_append_insn_byte(); // n
                        task_write_mem(scratch_addr, mem_data);
                        task_save_addr(addr + 1);
                        next_state = 3;
                    end
                    3: begin
                        task_write_mem_done();
                        task_done(scratch_addr);
                    end
                endcase

            `INSN_GROUP_LD_IXIY_REG:  // LD (IX/IY + d), r
                case (state)
                    0: begin
                        task_append_insn_byte();
                        task_read_next_insn_byte();
                        next_state = 1;
                    end
                    1: begin
                        task_append_insn_byte(); // d
                        task_read_reg1(use_instr[5] ? `REG_IY : `REG_IX);
                        task_read_reg2({1'b0, use_instr[10:8]});
                        task_write_mem(regs_out1 + {8'b0, mem_data}, regs_out2[7:0]);
                        task_save_addr(addr + 1);
                        next_state = 2;
                    end
                    2: begin
                        task_write_mem_done();
                        task_done(scratch_addr);
                    end
                endcase

        endcase
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
if (write_mem && addr == 5) mem5 <= write_data;
if (addr == 0) assume(mem_data == mem0);
if (addr == 1) assume(mem_data == mem1);
if (addr == 2) assume(mem_data == mem2);
if (addr == 3) assume(mem_data == mem3);
if (addr == 4) assume(mem_data == mem4);
end

initial assume(reset == 1);
always @(posedge clk) begin
    if (past_valid) begin
        assume(reset == 0);
        assert(!(write_mem && read_mem)); // yeah don't do that
        cover(z80_reg_b == 0 && z80_reg_c == 8'hAA);
        cover(mem5 == 8'hBC);
    end
end

`endif

endmodule

`endif // _sequencer_sv_
