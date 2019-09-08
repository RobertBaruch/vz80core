`ifndef _sequencer_program_sv_
`define _sequencer_program_sv_

`include "z80.vh"
`include "instr_decoder.sv"

`default_nettype none
`timescale 1us/1us

// sequencer_program is a module that, given its inputs, combinatorically outputs
// what it wants the parent module to do. So for example, if the input address is
// N and the input data is 0, and that is the first byte in the opcode, then the
// output address will be N+1 and the instruction is complete since this is a NOP
// instruction.
//
// There are many things we can do simultaneously, but also many things we can't.
module sequencer_program(
    input logic reset,
    input logic [15:0] addr,
    input logic [7:0] bus_rdata,
    input logic [15:0] z80_reg_ip,
    input logic [31:0] insn,
    input logic [2:0] insn_len, // length of instruction
    input logic [1:0] op_len, // length of opcode not including operand
    input logic [4:0] state,
    input logic [15:0] stored_data,
    input logic [1:0] stored_data_len,
    input logic [15:0] reg1_rdata,
    input logic [15:0] reg2_rdata,
    input logic [7:0] z80_reg_f,
    input logic [7:0] alu8_out,
    input logic [7:0] alu8_f_out,
    input logic [15:0] alu16_out,
    input logic [7:0] alu16_f_out,
    input logic [7:0] z80_reg_i,
    input logic [7:0] z80_reg_r,
    input logic z80_reg_iff1,
    input logic z80_reg_iff2,
    input logic [1:0] z80_reg_im,

    // This is the next type of cycle we want to perform.
    // TODO: Remove this.
    output logic [2:0] next_cycle,
    // This is the next address we want.
    output logic [15:0] next_addr,
    // This is the next IP we want.
    output logic [15:0] next_z80_reg_ip,
    // We want to add bus_rdata, when it's ready, to the insn.
    output logic add_to_insn,
    // We also want to increment op_len when we add to the insn.
    output logic add_to_op,
    // We want to add bus_rdata, when it's ready, to stored_data.
    output logic add_to_store_data,
    // This is the next state we want in handling a multi-state instruction.
    output logic [4:0] next_state,

    output logic [7:0] bus_wdata,
    // We want to write bus_wdata at memory location next_addr.
    output logic mem_wr,
    // We want to read bus_rdata at memory location next_addr.
    output logic mem_rd,
    // We want to write bus_wdata at I/O location next_addr.
    output logic io_wr,
    // We want to read bus_rdata at I/O location next_addr.
    output logic io_rd,
    // We want to extend the mcycle by one tcycle.
    output logic extend_cycle,
    // We want to run an internal cycle.
    output logic internal_cycle,
    // The register to put on bus 1.
    output logic `reg_select reg1_rnum,
    // The register to put on bus 2.
    output logic `reg_select reg2_rnum,
    // We want to write a register.
    output logic reg_wr,
    output logic `reg_select reg_wnum,
    output logic [15:0] reg_wdata,
    // We want to write flags.
    output logic f_wr,
    output logic [7:0] f_wdata,
    // We want to do one of these things:
    output logic block_inc,
    output logic block_dec,
    output logic block_compare,
    output logic ex_de_hl,
    output logic ex_af_af2,
    output logic exx,
    // We want to do an alu8 op.
    output logic [7:0] alu8_x,
    output logic [7:0] alu8_y,
    output logic [3:0] alu8_func,
    // We want to do an alu16 op.
    output logic [15:0] alu16_x,
    output logic [15:0] alu16_y,
    output logic [3:0] alu16_func,
    // We want to write the I register.
    output logic i_wr,
    output logic [7:0] i_wdata,
    // We want to write the R register.
    output logic r_wr,
    output logic [7:0] r_wdata,
    // We want to do one of these things:
    output logic enable_interrupts,
    output logic disable_interrupts,
    output logic accept_nmi,
    output logic ret_from_nmi,
    // The next IM we want.
    output logic [1:0] next_z80_reg_im,
    // We are done with this instruction after all the things we asked for
    // are done (so the next cycle will be an M1).
    output logic done
);

logic flag_s;
logic flag_z;
logic flag_5;
logic flag_h;
logic flag_3;
logic flag_pv;
logic flag_n;
logic flag_c;

assign flag_s  = z80_reg_f[7];
assign flag_z  = z80_reg_f[6];
assign flag_5  = z80_reg_f[5];
assign flag_h  = z80_reg_f[4];
assign flag_3  = z80_reg_f[3];
assign flag_pv = z80_reg_f[2];
assign flag_n  = z80_reg_f[1];
assign flag_c  = z80_reg_f[0];

logic [2:0] decoded_len; // output from instr_decoder
logic [7:0] decoded_group; // output from instr_decoder

instr_decoder instr_decoder(
    .instr(insn),
    .op_len(op_len),
    .len(decoded_len),
    .group(decoded_group)
);
logic [15:0] insn_operand;

`include "sequencer_tasks.vh"

logic [7:0] ixiy_bits_group; // output from ixiy_bits_decoder module

instr_ixiy_bits_decoder ixiy_bits_decoder(
    .instr(insn[31:24]),
    .group(ixiy_bits_group)
);

// jumped indicates whether we executed an absolute or relative jump.
// If this is not set and we execute a task_done, then by default
// we'll set the next ip to z80_reg_ip + 1.
logic jumped;

// handle_ixiy_bits_group handles the ixiy_bits group.
//
// ixiy_bits_group has to be an input to this task, as opposed to
// all the other signals this task, because this task is the only place
// ixiy_bits_group is used, and so the always @(*) cannot figure out
// that ixiy_bits_group is part of its sensitivity list. Therefore,
// we have to mention it somewhere in the always block.
task handle_ixiy_bits_group;
    input [7:0] ixiy_bits_group;
begin
    case (ixiy_bits_group)
        `INSN_GROUP_RR_RLC_IDX_IXIY: /* RLCA/RLC/RRCA/RRA (IX/IY + d) */
            case (state)
                0: task_extend_cycle();
                1: task_extend_cycle();
                2: begin
                    task_read_reg(1, {`REG_SET_IDX, insn[5]});
                    task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                end
                3: begin
                    task_extend_cycle();
                    task_collect_data(1);
                end
                4: begin
                    task_read_reg(1, {`REG_SET_IDX, insn[5]});
                    task_alu8_op(
                        {`ALU_ROT, insn[28:27]},
                        stored_data[7:0],
                        0);
                    task_write_f(`FLAG_H_MASK & `FLAG_N_MASK & alu8_f_out);
                    task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]}, alu8_out);
                end
                5: begin
                    task_write_mem_done(1);
                    task_done();
                end
            endcase

        `INSN_GROUP_SHIFT_IDX_IXIY: /* SRA/SRL/SLA (IX/IY + d) */
            case (state)
                0: task_extend_cycle();
                1: task_extend_cycle();
                2: begin
                    task_read_reg(1, {`REG_SET_IDX, insn[5]});
                    task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                end
                3: begin
                    task_extend_cycle();
                    task_collect_data(1);
                end
                4: begin
                    task_read_reg(1, {`REG_SET_IDX, insn[5]});
                    task_alu8_op(
                        {`ALU_SHIFT, insn[28:27]},
                        stored_data[7:0],
                        0);
                    task_write_f(`FLAG_H_MASK & `FLAG_N_MASK & alu8_f_out);
                    task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]}, alu8_out);
                end
                5: begin
                    task_write_mem_done(1);
                    task_done();
                end
            endcase

        `INSN_GROUP_BIT_IDX_IXIY: /* BIT b, (IX/IY + d) */
            case (state)
                0: task_extend_cycle();
                1: task_extend_cycle();
                2: begin
                    task_read_reg(1, {`REG_SET_IDX, insn[5]});
                    task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                end
                3: begin
                    task_extend_cycle();
                    task_collect_data(1);
                end
                4: begin
                    task_write_f({
                        // Undocumented value of S flag:
                        // Set if bit = 7 and bit 7 in r is set.
                        insn[29:27] == 3'b111 && stored_data[7] == 1'b1, // S ("unknown")
                        ~stored_data[insn[29:27]], // Z
                        flag_5,
                        1'b1, // H
                        flag_3,
                        // Undocumented value of PV flag: Same as Z.
                        ~stored_data[insn[29:27]],  // PV ("unknown")
                        1'b0, // N
                        flag_c
                    });
                    task_done();
                end
            endcase

        `INSN_GROUP_SET_IDX_IXIY: /* SET b, (IX/IY + d) */
            case (state)
                0: task_extend_cycle();
                1: task_extend_cycle();
                2: begin
                    task_read_reg(1, {`REG_SET_IDX, insn[5]});
                    task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                end
                3: begin
                    task_extend_cycle();
                    task_collect_data(1);
                end
                4: begin
                    task_read_reg(1, {`REG_SET_IDX, insn[5]});
                    task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]},
                        stored_data[7:0] | (8'b1 << insn[29:27]));
                end
                5: begin
                    task_write_mem_done(1);
                    task_done();
                end
            endcase

        `INSN_GROUP_RES_IDX_IXIY: /* RES b, (IX/IY + d) */
            case (state)
                0: task_extend_cycle();
                1: task_extend_cycle();
                2: begin
                    task_read_reg(1, {`REG_SET_IDX, insn[5]});
                    task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                end
                3: begin
                    task_extend_cycle();
                    task_collect_data(1);
                end
                4: begin
                    task_read_reg(1, {`REG_SET_IDX, insn[5]});
                    task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]},
                        stored_data[7:0] & ~(8'b1 << insn[29:27]));
                end
                5: begin
                    task_write_mem_done(1);
                    task_done();
                end
            endcase

        default: begin // For illegal instructions, just assume done
            task_done();
        end
    endcase
end
endtask

always @(*) begin
    task_idle();

    case (op_len)
        1: insn_operand = insn[23:8];
        default: insn_operand = insn[31:16];
    endcase

    if (!reset) begin
        // Here we check that we have enough bytes for the op.
        if (decoded_group == `INSN_GROUP_NEED_MORE_BYTES
                || decoded_len != insn_len) begin
            add_to_insn = 1;
            next_addr = z80_reg_ip + 1;
            next_z80_reg_ip = z80_reg_ip + 1;
            mem_rd = 1;
            if (decoded_group == `INSN_GROUP_NEED_MORE_BYTES) begin
                add_to_op = 1;
                next_cycle = `CYCLE_M1;
            end else begin
                next_cycle = `CYCLE_RDWR_MEM;
            end

        end else begin
            if (state == 0) next_z80_reg_ip = z80_reg_ip + 1;
            next_cycle = `CYCLE_INTERNAL;
            mem_rd = 0;
            next_state = state + 1;
            add_to_insn = 0;
            add_to_op = 0;

            case (decoded_group)
                `INSN_GROUP_NOP: begin /* NOP */
                    task_done();
                end

                // TODO: Break out of halt on interrupt
                `INSN_GROUP_HALT: begin  /* HALT */
                    task_jump_relative(-16'h1);
                    task_done();
                end

                `INSN_GROUP_IM: begin /* IM 0/1/2 */
                    case (insn[12:11])
                        2'b00: task_set_im(2'b00);
                        2'b10: task_set_im(2'b01);
                        2'b11: task_set_im(2'b10);
                    endcase
                    task_done();
                end

                `INSN_GROUP_JP: begin /* JP nn */
                    task_jump(insn_operand[15:0]);
                    task_done();
                end

                `INSN_GROUP_JP_COND: begin /* JP CC, nn */
                    case (insn[5:3])
                        0, 1: if (flag_z == insn[3]) task_jump(insn_operand[15:0]);
                        2, 3: if (flag_c == insn[3]) task_jump(insn_operand[15:0]);
                        4, 5: if (flag_pv == insn[3]) task_jump(insn_operand[15:0]);
                        6, 7: if (flag_s == insn[3]) task_jump(insn_operand[15:0]);
                    endcase
                    task_done();
                end

                `INSN_GROUP_JP_IND_HL: begin /* JP (HL) */
                    task_read_reg(1, `DD_REG_HL);
                    task_jump(reg1_rdata);
                    task_done();
                end

                `INSN_GROUP_JP_IND_IXIY: begin /* JP (IX/IY) */
                    task_read_reg(1, {`REG_SET_IDX, insn[5]});
                    task_jump(reg1_rdata);
                    task_done();
                end

                `INSN_GROUP_JR:  /* JR e */
                    case (state)
                        0: task_next_cycle_internal();
                        1: task_extend_cycle();
                        2: task_extend_cycle();
                        3: task_extend_cycle();
                        4: task_extend_cycle();
                        5: begin
                            task_jump_relative({ {8{insn_operand[7]}}, insn_operand[7:0]});
                            task_done();
                        end
                    endcase

                `INSN_GROUP_JR_COND:  /* JR CC, e */
                    case (state)
                        0: begin
                            if (z80_reg_f[insn[4] ? `FLAG_C_NUM : `FLAG_Z_NUM] == insn[3]) task_next_cycle_internal();
                            else task_done();
                        end
                        1: task_extend_cycle();
                        2: task_extend_cycle();
                        3: task_extend_cycle();
                        4: task_extend_cycle();
                        5: begin
                            task_jump_relative({ {8{insn_operand[7]}}, insn_operand[7:0]});
                            task_done();
                        end
                    endcase

                `INSN_GROUP_DJNZ:  /* DJNZ e */
                    case (state)
                        0: task_extend_cycle();
                        1: begin
                            task_read_mem(1, z80_reg_ip);
                            next_z80_reg_ip = z80_reg_ip + 1;
                        end
                        2: begin
                            task_collect_data(1);
                            task_read_reg(1, `REG_B);
                            task_alu8_op(`ALU_FUNC_SUB, reg1_rdata[7:0], 8'b1);
                            task_write_reg(`REG_B, alu8_out);
                            if (!alu8_f_out[`FLAG_Z_NUM]) task_next_cycle_internal();
                            else task_done();
                        end
                        3: task_extend_cycle();
                        4: task_extend_cycle();
                        5: task_extend_cycle();
                        6: task_extend_cycle();
                        7: begin
                            task_jump_relative({ {8{stored_data[7]}}, stored_data[7:0]});
                            task_done();
                        end
                    endcase

                `INSN_GROUP_CALL:  /* CALL nn */
                    case (state)
                        0: task_extend_cycle();
                        1: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_write_mem(1, reg1_rdata - 16'h1, next_z80_reg_ip[15:8]);
                        end
                        2: begin
                            task_write_mem_done(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_write_mem(2, reg1_rdata - 16'h2, next_z80_reg_ip[7:0]);
                            task_write_reg(`DD_REG_SP, reg1_rdata - 16'h2);
                        end
                        3: begin
                            task_write_mem_done(2);
                            task_jump(insn_operand[15:0]);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_CALL_COND:  /* CALL CC, nn */
                    case (state)
                        0: begin
                            case (insn[5:4])
                                0: if (flag_z != insn[3]) task_done();
                                   else task_extend_cycle();
                                1: if (flag_c != insn[3]) task_done();
                                   else task_extend_cycle();
                                2: if (flag_pv != insn[3]) task_done();
                                   else task_extend_cycle();
                                3: if (flag_s != insn[3]) task_done();
                                   else task_extend_cycle();
                            endcase
                        end
                        1: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_write_mem(1, reg1_rdata - 16'h1, next_z80_reg_ip[15:8]);
                        end
                        2: begin
                            task_write_mem_done(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_write_mem(2, reg1_rdata - 16'h2, next_z80_reg_ip[7:0]);
                            task_write_reg(`DD_REG_SP, reg1_rdata - 16'h2);
                        end
                        3: begin
                            task_write_mem_done(2);
                            task_jump(insn_operand[15:0]);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_RST:  /* RST p */
                    case (state)
                        0: task_extend_cycle();
                        1: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_write_mem(1, reg1_rdata - 16'h1, next_z80_reg_ip[15:8]);
                        end
                        2: begin
                            task_write_mem_done(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_write_mem(2, reg1_rdata - 16'h2, next_z80_reg_ip[7:0]);
                            task_write_reg(`DD_REG_SP, reg1_rdata - 16'h2);
                        end
                        3: begin
                            task_write_mem_done(2);
                            task_jump({8'b0, 2'b00, insn[5:3], 3'b000});
                            task_done();
                        end
                    endcase


                `INSN_GROUP_RET:  /* RET */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(2, reg1_rdata + 16'h1);
                            task_write_reg(`DD_REG_SP, reg1_rdata + 16'h2);
                        end
                        2: begin
                            task_collect_data(2);
                            task_jump(stored_data[15:0]);
                            task_done();
                        end
                    endcase

                // TODO: Hook this into interrupt signals.
                `INSN_GROUP_RETI:  /* RETI */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(2, reg1_rdata + 16'h1);
                            task_write_reg(`DD_REG_SP, reg1_rdata + 16'h2);
                        end
                        2: begin
                            task_collect_data(2);
                            task_jump(stored_data[15:0]);
                            task_done();
                        end
                    endcase

                // TODO: Hook this into interrupt signals.
                `INSN_GROUP_RETN:  /* RETN */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(2, reg1_rdata + 16'h1);
                            task_write_reg(`DD_REG_SP, reg1_rdata + 16'h2);
                        end
                        2: begin
                            task_collect_data(2);
                            task_ret_from_nmi();
                            task_jump(stored_data[15:0]);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_RET_COND:  /* RET CC */
                    case (state)
                        0: task_extend_cycle();
                        1: begin
                            case (insn[5:3])
                                0, 1: if (flag_z != insn[3])
                                    task_done();
                                2, 3: if (flag_c != insn[3])
                                    task_done();
                                4, 5: if (flag_pv != insn[3])
                                    task_done();
                                6, 7: if (flag_s != insn[3])
                                    task_done();
                            endcase
                            if (!done) begin
                                task_read_reg(1, `DD_REG_SP);
                                task_read_mem(1, reg1_rdata);
                            end
                        end
                        2: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(2, reg1_rdata + 16'h1);
                            task_write_reg(`DD_REG_SP, reg1_rdata + 16'h2);
                        end
                        3: begin
                            task_collect_data(2);
                            task_jump(stored_data[15:0]);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_EI_DI: begin  /* EI/DI */
                    if (!insn[3]) task_disable_interrupts();
                    else task_enable_interrupts();
                    task_done();
                end

                `INSN_GROUP_LD_REG_REG: begin  /* LD  r, r' */
                    task_read_reg(1, insn[2:0]);
                    task_write_reg(insn[5:3], reg1_rdata);
                    task_done();
                end

                `INSN_GROUP_LD_DD_NN: begin  /* LD  dd, nn */
                    task_write_reg({`REG_SET_DD, insn[5:4]}, insn_operand);
                    task_done();
                end

                `INSN_GROUP_LD_IXIY_NN: begin  /* LD  IX/IY, nn */
                    task_write_reg({`REG_SET_IDX, insn[5]}, insn_operand);
                    task_done();
                end

                `INSN_GROUP_LD_DD_IND_NN:  /* LD  dd, (nn) */
                    case (state)
                        0: begin
                            task_read_mem(1, insn_operand);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_mem(2, addr + 1);
                        end
                        2: begin
                            task_collect_data(2);
                            task_write_reg(
                                {`REG_SET_DD, insn[13:12]},
                                stored_data
                            );
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_IND_BCDE_A:  /* LD  (BC/DE), A */
                    case (state)
                        0: begin
                            task_read_reg(1, {`REG_SET_DD, 1'b0, insn[4]});
                            task_read_reg(2, `REG_A);
                            task_write_mem(1, reg1_rdata, reg2_rdata[7:0]);
                        end
                        1: begin
                            task_write_mem_done(1);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_A_IND_BCDE:  /* LD  A, (BC/DE)   */
                    case (state)
                        0: begin
                            task_read_reg(1, {`REG_SET_DD, 1'b0, insn[4]});
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_write_reg(`REG_A, stored_data[7:0]);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_A_IND_NN:  /* LD  A, (nn) */
                    case (state)
                        0: begin
                            task_read_mem(1, insn_operand);
                        end
                        1: begin
                            task_collect_data(1);
                            task_write_reg(`REG_A, stored_data[7:0]);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_IN_A:  /* IN  A, (n) */
                    case (state)
                        0: begin
                            task_read_reg(1, `REG_A);
                            task_read_io({reg1_rdata[7:0], insn_operand[7:0]});
                        end
                        1: begin
                            task_collect_data(1);
                            task_write_reg(`REG_A, stored_data[7:0]);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_IN_REG:  /* IN  r, (C) */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_BC);
                            task_read_io(reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_write_reg(insn[13:11], stored_data[7:0]);
                            task_write_f({
                                stored_data[7], // S
                                (stored_data[7:0] == 0), // Z
                                flag_5,
                                1'b0, // H
                                flag_3,
                                _parity8(stored_data[7:0]), // V
                                1'b0, // N
                                flag_c
                            });
                            task_done();
                        end
                    endcase

                `INSN_GROUP_OUT_A:  /* OUT (n), A */
                    case (state)
                        0: begin
                            task_read_reg(1, `REG_A);
                            task_write_io({reg1_rdata[7:0], insn_operand[7:0]}, reg1_rdata[7:0]);
                        end
                        1: begin
                            task_write_io_done();
                            task_done();
                        end
                    endcase

                `INSN_GROUP_OUT_REG:  /* OUT (C), r */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_BC);
                            task_read_reg(2, insn[13:11]);
                            task_write_io(reg1_rdata, reg2_rdata[7:0]);
                        end
                        1: begin
                            task_write_io_done();
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_IND_NN_A:  /* LD  (nn), A */
                    case (state)
                        0: begin
                            task_read_reg(1, `REG_A);
                            task_write_mem(1, insn_operand, reg1_rdata[7:0]);
                        end
                        1: begin
                            task_write_mem_done(1);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_A_I:  /* LD  A, I         */
                    case (state)
                        0: task_extend_cycle();
                        1: begin
                            task_write_f(
                                (z80_reg_f & (`FLAG_5_BIT | `FLAG_3_BIT | `FLAG_C_BIT)) |
                                (z80_reg_i == 0 ? `FLAG_Z_BIT : 0) |
                                (z80_reg_i[7] == 1 ? `FLAG_S_BIT : 0) |
                                (z80_reg_iff2 == 1 ? `FLAG_PV_BIT : 0));
                            task_write_reg(`REG_A, z80_reg_i);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_I_A:  /* LD  I, A         */
                    case (state)
                        0: task_extend_cycle();
                        1: begin
                            task_read_reg(1, `REG_A);
                            task_write_i(reg1_rdata);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_A_R:  /* LD  A, R         */
                    case (state)
                        0: task_extend_cycle();
                        1: begin
                            task_write_f(
                                (z80_reg_f & (`FLAG_5_BIT | `FLAG_3_BIT | `FLAG_C_BIT)) |
                                (z80_reg_r == 0 ? `FLAG_Z_BIT : 0) |
                                (z80_reg_r[7] == 1 ? `FLAG_S_BIT : 0) |
                                (z80_reg_iff2 == 1 ? `FLAG_PV_BIT : 0));
                            task_write_reg(`REG_A, z80_reg_r);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_R_A:  /* LD  R, A         */
                    case (state)
                        0: task_extend_cycle();
                        1: begin
                            task_read_reg(1, `REG_A);
                            task_write_r(reg1_rdata);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_REG_N: begin  /* LD  r, n */
                    task_write_reg(insn[5:3], insn_operand[7:0]);
                    task_done();
                end

                `INSN_GROUP_LD_IND_HL_N:  /* LD  (HL), n */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_write_mem(1, reg1_rdata, insn_operand[7:0]);
                        end
                        1: begin
                            task_write_mem_done(1);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_IND_HL_REG:  /* LD  (HL), r */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_reg(2, insn[2:0]);
                            task_write_mem(1, reg1_rdata, reg2_rdata[7:0]);
                        end
                        1: begin
                            task_write_mem_done(1);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_REG_IND_HL:  /* LD  r, (HL) */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_write_reg(insn[5:3], stored_data[7:0]);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_REG_IDX_IXIY:  /* LD  r, (IX/IY+d) */
                    case (state)
                        0: task_next_cycle_internal();
                        1: task_extend_cycle();
                        2: task_extend_cycle();
                        3: task_extend_cycle();
                        4: task_extend_cycle();
                        5: begin
                            task_read_reg(1, {`REG_SET_IDX, insn[5]});
                            task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                        end
                        6: begin
                            task_collect_data(1);
                            task_write_reg(insn[13:11], stored_data[7:0]);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_IDX_IXIY_N:  /* LD  (IX/IY+d), n */
                    case (state)
                        0: task_extend_cycle();
                        1: task_extend_cycle();
                        2: begin
                            task_read_reg(1, {`REG_SET_IDX, insn[5]});
                            task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]}, insn_operand[15:8]);
                        end
                        3: begin
                            task_write_mem_done(1);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_IDX_IXIY_REG:  /* LD  (IX/IY+d), r */
                    case (state)
                        0: task_next_cycle_internal();
                        1: task_extend_cycle();
                        2: task_extend_cycle();
                        3: task_extend_cycle();
                        4: task_extend_cycle();
                        5: begin
                            task_read_reg(1, {`REG_SET_IDX, insn[5]});
                            task_read_reg(2, insn[10:8]);
                            task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]}, reg2_rdata[7:0]);
                        end
                        6: begin
                            task_write_mem_done(1);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_IND_NN_DD:  /* LD  (nn), dd     */
                    case (state)
                        0: begin
                            task_read_reg(1, {`REG_SET_DD, insn[13:12]});
                            task_write_mem(1, insn_operand, reg1_rdata[7:0]);
                        end
                        1: begin
                            task_read_reg(1, {`REG_SET_DD, insn[13:12]});
                            task_write_mem_done(1);
                            task_write_mem(2, insn_operand + 1, reg1_rdata[15:8]);
                        end
                        2: begin
                            task_write_mem_done(2);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_IND_NN_HL:  /* LD  (nn), HL     */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_write_mem(1, insn_operand, reg1_rdata[7:0]);
                        end
                        1: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_write_mem_done(1);
                            task_write_mem(2, insn_operand + 1, reg1_rdata[15:8]);
                        end
                        2: begin
                            task_write_mem_done(2);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_HL_IND_NN:  /* LD  HL, (nn)     */
                    case (state)
                        0: begin
                            task_read_mem(1, insn_operand);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_mem(2, insn_operand + 1);
                        end
                        2: begin
                            task_collect_data(2);
                            task_write_reg(`DD_REG_HL, stored_data);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_SP_HL:  /* LD  SP, HL       */
                    case (state)
                        0: task_extend_cycle();
                        1: task_extend_cycle();
                        2: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_write_reg(`DD_REG_SP, reg1_rdata);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_SP_IXIY:  /* LD  SP, IX/IY    */
                    case (state)
                        0: task_extend_cycle();
                        1: task_extend_cycle();
                        2: begin
                            task_read_reg(1, {`REG_SET_IDX, insn[5]});
                            task_write_reg(`DD_REG_SP, reg1_rdata);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_IND_NN_IXIY:  /* LD  (nn), IX/IY  */
                    case (state)
                        0: begin
                            task_read_reg(1, {`REG_SET_IDX, insn[5]});
                            task_write_mem(1, insn_operand, reg1_rdata[7:0]);
                        end
                        1: begin
                            task_read_reg(1, {`REG_SET_IDX, insn[5]});
                            task_write_mem_done(1);
                            task_write_mem(2, insn_operand + 1, reg1_rdata[15:8]);
                        end
                        2: begin
                            task_write_mem_done(2);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LD_IXIY_IND_NN:  /* LD  IX/IY, (nn) */
                    case (state)
                        0: begin
                            task_read_mem(1, insn_operand);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_mem(2, insn_operand + 1);
                        end
                        2: begin
                            task_collect_data(2);
                            task_write_reg(
                                {`REG_SET_IDX, insn[5]},
                                stored_data
                            );
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LDD:  /* LDD */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_DE);
                            task_write_mem(1, reg1_rdata, stored_data[7:0]);
                        end
                        2: begin
                            task_extend_cycle();
                            task_write_mem_done(1);
                            task_block_dec();
                        end
                        3: task_extend_cycle();
                        4: task_done();
                    endcase

                `INSN_GROUP_LDI:  /* LDI */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_DE);
                            task_write_mem(1, reg1_rdata, stored_data[7:0]);
                        end
                        2: begin
                            task_extend_cycle();
                            task_write_mem_done(1);
                            task_block_inc();
                        end
                        3: task_extend_cycle();
                        4: task_done();
                    endcase

                `INSN_GROUP_LDDR:  /* LDDR */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_DE);
                            task_write_mem(1, reg1_rdata, stored_data[7:0]);
                        end
                        2: begin
                            task_extend_cycle();
                            task_write_mem_done(1);
                        end
                        3: begin
                            task_extend_cycle();
                            task_block_dec();
                        end
                        4: begin
                            if (!flag_pv) task_done();
                            else task_next_cycle_internal();
                        end
                        5: task_extend_cycle();
                        6: task_extend_cycle();
                        7: task_extend_cycle();
                        8: task_extend_cycle();
                        9: begin
                            task_jump_relative(-16'h2);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_LDIR:  /* LDIR */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_DE);
                            task_write_mem(1, reg1_rdata, stored_data[7:0]);
                        end
                        2: begin
                            task_extend_cycle();
                            task_write_mem_done(1);
                        end
                        3: begin
                            task_extend_cycle();
                            task_block_inc();
                        end
                        4: begin
                            if (!flag_pv) task_done();
                            else task_next_cycle_internal();
                        end
                        5: task_extend_cycle();
                        6: task_extend_cycle();
                        7: task_extend_cycle();
                        8: task_extend_cycle();
                        9: begin
                            task_jump_relative(-16'h2);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_CPD:  /* CPD */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_next_cycle_internal();
                            task_collect_data(1);
                        end
                        2: begin
                            task_extend_cycle();
                            task_read_reg(1, `REG_A);
                            task_alu8_compare(reg1_rdata[7:0], stored_data[7:0]);
                            // Flag C should be unaffected by the ALU.
                            task_write_f(
                                _combine_flags(z80_reg_f, alu8_f_out, `FLAG_C_BIT));
                        end
                        3: begin
                            task_extend_cycle();
                            task_compare_block_dec();
                        end
                        4: task_extend_cycle();
                        5: task_extend_cycle();
                        6: task_done();
                    endcase

                `INSN_GROUP_CPDR:  /* CPDR */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_next_cycle_internal();
                            task_collect_data(1);
                            task_read_reg(1, `REG_A);
                            task_alu8_compare(reg1_rdata[7:0], stored_data[7:0]);
                            // Flag C should be unaffected by the ALU.
                            task_write_f(
                                _combine_flags(z80_reg_f, alu8_f_out, `FLAG_C_BIT));
                        end
                        2: begin
                            task_extend_cycle();
                            task_compare_block_dec();
                        end
                        3: task_extend_cycle();
                        4: task_extend_cycle();
                        5: task_extend_cycle();
                        6: begin
                            if (!flag_pv) task_done();
                            else task_next_cycle_internal();
                        end
                        7: task_extend_cycle();
                        8: task_extend_cycle();
                        9: task_extend_cycle();
                        10: task_extend_cycle();
                        11: begin
                            task_jump_relative(-16'h2);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_CPI:  /* CPI */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_next_cycle_internal();
                            task_collect_data(1);
                        end
                        2: begin
                            task_extend_cycle();
                            task_read_reg(1, `REG_A);
                            task_alu8_compare(reg1_rdata[7:0], stored_data[7:0]);
                            // Flag C should be unaffected by the ALU.
                            task_write_f(
                                _combine_flags(z80_reg_f, alu8_f_out, `FLAG_C_BIT));
                        end
                        3: begin
                            task_extend_cycle();
                            task_compare_block_inc();
                        end
                        4: task_extend_cycle();
                        5: task_extend_cycle();
                        6: task_done();
                    endcase

                `INSN_GROUP_CPIR:  /* CPIR */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_next_cycle_internal();
                            task_collect_data(1);
                            task_read_reg(1, `REG_A);
                            task_alu8_compare(reg1_rdata[7:0], stored_data[7:0]);
                            // Flag C should be unaffected by the ALU.
                            task_write_f(
                                _combine_flags(z80_reg_f, alu8_f_out, `FLAG_C_BIT));
                        end
                        2: begin
                            task_extend_cycle();
                            task_compare_block_inc();
                        end
                        3: task_extend_cycle();
                        4: task_extend_cycle();
                        5: task_extend_cycle();
                        6: begin
                            if (!flag_pv) task_done();
                            else task_next_cycle_internal();
                        end
                        7: task_extend_cycle();
                        8: task_extend_cycle();
                        9: task_extend_cycle();
                        10: task_extend_cycle();
                        11: begin
                            task_jump_relative(-16'h2);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_IN_BLOCK:  /* INI/INIR/IND/INDR */
                    case (state)
                        0: task_extend_cycle();
                        1: begin
                            task_read_reg(1, `DD_REG_BC);
                            task_read_io(reg1_rdata);
                        end
                        2: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_HL);
                            task_write_mem(1, reg1_rdata, stored_data[7:0]);
                            task_alu16_op(
                                insn[11] ? `ALU_FUNC_SUB : `ALU_FUNC_ADD,
                                reg1_rdata, 1);
                            task_write_reg(`DD_REG_HL, alu16_out);
                        end
                        3: begin
                            task_write_mem_done(1);
                            task_read_reg(1, `REG_B);
                            task_alu8_op(`ALU_FUNC_SUB, reg1_rdata[7:0], 1);
                            task_write_reg(`REG_B, alu8_out);
                            // Flags: the undocumented document claims a
                            // weird formula for H, P, N, and C. It also
                            // contradicts the documented values for N (1)
                            // and C (unaffected). So for now we'll just
                            // set H and P to zero until we can verify what's
                            // going on.
                            task_write_f({
                                alu8_out[7], // S ("unknown")
                                alu8_out == 0, // Z
                                flag_5,
                                1'b0, // H ("unknown")
                                flag_3,
                                // Same
                                1'b0, // P ("unknown")
                                1'b1, // N
                                flag_c
                            });
                            if (insn[12] && alu8_out == 0) task_next_cycle_internal();
                            else task_done();
                        end
                        4: task_extend_cycle();
                        5: task_extend_cycle();
                        6: task_extend_cycle();
                        7: task_extend_cycle();
                        8: begin
                            task_jump_relative(-16'h2);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_OUT_BLOCK:  /* OUTI/OTIR/OUTD/OTDR */
                    case (state)
                        0: task_extend_cycle();
                        1: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        2: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_HL);
                            task_read_reg(2, `DD_REG_BC);
                            task_write_io(reg2_rdata, stored_data[7:0]);
                            task_alu16_op(
                                insn[11] ? `ALU_FUNC_SUB : `ALU_FUNC_ADD,
                                reg1_rdata, 1);
                            task_write_reg(`DD_REG_HL, alu16_out);
                        end
                        3: begin
                            task_write_io_done(1);
                            task_read_reg(1, `REG_B);
                            task_alu8_op(`ALU_FUNC_SUB, reg1_rdata[7:0], 1);
                            task_write_reg(`REG_B, alu8_out);
                            // Flags: the undocumented document claims a
                            // weird formula for H, P, N, and C. It also
                            // contradicts the documented values for N (1)
                            // and C (unaffected). So for now we'll just
                            // set H and P to zero until we can verify what's
                            // going on.
                            task_write_f({
                                alu8_out[7], // S ("unknown")
                                alu8_out == 0, // Z
                                flag_5,
                                1'b0, // H ("unknown")
                                flag_3,
                                // Same
                                1'b0, // P ("unknown")
                                1'b1, // N
                                flag_c
                            });
                            if (insn[12] && alu8_out == 0) task_next_cycle_internal();
                            else task_done();
                        end
                        4: task_extend_cycle();
                        5: task_extend_cycle();
                        6: task_extend_cycle();
                        7: task_extend_cycle();
                        8: begin
                            task_jump_relative(-16'h2);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_POP_QQ:  /* POP qq */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(2, reg1_rdata + 16'h1);
                            task_write_reg(`DD_REG_SP, reg1_rdata + 16'h2);
                        end
                        2: begin
                            task_collect_data(2);
                            task_write_reg({`REG_SET_QQ, insn[5:4]}, stored_data);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_POP_IXIY:  /* POP IX/IY */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(2, reg1_rdata + 16'h1);
                            task_write_reg(`DD_REG_SP, reg1_rdata + 16'h2);
                        end
                        2: begin
                            task_collect_data(2);
                            task_write_reg({`REG_SET_IDX, insn[5]}, stored_data);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_PUSH_QQ:  /* PUSH qq */
                    case (state)
                        0: task_extend_cycle();
                        1: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_read_reg(2, {`REG_SET_QQ, insn[5:4]});
                            task_write_mem(1, reg1_rdata - 16'h1, reg2_rdata[15:8]);
                        end
                        2: begin
                            task_write_mem_done(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_read_reg(2, {`REG_SET_QQ, insn[5:4]});
                            task_write_mem(2, reg1_rdata - 16'h2, reg2_rdata[7:0]);
                        end
                        3: begin
                            task_write_mem_done(2);
                            task_read_reg(1, `DD_REG_SP);
                            task_write_reg(`DD_REG_SP, reg1_rdata - 16'h2);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_PUSH_IXIY:  /* PUSH IX/IY */
                    case (state)
                        0: task_extend_cycle();
                        1: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_read_reg(2, {`REG_SET_IDX, insn[5]});
                            task_write_mem(1, reg1_rdata - 16'h1, reg2_rdata[15:8]);
                        end
                        2: begin
                            task_write_mem_done(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_read_reg(2, {`REG_SET_IDX, insn[5]});
                            task_write_mem(2, reg1_rdata - 16'h2, reg2_rdata[7:0]);
                        end
                        3: begin
                            task_write_mem_done(2);
                            task_read_reg(1, `DD_REG_SP);
                            task_write_reg(`DD_REG_SP, reg1_rdata - 16'h2);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_EX_DE_HL: begin /* EX DE, HL */
                    task_ex_de_hl();
                    task_done();
                end

                `INSN_GROUP_EX_AF_AF2: begin /* EX AF, AF2 */
                    task_ex_af_af2();
                    task_done();
                end

                `INSN_GROUP_EXX: begin /* EXX */
                    task_exx();
                    task_done();
                end

                `INSN_GROUP_EX_IND_SP_HL:  /* EX (SP), HL */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(2, reg1_rdata + 1);
                        end
                        2: begin
                            task_extend_cycle();
                            task_collect_data(2);
                        end
                        3: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_read_reg(2, `DD_REG_HL);
                            task_write_mem(1, reg1_rdata + 1, reg2_rdata[15:8]);
                        end
                        4: begin
                            task_write_mem_done(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_read_reg(2, `DD_REG_HL);
                            task_write_mem(1, reg1_rdata, reg2_rdata[7:0]);
                        end
                        5: begin
                            task_write_mem_done(2);
                            task_extend_cycle();
                        end
                        6: task_extend_cycle();
                        7: begin
                            task_write_reg(`DD_REG_HL, stored_data);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_EX_IND_SP_IXIY:  /* EX (SP), IX/IY */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_read_mem(2, reg1_rdata + 1);
                        end
                        2: begin
                            task_extend_cycle();
                            task_collect_data(2);
                        end
                        3: begin
                            task_read_reg(1, `DD_REG_SP);
                            task_read_reg(2, {`REG_SET_IDX, insn[5]});
                            task_write_mem(1, reg1_rdata + 1, reg2_rdata[15:8]);
                        end
                        4: begin
                            task_write_mem_done(1);
                            task_read_reg(1, `DD_REG_SP);
                            task_read_reg(2, {`REG_SET_IDX, insn[5]});
                            task_write_mem(1, reg1_rdata, reg2_rdata[7:0]);
                        end
                        5: begin
                            task_write_mem_done(2);
                            task_extend_cycle();
                        end
                        6: task_extend_cycle();
                        7: begin
                            task_write_reg({`REG_SET_IDX, insn[5]}, stored_data);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_ALU_A_REG:  /* ADD/ADC/SUB/SBC/AND/XOR/OR/CP A, r */
                    case (state)
                        0: begin
                            task_read_reg(1, `REG_A);
                            task_read_reg(2, insn[2:0]);
                            task_alu8_op(insn[5:3], reg1_rdata[7:0], reg2_rdata[7:0]);
                            if (insn[5:3] != `ALU_FUNC_CP) task_write_reg(`REG_A, alu8_out);
                            task_write_f(alu8_f_out);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_INC_DEC_REG:  /* INC/DEC r */
                    case (state)
                        0: begin
                            task_read_reg(1, insn[5:3]);
                            task_alu8_op(insn[0] ? `ALU_FUNC_SUB : `ALU_FUNC_ADD, reg1_rdata[7:0], 8'b1);
                            task_write_reg(insn[5:3], alu8_out);
                            // Flag C is not affected.
                            task_write_f(_combine_flags(z80_reg_f, alu8_f_out, `FLAG_C_BIT));
                            task_done();
                        end
                    endcase

                `INSN_GROUP_INC_DEC_DD:  /* INC/DEC dd */
                    case (state)
                        0: begin
                            task_read_reg(1, {`REG_SET_DD, insn[5:4]});
                            task_alu16_op(insn[3] ? `ALU_FUNC_SUB : `ALU_FUNC_ADD, reg1_rdata, 8'b1);
                            task_write_reg({`REG_SET_DD, insn[5:4]}, alu16_out);
                            task_extend_cycle();
                        end
                        1: task_extend_cycle();
                        2: task_done();
                    endcase

                `INSN_GROUP_INC_DEC_IXIY:  /* INC/DEC IX/IY */
                    case (state)
                        0: begin
                            task_read_reg(1, {`REG_SET_IDX, insn[5]});
                            task_alu16_op(insn[11] ? `ALU_FUNC_SUB : `ALU_FUNC_ADD, reg1_rdata, 8'b1);
                            task_write_reg({`REG_SET_IDX, insn[5]}, alu16_out);
                            task_extend_cycle();
                        end
                        1: task_extend_cycle();
                        2: task_done();
                    endcase

                `INSN_GROUP_ALU_A_N:  /* ADD/ADC/SUB/SBC/AND/XOR/OR/CP A, n */
                    case (state)
                        0: begin
                            task_read_reg(1, `REG_A);
                            task_alu8_op(insn[5:3], reg1_rdata[7:0], insn_operand[7:0]);
                            if (insn[5:3] != `ALU_FUNC_CP) task_write_reg(`REG_A, alu8_out);
                            task_write_f(alu8_f_out);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_ALU_A_IND_HL:  /* ADD/ADC/SUB/SBC/AND/XOR/OR/CP A, (HL) */
                    case (state)
                        0: begin
                            task_read_reg(2, `DD_REG_HL);
                            task_read_mem(1, reg2_rdata);
                        end
                        1: begin
                            task_collect_data(1);
                            task_read_reg(1, `REG_A);
                            task_alu8_op(insn[5:3], reg1_rdata[7:0], stored_data[7:0]);
                            if (insn[5:3] != `ALU_FUNC_CP) task_write_reg(`REG_A, alu8_out);
                            task_write_f(alu8_f_out);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_INC_DEC_IND_HL:  /* INC/DEC (HL) */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_extend_cycle();
                            task_collect_data(1);
                        end
                        2: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_alu8_op(insn[0] ? `ALU_FUNC_ADD : `ALU_FUNC_SUB, stored_data[7:0], 8'b1);
                            task_write_mem(1, reg1_rdata, alu8_out);
                            // Flag C is not affected.
                            task_write_f(_combine_flags(z80_reg_f, alu8_f_out, `FLAG_C_BIT));
                        end
                        3: begin
                            task_write_mem_done(1);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_ALU_A_IDX_IXIY:  /* ADD/ADC/SUB/SBC/AND/XOR/OR/CP A, (IX/IY + d) */
                    case (state)
                        0: task_next_cycle_internal();
                        1: task_extend_cycle();
                        2: task_extend_cycle();
                        3: task_extend_cycle();
                        4: task_extend_cycle();
                        5: begin
                            task_read_reg(2, {`REG_SET_IDX, insn[5]});
                            task_read_mem(1, reg2_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                        end
                        6: begin
                            task_collect_data(1);
                            task_read_reg(1, `REG_A);
                            task_alu8_op(insn[13:11], reg1_rdata[7:0], stored_data[7:0]);
                            if (insn[13:11] != `ALU_FUNC_CP) task_write_reg(`REG_A, alu8_out);
                            task_write_f(alu8_f_out);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_INC_DEC_IDX_IXIY:  /* INC/DEC (IX/IY + d) */
                    case (state)
                        0: task_next_cycle_internal();
                        1: task_extend_cycle();
                        2: task_extend_cycle();
                        3: task_extend_cycle();
                        4: task_extend_cycle();
                        5: begin
                            task_read_reg(1, {`REG_SET_IDX, insn[5]});
                            task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                        end
                        6: begin
                            task_extend_cycle();
                            task_collect_data(1);
                        end
                        7: begin
                            task_read_reg(1, {`REG_SET_IDX, insn[5]});
                            task_alu8_op(insn[8] ? `ALU_FUNC_ADD : `ALU_FUNC_SUB, stored_data[7:0], 8'b1);
                            task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]}, alu8_out);
                            // Flag C is not affected.
                            task_write_f(_combine_flags(z80_reg_f, alu8_f_out, `FLAG_C_BIT));
                        end
                        8: begin
                            task_write_mem_done(1);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_ADD_HL_DD:  /* ADD HL, dd */
                    case (state)
                        0: task_next_cycle_internal();
                        1: task_extend_cycle();
                        2: task_extend_cycle();
                        3: task_extend_cycle();
                        4: task_next_cycle_internal();
                        5: task_extend_cycle();
                        6: task_extend_cycle();
                        7: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_reg(2, {`REG_SET_DD, insn[5:4]});
                            task_alu16_op(`ALU_FUNC_ADD, reg1_rdata, reg2_rdata);
                            // N is reset, and only H and C are used.
                            task_write_f(`FLAG_N_MASK &
                                _combine_flags(alu16_f_out, z80_reg_f,
                                    `FLAG_H_BIT | `FLAG_C_BIT));
                            task_write_reg(`DD_REG_HL, alu16_out);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_ADD_IXIY_SS:  /* ADD IX/IY, ss */
                    case (state)
                        0: task_next_cycle_internal();
                        1: task_extend_cycle();
                        2: task_extend_cycle();
                        3: task_extend_cycle();
                        4: task_next_cycle_internal();
                        5: task_extend_cycle();
                        6: task_extend_cycle();
                        7: begin
                            task_read_reg(1, insn[5] ? `IDX_REG_IY : `IDX_REG_IX);
                            if (insn[13:12] == `REG_HL)
                                task_read_reg(2, insn[5] ? `IDX_REG_IY : `IDX_REG_IX);
                            else
                                task_read_reg(2, {`REG_SET_DD, insn[13:12]});
                            task_alu16_op(`ALU_FUNC_ADD, reg1_rdata, reg2_rdata);
                            // N is reset, and only H and C are used.
                            task_write_f(`FLAG_N_MASK &
                                _combine_flags(alu16_f_out, z80_reg_f,
                                    `FLAG_H_BIT | `FLAG_C_BIT));
                            task_write_reg(insn[5] ? `IDX_REG_IY : `IDX_REG_IX, alu16_out);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_ADC_SBC_HL_DD:  /* ADC/SBC HL, dd */
                    case (state)
                        0: task_next_cycle_internal();
                        1: task_extend_cycle();
                        2: task_extend_cycle();
                        3: task_extend_cycle();
                        4: task_next_cycle_internal();
                        5: task_extend_cycle();
                        6: task_extend_cycle();
                        7: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_reg(2, {`REG_SET_DD, insn[13:12]});
                            task_alu16_op(insn[11] ? `ALU_FUNC_ADC : `ALU_FUNC_SBC, reg1_rdata, reg2_rdata);
                            task_write_f(alu16_f_out);
                            task_write_reg(`DD_REG_HL, alu16_out);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_DAA: begin  /* DAA */
                    task_read_reg(1, `REG_A);
                    task_alu8_op(z80_reg_f[`FLAG_N_NUM] ? `ALU_FUNC_SUB : `ALU_FUNC_ADD,
                        reg1_rdata,
                        _daa_adjustment(flag_c, z80_reg_f[`FLAG_H_NUM], reg1_rdata));
                    task_write_reg(`REG_A, alu8_out);
                    // Flag PV is parity, not overflow.
                    task_write_f(
                        _combine_flags(_parity8(alu8_out) ? `FLAG_PV_BIT : 0,
                            alu8_f_out, `FLAG_PV_BIT));
                    task_done();
                end

                `INSN_GROUP_CPL: begin  /* CPL */
                    task_read_reg(1, `REG_A);
                    task_write_reg(`REG_A, ~reg1_rdata);
                    task_write_f(_combine_flags(
                        `FLAG_H_BIT | `FLAG_N_BIT, z80_reg_f,
                        `FLAG_H_BIT | `FLAG_N_BIT));
                    task_done();
                end

                `INSN_GROUP_NEG: begin  /* NEG */
                    task_read_reg(1, `REG_A);
                    task_alu8_op(`ALU_FUNC_SUB, 8'b0, reg1_rdata);
                    task_write_reg(`REG_A, alu8_out);
                    task_write_f(alu8_f_out);
                    task_done();
                end

                `INSN_GROUP_CCF: begin  /* CCF */
                    task_write_f({
                        z80_reg_f[7], // s
                        z80_reg_f[6], // z
                        z80_reg_f[5], // 5
                        z80_reg_f[0], // h (original c)
                        z80_reg_f[3], // 3
                        z80_reg_f[2], // v
                        1'b0,       // n
                        ~z80_reg_f[0] // c (complemented c)
                        });
                    task_done();
                end

                `INSN_GROUP_SCF: begin  /* SCF */
                    task_write_f({
                        z80_reg_f[7], // s
                        z80_reg_f[6], // z
                        z80_reg_f[5], // 5
                        1'b0,       // h
                        z80_reg_f[3], // 3
                        z80_reg_f[2], // v
                        1'b0,       // n
                        1'b1        // c
                        });
                    task_done();
                end

                `INSN_GROUP_RR_RLCA: begin  /* RLCA/RLC/RRCA/RRA */
                    task_read_reg(1, `REG_A);
                    task_alu8_op(
                        {`ALU_ROT, insn[4:3]},
                        reg1_rdata,
                        0);
                    task_write_f(`FLAG_H_MASK & `FLAG_N_MASK &
                        _combine_flags(alu8_f_out, z80_reg_f, `FLAG_C_BIT));
                    task_write_reg(`REG_A, alu8_out);
                    task_done();
                end

                `INSN_GROUP_RR_RLC_REG: begin  /* RLCA/RLC/RRCA/RRA r */
                    task_read_reg(1, insn[10:8]);
                    task_alu8_op(
                        {`ALU_ROT, insn[12:11]},
                        reg1_rdata,
                        0);
                    task_write_f(`FLAG_H_MASK & `FLAG_N_MASK & alu8_f_out);
                    task_write_reg(insn[10:8], alu8_out);
                    task_done();
                end

                `INSN_GROUP_RR_RLC_IND_HL:  /* RLCA/RLC/RRCA/RRA (HL) */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_extend_cycle();
                            task_collect_data(1);
                        end
                        2: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_alu8_op(
                                {`ALU_ROT, insn[12:11]},
                                stored_data[7:0],
                                0);
                            task_write_f(`FLAG_H_MASK & `FLAG_N_MASK & alu8_f_out);
                            task_write_mem(1, reg1_rdata, alu8_out);
                        end
                        3: begin
                            task_write_mem_done(1);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_SHIFT_REG: begin  /* SRA/SRL/SLA r */
                    task_read_reg(1, insn[10:8]);
                    task_alu8_op(
                        {`ALU_SHIFT, insn[12:11]},
                        reg1_rdata,
                        0);
                    task_write_f(`FLAG_H_MASK & `FLAG_N_MASK & alu8_f_out);
                    task_write_reg(insn[10:8], alu8_out);
                    task_done();
                end

                `INSN_GROUP_SHIFT_IND_HL:  /* SRA/SRL/SLA (HL) */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_extend_cycle();
                            task_collect_data(1);
                        end
                        2: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_alu8_op(
                                {`ALU_SHIFT, insn[12:11]},
                                stored_data[7:0],
                                0);
                            task_write_f(`FLAG_H_MASK & `FLAG_N_MASK & alu8_f_out);
                            task_write_mem(1, reg1_rdata, alu8_out);
                        end
                        3: begin
                            task_write_mem_done(1);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_ROT_DEC:  /* RRD/RLD */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_next_cycle_internal();
                            task_collect_data(1);
                        end
                        2: task_extend_cycle();
                        3: task_extend_cycle();
                        4: task_extend_cycle();
                        5: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_reg(2, `REG_A);
                            task_rotate_decimal(insn[11],
                                reg2_rdata[7:0], stored_data[7:0],
                                reg1_rdata);
                        end
                        6: begin
                            task_write_mem_done(1);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_BIT_REG: begin  /* BIT b, r */
                    task_read_reg(1, insn[10:8]);
                    task_write_f({
                        // Undocumented value of S flag:
                        // Set if bit = 7 and bit 7 in r is set.
                        insn[13:11] == 3'b111 && reg1_rdata[7] == 1'b1, // S ("unknown")
                        ~reg1_rdata[insn[13:11]], // Z
                        flag_5,
                        1'b1, // H
                        flag_3,
                        // Undocumented value of PV flag: Same as Z.
                        ~reg1_rdata[insn[13:11]],  // PV ("unknown")
                        1'b0, // N
                        flag_c
                    });
                    task_done();
                    end

                `INSN_GROUP_BIT_IND_HL:  /* BIT b, (HL) */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_extend_cycle();
                            task_collect_data(1);
                        end
                        2: begin
                            task_write_f({
                                // Undocumented value of S flag:
                                // Set if bit = 7 and bit 7 in r is set.
                                insn[13:11] == 3'b111 && stored_data[7] == 1'b1, // S ("unknown")
                                ~stored_data[insn[13:11]], // Z
                                flag_5,
                                1'b1, // H
                                flag_3,
                                // Undocumented value of PV flag: Same as Z.
                                ~stored_data[insn[13:11]],  // PV ("unknown")
                                1'b0, // N
                                flag_c
                            });
                            task_done();
                        end
                    endcase

                `INSN_GROUP_SET_REG: begin  /* SET b, r */
                    task_read_reg(1, insn[10:8]);
                    task_write_reg(insn[10:8],
                        reg1_rdata | (8'b1 << insn[13:11]));
                    task_done();
                    end

                `INSN_GROUP_SET_IND_HL:  /* SET b, (HL) */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_extend_cycle();
                            task_collect_data(1);
                        end
                        2: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_write_mem(1, reg1_rdata,
                                stored_data[7:0] | (8'b1 << insn[13:11]));
                        end
                        3: begin
                            task_write_mem_done(1);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_RES_REG: begin  /* RES b, r */
                    task_read_reg(1, insn[10:8]);
                    task_write_reg(insn[10:8],
                        reg1_rdata & ~(8'b1 << insn[13:11]));
                    task_done();
                    end

                `INSN_GROUP_RES_IND_HL:  /* RES b, (HL) */
                    case (state)
                        0: begin
                            task_read_reg(1, `DD_REG_HL);
                            task_read_mem(1, reg1_rdata);
                        end
                        1: begin
                            task_extend_cycle();
                            task_collect_data(1);
                        end
                        2: begin
                            task_collect_data(1);
                            task_read_reg(1, `DD_REG_HL);
                            task_write_mem(1, reg1_rdata,
                                stored_data[7:0] & ~(8'b1 << insn[13:11]));
                        end
                        3: begin
                            task_write_mem_done(1);
                            task_done();
                        end
                    endcase

                `INSN_GROUP_IDX_IXIY_BITS:
                    // Handles all the DDCB / FDCB instructions
                    handle_ixiy_bits_group(ixiy_bits_group);

                default: begin // For illegal instructions, just assume done
                    task_done();
                end
            endcase /* decoded_group */
        end /* have enough insn bytes */

        if (done) begin
            next_addr = next_z80_reg_ip;
        end

    end /* if !reset */

end


`ifdef SEQUENCER_FORMAL

logic [3:0] int_commands;
logic [6:0] reg_commands;
logic [3:0] rdwr;
logic [4:0] flag_wr_commands;
assign int_commands = {enable_interrupts, disable_interrupts, accept_nmi, ret_from_nmi};
assign reg_commands = {reg_wr, block_inc, block_dec, ex_de_hl, ex_af_af2, exx};
assign rdwr = {mem_rd, mem_wr, io_rd, io_wr};
assign flag_wr_commands = {f_wr, block_inc, block_dec, ex_af_af2, (reg_wr && (reg_wnum == `QQ_REG_AF))};

always @(*) begin
        if (insn_len >= 1) assume (op_len >= 1 && op_len <= insn_len);
        // assert(!(mem_wr && mem_rd)); // yeah don't do that
        // assert(!(io_wr && io_rd));
        // assert(!((mem_wr || mem_rd) && (io_wr || io_rd)));
        assert(rdwr == (rdwr & -rdwr)); // zero or one of the set
        assert(int_commands == (int_commands & -int_commands)); // zero or one of the set
        assert(reg_commands == (reg_commands & -reg_commands));
        assert(flag_wr_commands == (flag_wr_commands & -flag_wr_commands));
        if (block_compare) assert(block_inc || block_dec);
end

`endif

endmodule

`endif // _sequencer_program_sv_
