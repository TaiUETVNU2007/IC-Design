module VrMPYdata(SM,PROD,RESET,CLK,INP,START);
`include "VrMPYdefs.v"
  input RESET,CLK,START ;
  input [MPYmsb:0] INP;
  input [SMmsb , SMlsb] SM;
  output [PRODmsb:0] PROD;
  reg [MPYmsb:0] MPY , MCND , HPROD ;
  wire [MPYmsb+1:0] F;
  always @(posedge CLK) begin
    if(RESET) begin 
        MPY<=0 ;
        MCND<=0
        HPROD<=0; 
    end
    else if((SM==IDLE)&&(START)) begin
        MCND <=INP;
        HPROD <=0;
    end
    else if(SM==INIT) MPY<=INP;
    else if(SM==RUN) begin
        MPY<={F[0],MPY[MPYmsb:1]};
        HPROD <= F[MPYmsb,1];
    end
  end
  F=(MPY[0])?({1'b0,HPROD}+{1'b0,MCND}) : {1'b0,HPROD};
  assign PROD ={HPROD,MPY};
endmodule