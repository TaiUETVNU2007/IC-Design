module VrMPYcnt(SM,RESET,CLK,MAX);
`include "VrMPYdef"
       input [1:0] SM ;
       input CLK , RESET;
       output MAX;
       reg [CNTRmsb:0] Count ;
       always @(posedge CLK) begin
            if(RESET) count<=0;
            else if(SM==RUN) Count<=Count+1;
            else Count<=0;
       end
       assign MAX=(Count==Maxcnt) ;
endmodule