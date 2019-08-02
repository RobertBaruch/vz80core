`include "z80fi.vh"
`define Z80_FORMAL
`include "z80.v"

module z80fi_wrapper(
    input         clk,
	input         reset,
	`Z80FI_OUTPUTS    
);

`z80formal_rand_reg [7:0] mem_rdata;

wire [15:0] mem_addr;
wire [7:0] mem_wdata;
wire mem_write;
wire mem_read;

wire mem_nwrite = !mem_write;
wire mem_nread = !mem_read;

z80 uut(
    .CLK(clk),
    .nRESET(!reset),
    .READ_D(mem_rdata),

    .A(mem_addr),
    .nWR(mem_nwrite),
    .nRD(mem_nread),
    .WRITE_D(mem_wdata),

    `Z80FI_CONN
);

endmodule
