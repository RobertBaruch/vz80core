`ifndef _sequencer_sv_
`define _sequencer_sv_

`include "z80.vh"
`include "z80fi.vh"
`include "registers.sv"
`include "ir_registers.sv"
`include "alu.sv"
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

logic gated_iff1;
logic gated_iff2;
logic delayed_enable_interrupts;
assign gated_iff1 = z80_reg_iff1 & !reset & !disable_interrupts & !enable_interrupts & !delayed_enable_interrupts;
assign gated_iff2 = z80_reg_iff2 & !reset & !disable_interrupts & !enable_interrupts & !delayed_enable_interrupts;

logic [7:0] mem_rdata;
logic [7:0] mem_wdata;
logic mem_wr;
logic mem_rd;

assign mem_rdata = mem_data;
assign write_data = mem_wdata;
assign write_mem = mem_wr;
assign read_mem = mem_rd;

logic `reg_select reg_wnum;
logic `reg_select reg1_rnum;
logic `reg_select reg2_rnum;
logic [15:0] reg_wdata;
logic [15:0] reg1_rdata;
logic [15:0] reg2_rdata;
logic reg_wr;
logic [7:0] f_rdata;
logic [7:0] f_wdata;
logic f_wr;
logic block_inc;
logic block_dec;
logic block_compare;
logic ex_de_hl;
logic ex_af_af2;
logic exx;

logic flag_s;
logic flag_z;
logic flag_5;
logic flag_h;
logic flag_3;
logic flag_pv;
logic flag_n;
logic flag_c;

assign flag_s  = f_rdata[7];
assign flag_z  = f_rdata[6];
assign flag_5  = f_rdata[5];
assign flag_h  = f_rdata[4];
assign flag_3  = f_rdata[3];
assign flag_pv = f_rdata[2];
assign flag_n  = f_rdata[1];
assign flag_c  = f_rdata[0];

logic i_wr;
logic [7:0] i_wdata;
logic r_wr;
logic [7:0] r_wdata;
logic [7:0] z80_reg_i;
logic [7:0] z80_reg_r;
logic z80_reg_iff1;
logic z80_reg_iff2;
logic enable_interrupts;
logic disable_interrupts;
logic accept_nmi;
logic ret_from_nmi;

logic [2:0] decoded_len;
logic [7:0] decoded_group;

//
// State variables
//

// collected_insn represents the entire instruction, little-endian.
// Maximum 4 bytes. Ex: LD IY, (AABB) -> AA BB 2A FD.
// The op is just that part of the instruction needed to
// decode the operation. Ex: LD IY, (AABB) -> 2A FD.
logic [31:0] collected_insn;
logic [2:0] collected_insn_len;
logic collected_insn_ready;
logic collected_op_ready;
logic [1:0] collected_op_len;

logic [15:0] collected_data;
logic collected_data_ready;
logic [1:0] collected_data_len;

logic [15:0] z80_reg_ip;

logic [3:0] state;

//
// Next state variables
//

logic next_done;
logic [15:0] next_addr;
logic next_mem_rd;
logic next_mem_wr;
logic [7:0] next_mem_wdata;

logic [31:0] next_collected_insn;
logic [2:0] next_collected_insn_len;
logic next_collected_insn_ready;
logic next_collected_op_ready;
logic [1:0] next_collected_op_len;

logic [15:0] next_collected_data;
logic next_collected_data_ready;
logic [1:0] next_collected_data_len;

logic [15:0] next_z80_reg_ip;

logic [3:0] next_state;

//
// State update
//

always @(posedge clk or posedge reset) begin
    if (reset) begin
        done <= 0;
        addr <= 0;
        mem_rd <= 1;
        mem_wr <= 0;
        mem_wdata <= 0;

        collected_insn <= 0;
        collected_insn_len <= 0;
        collected_insn_ready <= 0;
        collected_op_ready <= 0;
        collected_op_len <= 0;

        collected_data <= 0;
        collected_data_ready <= 0;
        collected_data_len <= 0;

        z80_reg_ip <= 0;

        state <= 0;

        `ifdef Z80_FORMAL
            `Z80FI_RESET_STATE
        `endif
    end else begin
        done <= next_done;
        addr <= next_addr;
        mem_rd <= next_mem_rd;
        mem_wr <= next_mem_wr;
        mem_wdata <= next_mem_wdata;

        collected_insn <= next_collected_insn;
        collected_insn_len <= next_collected_insn_len;
        collected_insn_ready <= next_collected_insn_ready;
        collected_op_ready <= next_collected_op_ready;
        collected_op_len <= next_collected_op_len;

        collected_data <= next_collected_data;
        collected_data_ready <= next_collected_data_ready;
        collected_data_len <= next_collected_data_len;

        z80_reg_ip <= next_z80_reg_ip;

        state <= next_state;

        `ifdef Z80_FORMAL
            `Z80FI_LOAD_NEXT_STATE
        `endif
    end
end

`ifdef Z80_FORMAL
    `Z80FI_NEXT_STATE
    `Z80FI_REG_ASSIGN
`endif

