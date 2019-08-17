`include "z80fi.vh"
`include "z80.v"

// See if we can read and write some memory.
module testbench(
    input clk,

    input [7:0] READ_D,

    output nRD,
    output nWR,
    output [15:0] A,
    output [7:0] WRITE_D
);

reg nRESET = 0;

always @(posedge clk)
    nRESET <= 1;

`Z80FI_WIRES

z80 uut(
    .CLK(clk),
    .nRESET(nRESET),
    .READ_D(READ_D),

    .A(A),
    .nWR(nWR),
    .nRD(nRD),
    .WRITE_D(WRITE_D),

    `Z80FI_CONN
);

integer count_memrd = 0;
integer count_memwr = 0;

always @(posedge clk) begin
    if (nRESET && z80fi_valid) begin
        if (z80fi_mem_rd)
            count_memrd <= count_memrd + 1;
        if (z80fi_mem_wr)
            count_memwr <= count_memwr + 1;
    end
end

`ifdef FORMAL
cover property (count_memrd);
cover property (count_memrd >= 3);
cover property (count_memwr);
cover property (count_memwr >= 3);
cover property (count_memrd >= 1 && count_memwr >= 1);
`endif

endmodule
