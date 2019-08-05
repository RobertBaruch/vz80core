`ifndef _sequencer_sv_
`define _sequencer_sv_

`include "z80.vh"
`include "z80fi.vh"
`include "registers.sv"
`include "ir_registers.sv"
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

logic i_wr;
logic [7:0] i_wdata;
logic r_wr;
logic [7:0] r_wdata;
logic [7:0] i_rdata;
logic [7:0] r_rdata;
logic iff1;
logic iff2;

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

logic [15:0] ip;

logic [3:0] state;

//
// Next state variables
//

logic next_done;
logic [15:0] next_addr;
logic next_mem_rd;
logic next_mem_wr;
logic [7:0] next_mem_wdata;
logic next_reg_wr;
logic next_i_wr;
logic next_r_wr;
logic next_f_wr;

logic [31:0] next_collected_insn;
logic [2:0] next_collected_insn_len;
logic next_collected_insn_ready;
logic next_collected_op_ready;
logic [1:0] next_collected_op_len;

logic [15:0] next_collected_data;
logic next_collected_data_ready;
logic [1:0] next_collected_data_len;

logic [15:0] next_ip;

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
        reg_wr <= 0;
        i_wr <= 0;
        r_wr <= 0;
        f_wr <= 0;

        collected_insn <= 0;
        collected_insn_len <= 0;
        collected_insn_ready <= 0;
        collected_op_ready <= 0;
        collected_op_len <= 0;

        collected_data <= 0;
        collected_data_ready <= 0;
        collected_data_len <= 0;

        ip <= 0;

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
        reg_wr <= next_reg_wr;
        i_wr <= next_i_wr;
        r_wr <= next_r_wr;
        f_wr <= next_f_wr;

        collected_insn <= next_collected_insn;
        collected_insn_len <= next_collected_insn_len;
        collected_insn_ready <= next_collected_insn_ready;
        collected_op_ready <= next_collected_op_ready;
        collected_op_len <= next_collected_op_len;

        collected_data <= next_collected_data;
        collected_data_ready <= next_collected_data_ready;
        collected_data_len <= next_collected_data_len;

        ip <= next_ip;

        state <= next_state;

        `ifdef Z80_FORMAL
            `Z80FI_LOAD_NEXT_STATE
        `endif
    end
end

`ifdef Z80_FORMAL
    `Z80FI_NEXT_STATE
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
    .f_wr(f_wr)

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

    .reg_i(i_rdata),
    .reg_r(r_rdata),

    .iff1(iff1),
    .iff2(iff2)
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

always @(*) begin
    if (reset || done) begin
        `ifdef Z80_FORMAL
            `Z80FI_INIT_NEXT_STATE
            next_z80fi_pc_rdata = addr;
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
    next_reg_wr = 0;
    next_i_wr = 0;
    next_r_wr = 0;
    next_f_wr = 0;

    reg1_rnum = 0;
    reg2_rnum = 0;
    reg_wnum = 0;
    reg_wdata = 0;
    i_wdata = 0;
    r_wdata = 0;
    f_wdata = 0;

    next_collected_insn_len = 0;
    next_collected_insn = 0;
    next_collected_insn_ready = 0;
    next_collected_op_len = 0;
    next_collected_op_ready = 0;
    next_collected_data = collected_data;

        next_addr = addr;
        next_ip = ip;
        next_mem_rd = 0;

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
            next_addr = ip + 1;
            next_ip = ip + 1;
            next_mem_rd = 1;
        end

        if (collected_op_ready) op_len_for_decoder = collected_op_len;
        else op_len_for_decoder = collected_op_len + 1;

        if (collected_insn_ready) insn_len_for_sequencer = collected_insn_len;
        else insn_len_for_sequencer = collected_insn_len + 1;

        next_collected_insn_len = insn_len_for_sequencer;
        next_collected_insn = instr_for_decoder;
        next_collected_insn_ready = 0;
        next_collected_op_len = op_len_for_decoder;
        next_collected_op_ready = 0;

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

            `INSN_GROUP_LD_REG_REG: begin  /* LD  r, r' */
                task_read_reg8(1, instr_for_decoder[2:0]);
                task_write_reg8(instr_for_decoder[5:3], reg1_rdata[7:0]);
                task_done();
            end

            `INSN_GROUP_LD_DD_NN: begin  /* LD  dd, nn */
                task_write_reg_pair(instr_for_decoder[5:4], insn_operand);
                task_done();
            end

            `INSN_GROUP_LD_IXIY_NN: begin  /* LD  IX/IY, nn */
                task_write_reg16(instr_for_decoder[5] ? `REG_IY : `REG_IX, insn_operand);
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
                        task_write_reg_pair(
                            instr_for_decoder[13:12],
                            next_collected_data
                        );
                        task_done();
                    end
                endcase

            `INSN_GROUP_LD_IND_BCDE_A:  /* LD  (BC/DE), A */
                case (state)
                    0: begin
                        task_read_reg16(1, instr_for_decoder[4] ? `REG_DE : `REG_BC);
                        task_read_reg8(2, `REG_A);
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
                        task_read_reg16(1, instr_for_decoder[4] ? `REG_DE : `REG_BC);
                        task_read_mem(1, reg1_rdata);
                    end
                    1: begin
                        task_collect_data(1);
                        task_write_reg8(`REG_A, next_collected_data[7:0]);
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
                        task_write_reg8(`REG_A, next_collected_data[7:0]);
                        task_done();
                    end
                endcase

            `INSN_GROUP_LD_IND_NN_A:  /* LD  (nn), A */
                case (state)
                    0: begin
                        task_read_reg8(1, `REG_A);
                        task_write_mem(1, insn_operand, reg1_rdata[7:0]);
                    end
                    1: begin
                        task_write_mem_done(1);
                        task_done();
                    end
                endcase

            `INSN_GROUP_LD_A_I: begin  /* LD  A, I         */
                task_read_i();
                task_read_f();
                task_read_iff2();
                task_write_f(
                    (f_rdata & (`FLAG_5_BIT | `FLAG_3_BIT | `FLAG_C_BIT)) |
                    (i_rdata == 0 ? `FLAG_Z_BIT : 0) |
                    (i_rdata[7] == 1 ? `FLAG_S_BIT : 0) |
                    (iff2 == 1 ? `FLAG_PV_BIT : 0));
                task_write_reg8(`REG_A, i_rdata);
                task_done();
            end

            `INSN_GROUP_LD_I_A: begin  /* LD  I, A         */
                task_read_reg8(1, `REG_A);
                task_write_i(reg1_rdata);
                task_done();
            end

            `INSN_GROUP_LD_A_R: begin  /* LD  A, R         */
                task_read_r();
                task_read_f();
                task_read_iff2();
                task_write_f(
                    (f_rdata & (`FLAG_5_BIT | `FLAG_3_BIT | `FLAG_C_BIT)) |
                    (r_rdata == 0 ? `FLAG_Z_BIT : 0) |
                    (r_rdata[7] == 1 ? `FLAG_S_BIT : 0) |
                    (iff2 == 1 ? `FLAG_PV_BIT : 0));
                task_write_reg8(`REG_A, r_rdata);
                task_done();
            end

            `INSN_GROUP_LD_REG_N: begin  /* LD  r, n */
                task_write_reg8(instr_for_decoder[5:3], insn_operand[7:0]);
                task_done();
            end

            `INSN_GROUP_LD_IND_HL_N:  /* LD  (HL), n */
                case (state)
                    0: begin
                        task_read_reg16(1, `REG_HL);
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
                        task_read_reg16(1, `REG_HL);
                        task_read_reg8(2, instr_for_decoder[2:0]);
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
                        task_read_reg16(1, instr_for_decoder[5] ? `REG_IY : `REG_IX);
                        task_read_mem(1, reg1_rdata + {8'h0, insn_operand[7:0]});
                    end
                    1: begin
                        task_collect_data(1);
                        task_write_reg8(instr_for_decoder[13:11], next_collected_data[7:0]);
                        task_done();
                    end
                endcase

            `INSN_GROUP_LD_IDX_IXIY_N:  /* LD  (IX/IY+d), n */
                case (state)
                    0: begin
                        task_read_reg16(1, instr_for_decoder[5] ? `REG_IY : `REG_IX);
                        task_write_mem(1, reg1_rdata + {8'h0, insn_operand[7:0]}, insn_operand[15:8]);
                    end
                    1: begin
                        task_write_mem_done(1);
                        task_done();
                    end
                endcase

            `INSN_GROUP_LD_IDX_IXIY_REG:  /* LD  (IX/IY+d), r */
                case (state)
                    0: begin
                        task_read_reg16(1, instr_for_decoder[5] ? `REG_IY : `REG_IX);
                        task_read_reg8(2, instr_for_decoder[10:8]);
                        task_write_mem(1, reg1_rdata + {8'h0, insn_operand[7:0]}, reg2_rdata[7:0]);
                    end
                    1: begin
                        task_write_mem_done(1);
                        task_done();
                    end
                endcase

            `INSN_GROUP_LD_IND_NN_DD:  /* LD  (nn), dd     */
                case (state)
                    0: begin
                        task_read_reg_pair(1, instr_for_decoder[13:12]);
                        task_write_mem(1, insn_operand, reg1_rdata[7:0]);
                    end
                    1: begin
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
                        task_read_reg_pair(1, `REG_HL);
                        task_write_mem(1, insn_operand, reg1_rdata[7:0]);
                    end
                    1: begin
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
                        task_write_reg16(`REG_HL, next_collected_data);
                        task_done();
                    end
                endcase

            `INSN_GROUP_LD_IND_NN_IXIY:  /* LD  (nn), IX/IY  */
                case (state)
                    0: begin
                        task_read_reg16(1, instr_for_decoder[5] ? `REG_IY : `REG_IX);
                        task_write_mem(1, insn_operand, reg1_rdata[7:0]);
                    end
                    1: begin
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
                        task_write_reg16(
                            instr_for_decoder[5] ? `REG_IY : `REG_IX,
                            next_collected_data
                        );
                        task_done();
                    end
                endcase

            default: begin // For now, just assume done
                next_done = 1;
            end
        endcase
    end

    if (next_done) begin
        next_addr = next_ip;
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
            next_z80fi_pc_wdata = next_ip;
            next_z80fi_insn = instr_for_decoder;
            next_z80fi_insn_len = insn_len_for_sequencer;
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
