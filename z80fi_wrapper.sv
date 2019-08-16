`include "z80fi.vh"
`define Z80_FORMAL
`include "z80.v"

module z80fi_wrapper(
    input         clk,
	input         reset,
	`Z80FI_OUTPUTS
);

`z80formal_rand_reg [7:0] bus_rdata;

// These output signals aren't monitored. Instead, we verify
// using the z80fi interface.
wire [15:0] bus_addr;
wire [7:0] bus_wdata;
wire bus_nwrite;
wire bus_nread;
wire nmreq;
wire niorq;

z80 uut(
    .CLK(clk),
    .nRESET(!reset),
    .READ_D(bus_rdata),

    .A(bus_addr),
    .nMREQ(nmreq),
    .nIORQ(niorq),
    .nWR(bus_nwrite),
    .nRD(bus_nread),
    .WRITE_D(bus_wdata),

    `Z80FI_CONN
);

endmodule