registers registers(
    .reset(reset),
    .clk(clk),

    .write_en(reg_wr),
    .dest(reg_wnum),
    .in(reg_wdata),

    .src1(reg1_rnum),
    .out1(reg1_rdata),

    .src2(reg2_rnum),
    .out2(reg2_rdata),

    .reg_f(f_rdata),
    .f_in(f_wdata),
    .f_wr(f_wr),

    .block_inc(block_inc),
    .block_dec(block_dec),
    .block_compare(block_compare),

    .ex_de_hl(ex_de_hl),
    .ex_af_af2(ex_af_af2),
    .exx(exx)

`ifdef Z80_FORMAL
    ,
    `Z80_REGS_CONN
`endif
);

ir_registers ir_registers(
    .reset(reset),
    .clk(clk),

    .i_wr(i_wr),
    .i_in(i_wdata),
    .r_wr(r_wr),
    .r_in(r_wdata),

    .reg_i(z80_reg_i),
    .reg_r(z80_reg_r),
    .enable_interrupts(enable_interrupts),
    .disable_interrupts(disable_interrupts),
    .accept_nmi(accept_nmi),
    .ret_from_nmi(ret_from_nmi),
    .next_insn_done(next_done),

    .iff1(z80_reg_iff1),
    .iff2(z80_reg_iff2),
    .delayed_enable_interrupts(delayed_enable_interrupts)
);

logic [7:0] alu8_x;
logic [7:0] alu8_y;
logic [7:0] alu8_out;
logic [7:0] alu8_f_out;
logic [3:0] alu8_func;

alu8 alu8(
    .x(alu8_x),
    .y(alu8_y),
    .func(alu8_func),
    .f_in(f_rdata),
    .out(alu8_out),
    .f(alu8_f_out)
);

logic [15:0] alu16_x;
logic [15:0] alu16_y;
logic [3:0] alu16_func;
logic [7:0] alu16_f_out;
logic [15:0] alu16_out;

alu16 alu16(
    .x(alu16_x),
    .y(alu16_y),
    .func(alu16_func),
    .f_in(f_rdata),
    .out(alu16_out),
    .f(alu16_f_out)
);

logic [31:0] instr_for_decoder;
logic [1:0] op_len_for_decoder;
logic [2:0] insn_len_for_sequencer;
logic [15:0] insn_operand;

instr_decoder instr_decoder(
    .instr(instr_for_decoder),
    .op_len(op_len_for_decoder),
    .len(decoded_len),
    .group(decoded_group)
);

`include "sequencer_tasks.vh"

logic [7:0] ixiy_bits_group;
instr_ixiy_bits_decoder ixiy_bits_decoder(
    .instr(instr_for_decoder[31:24]),
    .group(ixiy_bits_group)
);

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
                0: begin
                    task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                    task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                end
                1: begin
                    task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                    task_collect_data(1);
                    task_alu8_op(
                        {`ALU_ROT, instr_for_decoder[28:27]},
                        next_collected_data[7:0],
                        0);
                    task_write_f(`FLAG_H_MASK & `FLAG_N_MASK & alu8_f_out);
                    task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]}, alu8_out);
                end
                2: begin
                    task_write_mem_done(1);
                    task_done();
                end
            endcase

        `INSN_GROUP_SHIFT_IDX_IXIY: /* SRA/SRL/SLA (IX/IY + d) */
            case (state)
                0: begin
                    task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                    task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                end
                1: begin
                    task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                    task_collect_data(1);
                    task_alu8_op(
                        {`ALU_SHIFT, instr_for_decoder[28:27]},
                        next_collected_data[7:0],
                        0);
                    task_write_f(`FLAG_H_MASK & `FLAG_N_MASK & alu8_f_out);
                    task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]}, alu8_out);
                end
                2: begin
                    task_write_mem_done(1);
                    task_done();
                end
            endcase

        `INSN_GROUP_BIT_IDX_IXIY: /* BIT b, (IX/IY + d) */
            case (state)
                0: begin
                    task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                    task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                end
                1: begin
                    task_collect_data(1);
                    task_write_f({
                        // Undocumented value of S flag:
                        // Set if bit = 7 and bit 7 in r is set.
                        instr_for_decoder[29:27] == 3'b111 && next_collected_data[7] == 1'b1, // S ("unknown")
                        ~next_collected_data[instr_for_decoder[29:27]], // Z
                        f_rdata[`FLAG_5_NUM],
                        1'b1, // H
                        f_rdata[`FLAG_3_NUM],
                        // Undocumented value of PV flag: Same as Z.
                        ~next_collected_data[instr_for_decoder[29:27]],  // PV ("unknown")
                        1'b0, // N
                        f_rdata[`FLAG_C_NUM]
                    });
                    task_done();
                end
            endcase

        `INSN_GROUP_SET_IDX_IXIY: /* SET b, (IX/IY + d) */
            case (state)
                0: begin
                    task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                    task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                end
                1: begin
                    task_collect_data(1);
                    task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                    task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]},
                        next_collected_data[7:0] | (8'b1 << instr_for_decoder[29:27]));
                end
                2: begin
                    task_write_mem_done(1);
                    task_done();
                end
            endcase

        `INSN_GROUP_RES_IDX_IXIY: /* RES b, (IX/IY + d) */
            case (state)
                0: begin
                    task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                    task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                end
                1: begin
                    task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                    task_collect_data(1);
                    task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]},
                        next_collected_data[7:0] & ~(8'b1 << instr_for_decoder[29:27]));
                end
                2: begin
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
    if (reset || done) begin
        `ifdef Z80_FORMAL
            `Z80FI_INIT_NEXT_STATE
            next_z80fi_reg_ip_in = addr;
        `endif
    end else begin
        `ifdef Z80_FORMAL
            `Z80FI_RETAIN_NEXT_STATE
        `endif
    end

    next_done = 0;
    next_state = state;
    next_z80fi_valid = 0;

    next_mem_wr = 0;
    next_mem_wdata = 0;

    reg1_rnum = 0;
    reg2_rnum = 0;
    reg_wr = 0;
    reg_wnum = 0;
    reg_wdata = 0;
    block_inc = 0;
    block_dec = 0;
    block_compare = 0;
    ex_de_hl = 0;
    ex_af_af2 = 0;
    exx = 0;

    i_wr = 0;
    i_wdata = 0;
    r_wr = 0;
    r_wdata = 0;
    f_wr = 0;
    f_wdata = 0;
    enable_interrupts = 0;
    disable_interrupts = reset;
    accept_nmi = 0;
    ret_from_nmi = 0;

    alu8_x = 0;
    alu8_y = 0;
    alu8_func = 0;
    alu16_x = 0;
    alu16_y = 0;
    alu16_func = 0;

    next_collected_insn_len = 0;
    next_collected_insn = 0;
    next_collected_insn_ready = 0;
    next_collected_op_len = 0;
    next_collected_op_ready = 0;
    next_collected_data = collected_data;

        next_addr = addr;
        next_z80_reg_ip = z80_reg_ip;
        next_mem_rd = 0;

        // This part collects all the bytes for the current instruction.
        if (collected_insn_ready) begin
            instr_for_decoder = collected_insn;
        end else begin
            case (collected_insn_len)
                0: instr_for_decoder = {24'b0, mem_rdata};
                1: instr_for_decoder = {16'b0, mem_rdata, collected_insn[7:0]};
                2: instr_for_decoder = {8'b0, mem_rdata, collected_insn[15:0]};
                3: instr_for_decoder = {mem_rdata, collected_insn[23:0]};
                default: instr_for_decoder = collected_insn;
            endcase
            next_addr = z80_reg_ip + 1;
            next_z80_reg_ip = z80_reg_ip + 1;
            next_mem_rd = 1;
        end

        // This part determines the current op and insn length.
        // (the op is just the opcode part, while the insn includes
        // the op bytes and the operand bytes).
        if (collected_op_ready) op_len_for_decoder = collected_op_len;
        else op_len_for_decoder = collected_op_len + 1;

        if (collected_insn_ready) insn_len_for_sequencer = collected_insn_len;
        else insn_len_for_sequencer = collected_insn_len + 1;

        next_collected_insn_len = insn_len_for_sequencer;
        next_collected_insn = instr_for_decoder;
        next_collected_insn_ready = 0;
        next_collected_op_len = op_len_for_decoder;
        next_collected_op_ready = 0;

        // Here we check that we have enough bytes for the op.
        if (decoded_group == `INSN_GROUP_NEED_MORE_BYTES) begin
            next_collected_op_ready = 0;
            next_collected_insn_ready = 0;
        end else begin
            next_collected_op_ready = 1;
            if (decoded_len != insn_len_for_sequencer) begin
                next_collected_insn_ready = 0;
            end else begin
                next_collected_insn_ready = 1;
            end
        end

    // I guess I could just use collected_insn_ready? In any case, until
    // we have all the bytes in the instruction, we remain in state 0.
    if (insn_len_for_sequencer == decoded_len) begin
        next_state = state + 1;

        `ifdef FORMAL
            assert(op_len_for_decoder != 0);
        `endif

        case (op_len_for_decoder)
            1: insn_operand = instr_for_decoder[23:8];
            default: insn_operand = instr_for_decoder[31:16];
        endcase

        case (decoded_group)
            `INSN_GROUP_NOP:  /* NOP */
                task_done();

            // TODO: Break out of halt on interrupt
            `INSN_GROUP_HALT: begin  /* HALT */
                task_jump_relative(-16'h1);
                task_done();
            end

            `INSN_GROUP_JP: begin /* JP nn */
                task_jump(insn_operand[15:0]);
                task_done();
            end

            `INSN_GROUP_JP_COND: begin /* JP CC, nn */
                case (instr_for_decoder[5:3])
                    0, 1: if (f_rdata[`FLAG_Z_NUM] == instr_for_decoder[3])
                        task_jump(insn_operand[15:0]);
                    2, 3: if (f_rdata[`FLAG_C_NUM] == instr_for_decoder[3])
                        task_jump(insn_operand[15:0]);
                    4, 5: if (f_rdata[`FLAG_PV_NUM] == instr_for_decoder[3])
                        task_jump(insn_operand[15:0]);
                    6, 7: if (f_rdata[`FLAG_S_NUM] == instr_for_decoder[3])
                        task_jump(insn_operand[15:0]);
                endcase
                task_done();
            end

            `INSN_GROUP_JR: begin /* JR e */
                task_jump_relative({ {8{insn_operand[7]}}, insn_operand[7:0]});
                task_done();
            end

            `INSN_GROUP_JR_COND: begin /* JR CC, e */
                if (f_rdata[instr_for_decoder[4] ? `FLAG_C_NUM : `FLAG_Z_NUM] ==
                        instr_for_decoder[3])
                    task_jump_relative({ {8{insn_operand[7]}}, insn_operand[7:0]});
                task_done();
            end

            `INSN_GROUP_EI_DI: begin  /* EI/DI */
                if (!instr_for_decoder[3]) task_disable_interrupts();
                else task_enable_interrupts();
                task_done();
            end

            `INSN_GROUP_LD_REG_REG: begin  /* LD  r, r' */
                task_read_reg(1, instr_for_decoder[2:0]);
                task_write_reg(instr_for_decoder[5:3], reg1_rdata);
                task_done();
            end

            `INSN_GROUP_LD_DD_NN: begin  /* LD  dd, nn */
                task_write_reg({`REG_SET_DD, instr_for_decoder[5:4]}, insn_operand);
                task_done();
            end

            `INSN_GROUP_LD_IXIY_NN: begin  /* LD  IX/IY, nn */
                task_write_reg({`REG_SET_IDX, instr_for_decoder[5]}, insn_operand);
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
                            {`REG_SET_DD, instr_for_decoder[13:12]},
                            next_collected_data
                        );
                        task_done();
                    end
                endcase

            `INSN_GROUP_LD_IND_BCDE_A:  /* LD  (BC/DE), A */
                case (state)
                    0: begin
                        task_read_reg(1, {`REG_SET_DD, 1'b0, instr_for_decoder[4]});
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
                        task_read_reg(1, {`REG_SET_DD, 1'b0, instr_for_decoder[4]});
                        task_read_mem(1, reg1_rdata);
                    end
                    1: begin
                        task_collect_data(1);
                        task_write_reg(`REG_A, next_collected_data[7:0]);
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
                        task_write_reg(`REG_A, next_collected_data[7:0]);
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

            `INSN_GROUP_LD_A_I: begin  /* LD  A, I         */
                task_write_f(
                    (f_rdata & (`FLAG_5_BIT | `FLAG_3_BIT | `FLAG_C_BIT)) |
                    (z80_reg_i == 0 ? `FLAG_Z_BIT : 0) |
                    (z80_reg_i[7] == 1 ? `FLAG_S_BIT : 0) |
                    (z80_reg_iff2 == 1 ? `FLAG_PV_BIT : 0));
                task_write_reg(`REG_A, z80_reg_i);
                task_done();
            end

            `INSN_GROUP_LD_I_A: begin  /* LD  I, A         */
                task_read_reg(1, `REG_A);
                task_write_i(reg1_rdata);
                task_done();
            end

            `INSN_GROUP_LD_A_R: begin  /* LD  A, R         */
                task_write_f(
                    (f_rdata & (`FLAG_5_BIT | `FLAG_3_BIT | `FLAG_C_BIT)) |
                    (z80_reg_r == 0 ? `FLAG_Z_BIT : 0) |
                    (z80_reg_r[7] == 1 ? `FLAG_S_BIT : 0) |
                    (z80_reg_iff2 == 1 ? `FLAG_PV_BIT : 0));
                task_write_reg(`REG_A, z80_reg_r);
                task_done();
            end

            `INSN_GROUP_LD_R_A: begin  /* LD  R, A         */
                task_read_reg(1, `REG_A);
                task_write_r(reg1_rdata);
                task_done();
            end

            `INSN_GROUP_LD_REG_N: begin  /* LD  r, n */
                task_write_reg(instr_for_decoder[5:3], insn_operand[7:0]);
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
                        task_read_reg(2, instr_for_decoder[2:0]);
                        task_write_mem(1, reg1_rdata, reg2_rdata[7:0]);
                    end
                    1: begin
                        task_write_mem_done(1);
                        task_done();
                    end
                endcase

            `INSN_GROUP_LD_REG_IDX_IXIY:  /* LD  r, (IX/IY+d) */
                case (state)
                    0: begin
                        task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                    end
                    1: begin
                        task_collect_data(1);
                        task_write_reg(instr_for_decoder[13:11], next_collected_data[7:0]);
                        task_done();
                    end
                endcase

            `INSN_GROUP_LD_IDX_IXIY_N:  /* LD  (IX/IY+d), n */
                case (state)
                    0: begin
                        task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]}, insn_operand[15:8]);
                    end
                    1: begin
                        task_write_mem_done(1);
                        task_done();
                    end
                endcase

            `INSN_GROUP_LD_IDX_IXIY_REG:  /* LD  (IX/IY+d), r */
                case (state)
                    0: begin
                        task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_read_reg(2, instr_for_decoder[10:8]);
                        task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]}, reg2_rdata[7:0]);
                    end
                    1: begin
                        task_write_mem_done(1);
                        task_done();
                    end
                endcase

            `INSN_GROUP_LD_IND_NN_DD:  /* LD  (nn), dd     */
                case (state)
                    0: begin
                        task_read_reg(1, {`REG_SET_DD, instr_for_decoder[13:12]});
                        task_write_mem(1, insn_operand, reg1_rdata[7:0]);
                    end
                    1: begin
                        task_read_reg(1, {`REG_SET_DD, instr_for_decoder[13:12]});
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
                        task_write_reg(`DD_REG_HL, next_collected_data);
                        task_done();
                    end
                endcase

            `INSN_GROUP_LD_SP_HL: begin  /* LD  SP, HL       */
                task_read_reg(1, `DD_REG_HL);
                task_write_reg(`DD_REG_SP, reg1_rdata);
                task_done();
            end

            `INSN_GROUP_LD_SP_IXIY: begin  /* LD  SP, IX/IY    */
                task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                task_write_reg(`DD_REG_SP, reg1_rdata);
                task_done();
            end

            `INSN_GROUP_LD_IND_NN_IXIY:  /* LD  (nn), IX/IY  */
                case (state)
                    0: begin
                        task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_write_mem(1, insn_operand, reg1_rdata[7:0]);
                    end
                    1: begin
                        task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
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
                            {`REG_SET_IDX, instr_for_decoder[5]},
                            next_collected_data
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
                        task_write_mem(1, reg1_rdata, next_collected_data[7:0]);
                        task_block_dec();
                    end
                    2: begin
                        task_write_mem_done(1);
                        task_done();
                    end
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
                        task_write_mem(1, reg1_rdata, next_collected_data[7:0]);
                        task_block_inc();
                    end
                    2: begin
                        task_write_mem_done(1);
                        task_done();
                    end
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
                        task_write_mem(1, reg1_rdata, next_collected_data[7:0]);
                        task_block_dec();
                    end
                    2: begin
                        task_write_mem_done(1);
                        task_jump_relative(flag_pv ? -16'h2 : 0);
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
                        task_write_mem(1, reg1_rdata, next_collected_data[7:0]);
                        task_block_inc();
                    end
                    2: begin
                        task_write_mem_done(1);
                        task_jump_relative(flag_pv ? -16'h2 : 0);
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
                        task_collect_data(1);
                        task_read_reg(1, `REG_A);
                        task_alu8_compare(reg1_rdata[7:0], next_collected_data[7:0]);
                        // Flag C should be unaffected by the ALU.
                        task_write_f(
                            _combine_flags(f_rdata, alu8_f_out, `FLAG_C_BIT));
                    end
                    2: begin
                        task_compare_block_dec();
                        task_done();
                    end
                endcase

            `INSN_GROUP_CPDR:  /* CPDR */
                case (state)
                    0: begin
                        task_read_reg(1, `DD_REG_HL);
                        task_read_mem(1, reg1_rdata);
                    end
                    1: begin
                        task_collect_data(1);
                        task_read_reg(1, `REG_A);
                        task_alu8_compare(reg1_rdata[7:0], next_collected_data[7:0]);
                        // Flag C should be unaffected by the ALU.
                        task_write_f(
                            _combine_flags(f_rdata, alu8_f_out, `FLAG_C_BIT));
                    end
                    2: begin
                        // Have to wait one cycle for the flags to be written.
                        task_compare_block_dec();
                    end
                    3: begin
                        task_jump_relative(flag_pv ? -16'h2 : 0);
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
                        task_collect_data(1);
                        task_read_reg(1, `REG_A);
                        task_alu8_compare(reg1_rdata[7:0], next_collected_data[7:0]);
                        // Flag C should be unaffected by the ALU.
                        task_write_f(
                            _combine_flags(f_rdata, alu8_f_out, `FLAG_C_BIT));
                    end
                    2: begin
                        task_compare_block_inc();
                        task_done();
                    end
                endcase

            `INSN_GROUP_CPIR:  /* CPIR */
                case (state)
                    0: begin
                        task_read_reg(1, `DD_REG_HL);
                        task_read_mem(1, reg1_rdata);
                    end
                    1: begin
                        task_collect_data(1);
                        task_read_reg(1, `REG_A);
                        task_alu8_compare(reg1_rdata[7:0], next_collected_data[7:0]);
                        // Flag C should be unaffected by the ALU.
                        task_write_f(
                            _combine_flags(f_rdata, alu8_f_out, `FLAG_C_BIT));
                    end
                    2: begin
                        // Have to wait one cycle for the flags to be written.
                        task_compare_block_inc();
                    end
                    3: begin
                        task_jump_relative(flag_pv ? -16'h2 : 0);
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
                        task_write_reg({`REG_SET_QQ, instr_for_decoder[5:4]}, next_collected_data);
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
                        task_write_reg({`REG_SET_IDX, instr_for_decoder[5]}, next_collected_data);
                        task_done();
                    end
                endcase

            `INSN_GROUP_PUSH_QQ:  /* PUSH qq */
                case (state)
                    0: begin
                        task_read_reg(1, `DD_REG_SP);
                        task_read_reg(2, {`REG_SET_QQ, instr_for_decoder[5:4]});
                        task_write_mem(1, reg1_rdata - 16'h2, reg2_rdata[7:0]);
                    end
                    1: begin
                        task_write_mem_done(1);
                        task_read_reg(1, `DD_REG_SP);
                        task_read_reg(2, {`REG_SET_QQ, instr_for_decoder[5:4]});
                        task_write_mem(2, reg1_rdata - 16'h1, reg2_rdata[15:8]);
                    end
                    2: begin
                        task_write_mem_done(2);
                        task_read_reg(1, `DD_REG_SP);
                        task_write_reg(`DD_REG_SP, reg1_rdata - 16'h2);
                        task_done();
                    end
                endcase

            `INSN_GROUP_PUSH_IXIY:  /* PUSH IX/IY */
                case (state)
                    0: begin
                        task_read_reg(1, `DD_REG_SP);
                        task_read_reg(2, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_write_mem(1, reg1_rdata - 16'h2, reg2_rdata[7:0]);
                    end
                    1: begin
                        task_write_mem_done(1);
                        task_read_reg(1, `DD_REG_SP);
                        task_read_reg(2, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_write_mem(2, reg1_rdata - 16'h1, reg2_rdata[15:8]);
                    end
                    2: begin
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
                        task_read_reg(2, `DD_REG_HL);
                        task_read_mem(1, reg1_rdata);
                    end
                    1: begin
                        task_collect_data(1);
                        task_read_reg(1, `DD_REG_SP);
                        task_read_reg(2, `DD_REG_HL);
                        task_write_mem(1, reg1_rdata, reg2_rdata[7:0]);
                    end
                    2: begin
                        task_write_mem_done(1);
                        task_read_reg(1, `DD_REG_SP);
                        task_read_reg(2, `DD_REG_HL);
                        task_read_mem(2, reg1_rdata + 1);
                    end
                    3: begin
                        task_collect_data(2);
                        task_read_reg(1, `DD_REG_SP);
                        task_read_reg(2, `DD_REG_HL);
                        task_write_mem(1, reg1_rdata + 1, reg2_rdata[15:8]);
                        task_write_reg(`DD_REG_HL, next_collected_data);
                    end
                    4: begin
                        task_write_mem_done(2);
                        task_done();
                    end
                endcase

            `INSN_GROUP_EX_IND_SP_IXIY:  /* EX (SP), IX/IY */
                case (state)
                    0: begin
                        task_read_reg(1, `DD_REG_SP);
                        task_read_reg(2, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_read_mem(1, reg1_rdata);
                    end
                    1: begin
                        task_collect_data(1);
                        task_read_reg(1, `DD_REG_SP);
                        task_read_reg(2, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_write_mem(1, reg1_rdata, reg2_rdata[7:0]);
                    end
                    2: begin
                        task_write_mem_done(1);
                        task_read_reg(1, `DD_REG_SP);
                        task_read_reg(2, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_read_mem(2, reg1_rdata + 1);
                    end
                    3: begin
                        task_collect_data(2);
                        task_read_reg(1, `DD_REG_SP);
                        task_read_reg(2, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_write_mem(1, reg1_rdata + 1, reg2_rdata[15:8]);
                        task_write_reg(
                            {`REG_SET_IDX, instr_for_decoder[5]},
                            next_collected_data);
                    end
                    4: begin
                        task_write_mem_done(2);
                        task_done();
                    end
                endcase

            `INSN_GROUP_ALU_A_REG:  /* ADD/ADC/SUB/SBC/AND/XOR/OR/CP A, r */
                case (state)
                    0: begin
                        task_read_reg(1, `REG_A);
                        task_read_reg(2, instr_for_decoder[2:0]);
                        task_alu8_op(instr_for_decoder[5:3], reg1_rdata[7:0], reg2_rdata[7:0]);
                        if (instr_for_decoder[5:3] != `ALU_FUNC_CP) task_write_reg(`REG_A, alu8_out);
                        task_write_f(alu8_f_out);
                        task_done();
                    end
                endcase

            `INSN_GROUP_INC_DEC_REG:  /* INC/DEC r */
                case (state)
                    0: begin
                        task_read_reg(1, instr_for_decoder[5:3]);
                        task_alu8_op(instr_for_decoder[0] ? `ALU_FUNC_ADD : `ALU_FUNC_SUB, reg1_rdata[7:0], 8'b1);
                        task_write_reg(instr_for_decoder[5:3], alu8_out);
                        // Flag C is not affected.
                        task_write_f(_combine_flags(f_rdata, alu8_f_out, `FLAG_C_BIT));
                        task_done();
                    end
                endcase

            `INSN_GROUP_INC_DEC_DD:  /* INC/DEC dd */
                case (state)
                    0: begin
                        task_read_reg(1, {`REG_SET_DD, instr_for_decoder[5:4]});
                        task_alu16_op(instr_for_decoder[3] ? `ALU_FUNC_SUB : `ALU_FUNC_ADD, reg1_rdata, 8'b1);
                        task_write_reg({`REG_SET_DD, instr_for_decoder[5:4]}, alu16_out);
                        task_done();
                    end
                endcase

            `INSN_GROUP_INC_DEC_IXIY:  /* INC/DEC IX/IY */
                case (state)
                    0: begin
                        task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_alu16_op(instr_for_decoder[11] ? `ALU_FUNC_SUB : `ALU_FUNC_ADD, reg1_rdata, 8'b1);
                        task_write_reg({`REG_SET_IDX, instr_for_decoder[5]}, alu16_out);
                        task_done();
                    end
                endcase

            `INSN_GROUP_ALU_A_N:  /* ADD/ADC/SUB/SBC/AND/XOR/OR/CP A, n */
                case (state)
                    0: begin
                        task_read_reg(1, `REG_A);
                        task_alu8_op(instr_for_decoder[5:3], reg1_rdata[7:0], insn_operand[7:0]);
                        if (instr_for_decoder[5:3] != `ALU_FUNC_CP) task_write_reg(`REG_A, alu8_out);
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
                        task_alu8_op(instr_for_decoder[5:3], reg1_rdata[7:0], next_collected_data[7:0]);
                        if (instr_for_decoder[5:3] != `ALU_FUNC_CP) task_write_reg(`REG_A, alu8_out);
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
                        task_read_reg(1, `DD_REG_HL);
                        task_collect_data(1);
                        task_alu8_op(instr_for_decoder[0] ? `ALU_FUNC_ADD : `ALU_FUNC_SUB, next_collected_data[7:0], 8'b1);
                        task_write_mem(1, reg1_rdata, alu8_out);
                        // Flag C is not affected.
                        task_write_f(_combine_flags(f_rdata, alu8_f_out, `FLAG_C_BIT));
                    end
                    2: begin
                        task_write_mem_done(1);
                        task_done();
                    end
                endcase

            `INSN_GROUP_ALU_A_IDX_IXIY:  /* ADD/ADC/SUB/SBC/AND/XOR/OR/CP A, (IX/IY + d) */
                case (state)
                    0: begin
                        task_read_reg(2, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_read_mem(1, reg2_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                    end
                    1: begin
                        task_collect_data(1);
                        task_read_reg(1, `REG_A);
                        task_alu8_op(instr_for_decoder[13:11], reg1_rdata[7:0], next_collected_data[7:0]);
                        if (instr_for_decoder[13:11] != `ALU_FUNC_CP) task_write_reg(`REG_A, alu8_out);
                        task_write_f(alu8_f_out);
                        task_done();
                    end
                endcase

            `INSN_GROUP_INC_DEC_IDX_IXIY:  /* INC/DEC (IX/IY + d) */
                case (state)
                    0: begin
                        task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_read_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]});
                    end
                    1: begin
                        task_read_reg(1, {`REG_SET_IDX, instr_for_decoder[5]});
                        task_collect_data(1);
                        task_alu8_op(instr_for_decoder[8] ? `ALU_FUNC_ADD : `ALU_FUNC_SUB, next_collected_data[7:0], 8'b1);
                        task_write_mem(1, reg1_rdata + { {8{insn_operand[7]}}, insn_operand[7:0]}, alu8_out);
                        // Flag C is not affected.
                        task_write_f(_combine_flags(f_rdata, alu8_f_out, `FLAG_C_BIT));
                    end
                    2: begin
                        task_write_mem_done(1);
                        task_done();
                    end
                endcase

            `INSN_GROUP_ADD_HL_DD:  /* ADD HL, dd */
                case (state)
                    0: begin
                        task_read_reg(1, `DD_REG_HL);
                        task_read_reg(2, {`REG_SET_DD, instr_for_decoder[5:4]});
                        task_alu16_op(`ALU_FUNC_ADD, reg1_rdata, reg2_rdata);
                        // N is reset, and only H and C are used.
                        task_write_f(`FLAG_N_MASK &
                            _combine_flags(alu16_f_out, f_rdata,
                                `FLAG_H_BIT | `FLAG_C_BIT));
                        task_write_reg(`DD_REG_HL, alu16_out);
                        task_done();
                    end
                endcase

            `INSN_GROUP_ADD_IXIY_SS:  /* ADD IX/IY, ss */
                case (state)
                    0: begin
                        task_read_reg(1, instr_for_decoder[5] ? `IDX_REG_IY : `IDX_REG_IX);
                        if (instr_for_decoder[13:12] == `REG_HL)
                            task_read_reg(2, instr_for_decoder[5] ? `IDX_REG_IY : `IDX_REG_IX);
                        else
                            task_read_reg(2, {`REG_SET_DD, instr_for_decoder[13:12]});
                        task_alu16_op(`ALU_FUNC_ADD, reg1_rdata, reg2_rdata);
                        // N is reset, and only H and C are used.
                        task_write_f(`FLAG_N_MASK &
                            _combine_flags(alu16_f_out, f_rdata,
                                `FLAG_H_BIT | `FLAG_C_BIT));
                        task_write_reg(instr_for_decoder[5] ? `IDX_REG_IY : `IDX_REG_IX, alu16_out);
                        task_done();
                    end
                endcase

            `INSN_GROUP_ADC_SBC_HL_DD:  /* ADC/SBC HL, dd */
                case (state)
                    0: begin
                        task_read_reg(1, `DD_REG_HL);
                        task_read_reg(2, {`REG_SET_DD, instr_for_decoder[13:12]});
                        task_alu16_op(instr_for_decoder[11] ? `ALU_FUNC_ADC : `ALU_FUNC_SBC, reg1_rdata, reg2_rdata);
                        task_write_f(alu16_f_out);
                        task_write_reg(`DD_REG_HL, alu16_out);
                        task_done();
                    end
                endcase

            `INSN_GROUP_DAA: begin  /* DAA */
                task_read_reg(1, `REG_A);
                task_alu8_op(f_rdata[`FLAG_N_NUM] ? `ALU_FUNC_SUB : `ALU_FUNC_ADD,
                    reg1_rdata,
                    _daa_adjustment(f_rdata[`FLAG_C_NUM], f_rdata[`FLAG_H_NUM], reg1_rdata));
                task_write_reg(`REG_A, alu8_out);
                // Flag PV is parity, not overflow.
                task_write_f(
                    _combine_flags(_alu_parity8(alu8_out) ? `FLAG_PV_BIT : 0,
                        alu8_f_out, `FLAG_PV_BIT));
                task_done();
            end

            `INSN_GROUP_CPL: begin  /* CPL */
                task_read_reg(1, `REG_A);
                task_write_reg(`REG_A, ~reg1_rdata);
                task_write_f(_combine_flags(
                    `FLAG_H_BIT | `FLAG_N_BIT, f_rdata,
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
                    f_rdata[7], // s
                    f_rdata[6], // z
                    f_rdata[5], // 5
                    f_rdata[0], // h (original c)
                    f_rdata[3], // 3
                    f_rdata[2], // v
                    1'b0,       // n
                    ~f_rdata[0] // c (complemented c)
                    });
                task_done();
            end

            `INSN_GROUP_SCF: begin  /* SCF */
                task_write_f({
                    f_rdata[7], // s
                    f_rdata[6], // z
                    f_rdata[5], // 5
                    1'b0,       // h
                    f_rdata[3], // 3
                    f_rdata[2], // v
                    1'b0,       // n
                    1'b1        // c
                    });
                task_done();
            end

            `INSN_GROUP_RR_RLCA: begin  /* RLCA/RLC/RRCA/RRA */
                task_read_reg(1, `REG_A);
                task_alu8_op(
                    {`ALU_ROT, instr_for_decoder[4:3]},
                    reg1_rdata,
                    0);
                task_write_f(`FLAG_H_MASK & `FLAG_N_MASK &
                    _combine_flags(alu8_f_out, f_rdata, `FLAG_C_BIT));
                task_write_reg(`REG_A, alu8_out);
                task_done();
            end

            `INSN_GROUP_RR_RLC_REG: begin  /* RLCA/RLC/RRCA/RRA r */
                task_read_reg(1, instr_for_decoder[10:8]);
                task_alu8_op(
                    {`ALU_ROT, instr_for_decoder[12:11]},
                    reg1_rdata,
                    0);
                task_write_f(`FLAG_H_MASK & `FLAG_N_MASK & alu8_f_out);
                task_write_reg(instr_for_decoder[10:8], alu8_out);
                task_done();
            end

            `INSN_GROUP_RR_RLC_IND_HL:  /* RLCA/RLC/RRCA/RRA (HL) */
                case (state)
                    0: begin
                        task_read_reg(1, `DD_REG_HL);
                        task_read_mem(1, reg1_rdata);
                    end
                    1: begin
                        task_read_reg(1, `DD_REG_HL);
                        task_collect_data(1);
                        task_alu8_op(
                            {`ALU_ROT, instr_for_decoder[12:11]},
                            next_collected_data[7:0],
                            0);
                        task_write_f(`FLAG_H_MASK & `FLAG_N_MASK & alu8_f_out);
                        task_write_mem(1, reg1_rdata, alu8_out);
                    end
                    2: begin
                        task_write_mem_done(1);
                        task_done();
                    end
                endcase

            `INSN_GROUP_SHIFT_REG: begin  /* SRA/SRL/SLA r */
                task_read_reg(1, instr_for_decoder[10:8]);
                task_alu8_op(
                    {`ALU_SHIFT, instr_for_decoder[12:11]},
                    reg1_rdata,
                    0);
                task_write_f(`FLAG_H_MASK & `FLAG_N_MASK & alu8_f_out);
                task_write_reg(instr_for_decoder[10:8], alu8_out);
                task_done();
            end

            `INSN_GROUP_SHIFT_IND_HL:  /* SRA/SRL/SLA (HL) */
                case (state)
                    0: begin
                        task_read_reg(1, `DD_REG_HL);
                        task_read_mem(1, reg1_rdata);
                    end
                    1: begin
                        task_read_reg(1, `DD_REG_HL);
                        task_collect_data(1);
                        task_alu8_op(
                            {`ALU_SHIFT, instr_for_decoder[12:11]},
                            next_collected_data[7:0],
                            0);
                        task_write_f(`FLAG_H_MASK & `FLAG_N_MASK & alu8_f_out);
                        task_write_mem(1, reg1_rdata, alu8_out);
                    end
                    2: begin
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
                        task_collect_data(1);
                        task_read_reg(1, `DD_REG_HL);
                        task_read_reg(2, `REG_A);
                        task_rotate_decimal(instr_for_decoder[11],
                            reg2_rdata[7:0], next_collected_data[7:0],
                            reg1_rdata);
                    end
                    2: begin
                        task_write_mem_done(1);
                        task_done();
                    end
                endcase

            `INSN_GROUP_BIT_REG: begin  /* BIT b, r */
                task_read_reg(1, instr_for_decoder[10:8]);
                task_write_f({
                    // Undocumented value of S flag:
                    // Set if bit = 7 and bit 7 in r is set.
                    instr_for_decoder[13:11] == 3'b111 && reg1_rdata[7] == 1'b1, // S ("unknown")
                    ~reg1_rdata[instr_for_decoder[13:11]], // Z
                    f_rdata[`FLAG_5_NUM],
                    1'b1, // H
                    f_rdata[`FLAG_3_NUM],
                    // Undocumented value of PV flag: Same as Z.
                    ~reg1_rdata[instr_for_decoder[13:11]],  // PV ("unknown")
                    1'b0, // N
                    f_rdata[`FLAG_C_NUM]
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
                        task_collect_data(1);
                        task_write_f({
                            // Undocumented value of S flag:
                            // Set if bit = 7 and bit 7 in r is set.
                            instr_for_decoder[13:11] == 3'b111 && next_collected_data[7] == 1'b1, // S ("unknown")
                            ~next_collected_data[instr_for_decoder[13:11]], // Z
                            f_rdata[`FLAG_5_NUM],
                            1'b1, // H
                            f_rdata[`FLAG_3_NUM],
                            // Undocumented value of PV flag: Same as Z.
                            ~next_collected_data[instr_for_decoder[13:11]],  // PV ("unknown")
                            1'b0, // N
                            f_rdata[`FLAG_C_NUM]
                        });
                        task_done();
                    end
                endcase

            `INSN_GROUP_SET_REG: begin  /* SET b, r */
                task_read_reg(1, instr_for_decoder[10:8]);
                task_write_reg(instr_for_decoder[10:8],
                    reg1_rdata | (8'b1 << instr_for_decoder[13:11]));
                task_done();
                end

            `INSN_GROUP_SET_IND_HL:  /* SET b, (HL) */
                case (state)
                    0: begin
                        task_read_reg(1, `DD_REG_HL);
                        task_read_mem(1, reg1_rdata);
                    end
                    1: begin
                        task_collect_data(1);
                        task_read_reg(1, `DD_REG_HL);
                        task_write_mem(1, reg1_rdata,
                            next_collected_data[7:0] | (8'b1 << instr_for_decoder[13:11]));
                    end
                    2: begin
                        task_write_mem_done(1);
                        task_done();
                    end
                endcase

            `INSN_GROUP_RES_REG: begin  /* RES b, r */
                task_read_reg(1, instr_for_decoder[10:8]);
                task_write_reg(instr_for_decoder[10:8],
                    reg1_rdata & ~(8'b1 << instr_for_decoder[13:11]));
                task_done();
                end

            `INSN_GROUP_RES_IND_HL:  /* RES b, (HL) */
                case (state)
                    0: begin
                        task_read_reg(1, `DD_REG_HL);
                        task_read_mem(1, reg1_rdata);
                    end
                    1: begin
                        task_collect_data(1);
                        task_read_reg(1, `DD_REG_HL);
                        task_write_mem(1, reg1_rdata,
                            next_collected_data[7:0] & ~(8'b1 << instr_for_decoder[13:11]));
                    end
                    2: begin
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
        endcase
    end

    if (next_done) begin
        next_addr = next_z80_reg_ip;
        next_collected_data = 0;
        next_collected_insn_len = 0;
        next_collected_insn_ready = 0;
        next_collected_op_len = 0;
        next_collected_op_ready = 0;
        next_mem_rd = 1;
        next_mem_wr = 0;
        next_state = 0;

        `ifdef Z80_FORMAL
            next_z80fi_valid = 1;
            next_z80fi_insn = instr_for_decoder;
            next_z80fi_insn_len = insn_len_for_sequencer;
            // We can't do something like next_z80fi_reg_a_out = z80_reg_a
            // because if we've set up the register to be written to,
            // the register has not yet been set.
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
