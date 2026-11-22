module VrMPY8x8(RESET, CLK, START, INP, DONE, PROD);
`include "VrMPYdefs.v"
     input RESET, CLK, START;
     input [MPYmsb:0] INP;
     output DONE;
     output [PRODmsb:0] PROD;
     wire [SMmsb:SMlsb] SM;

     VrMPYdata U1 (
        .RESET(RESET),
        .CLK(CLK),
        .START(START),
        .INP(INP),
        .SM(SM),
        .PROD(PROD)
     );

     VrMPYcntr U2 (
        .RESET(RESET),
        .CLK(CLK),
        .START(START),
        .DONE(DONE),
        .SM(SM)
     );
endmodule
