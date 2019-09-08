`define Z80_FORMAL

`include "z80.sv"
`include "z80fi.vh"

module z80fi_wrapper(
    input clk,
	input reset,
    input wwait,
    input bus_req,
	`Z80FI_OUTPUTS
);

`z80formal_rand_reg [7:0] bus_rdata;

// These output signals aren't monitored. Instead, we verify
// using the z80fi interface.
logic [15:0] bus_addr;
logic [7:0] bus_wdata;
logic bus_nwrite;
logic bus_nread;
logic nmreq;
logic niorq;
logic nm1;
logic nrfsh;
logic nbusak;

z80 uut(
    .CLK(clk),
    .nRESET(!reset),
    .nWAIT(!wwait),
    .nBUSRQ(!bus_req),
    .READ_D(bus_rdata),

    .A(bus_addr),
    .nMREQ(nmreq),
    .nIORQ(niorq),
    .nWR(bus_nwrite),
    .nRD(bus_nread),
    .nM1(nm1),
    .nRFSH(nrfsh),
    .nBUSAK(nbusak),
    .WRITE_D(bus_wdata),

    `Z80FI_CONN
);

endmodule
