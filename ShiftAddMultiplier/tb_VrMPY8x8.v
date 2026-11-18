`timescale 1ns/100ps
module VrMPY8x8_tb ();
`include "VrMPYdefs.v"
 reg Tclk, RST, START;
 wire DONE;
 reg [MPYmsb:0] INP;
 wire [PRODmsb:0] PROD;
 integer ii, jj, cnt;
 VrMPY8x8 UUT( .CLK(Tclk), .RESET(RST), .START(START), .INP(INP),
 .DONE(DONE), .PROD(PROD) ); // instantiate UUT
 always begin // create free-running test clock with 10 ns period
 #5 Tclk = 0; // 5 ns high
 #5 Tclk = 1; // 5 ns low
 end
 initial begin // What to do starting at time 0
 RST = 1; START = 0; INP = 0; // Initial inputs
 #115; // Wait 15 ns,
 RST = 0; // then apply inputs and check outputs.
 for (ii=0; ii<=2**MPYwidth-1; ii=ii+1) // Try all 256x256 combinations
 for (jj=0; jj<=2**MPYwidth-1; jj=jj+1) begin
 START = 1; INP = ii;
 #10; // Wait for 10 ns
 START = 0; INP = jj;
 #10; // Wait for 10 ns
 for (cnt=0; cnt<=MPYwidth-1; cnt=cnt+1)
 #10; // Shift-and-add MPYwidth times
 if (PROD != ii*jj) begin // Display and stop on error
 $display($time," Error, ii(%d) * jj(%d), expected %d(%b), got %d(%b)",
 ii, jj, ii*jj, ii*jj, PROD, PROD); $stop(1); end;
 end
 $stop(1); // end test
 end
endmodule