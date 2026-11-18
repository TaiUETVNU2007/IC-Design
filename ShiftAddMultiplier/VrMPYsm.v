module VrMPYsm (CLK , RESET , START , MAX ,SM);
`include "VrMPYdefs.v"
     output [1:0] SM ;
     input CLK, RESET ,START ,MAX ;
     reg [1:0] Scurrent , Sreg ;
     always @(posedge CLK) begin
         if(RESET) Sreg<=IDLE ;
         else Sreg<=Snext;
     end
     always @(*) begin
        case(Sreg) 
            IDLE: if(START) Scurrent <=INIT ;
                  else      Scurrent <=IDLE;
            INIT: Scurrent<=RUN;
            RUN: if(MAX&&~START) Scurrent <=WAIT ;
                 else Scurrent <=RUN ;
            WAIT: if(START) Scurrent<=IDLE;
                  else Scurrent<=WAIT;          
     end
     assign SM=Sreg;
endmodule

