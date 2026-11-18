module MPYcntr(CLK,RESET,START, DONE ,SM);
`include "VrMPYdefs.v"
      input RESET , CLK , START ,DONE ;
      output reg DONE ;
      output [SMmsb, SMlsb] SM;
      wire MAX ;
      wire [SMmsb,SMlsb] SMi;
      VrMPYsm U1 (
          .RESET(RESET),
          .CLK(CLK),
          .START(START),
          .MAX(MAX),
          .SM(SMi),
      );
      VrMPYcnt U2 (
        .RESET(RESET),
        .CLK(CLK),
        .MAX(MAX),
        .SM(SMi),
      );
      always @(*) begin
          if(RESET) DONE<=1'b0;
          else if ((SMi==RUN && MAX==1)||(SMi==WAIT)) DONE<=1'b1;
          else DONE<=1'b0;
      end
      assign SM=SMi;
endmodule
