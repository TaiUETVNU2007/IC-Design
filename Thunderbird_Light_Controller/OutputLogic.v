`timescale 1ns/1ps

module OutputLogic (
    output reg [5:0] data_out,
    input [2:0] Snext
);
    parameter [2:0] IDLE = 3'b000,
                    L1   = 3'b001,
                    L2   = 3'b011,
                    L3   = 3'b010,
                    R1   = 3'b101,
                    R2   = 3'b111,
                    R3   = 3'b110,
                    LR3  = 3'b100;

    always @(*) begin
        case (Snext)
            IDLE: data_out = 6'b000000;
            L1:   data_out = 6'b001000;
            L2:   data_out = 6'b011000;
            L3:   data_out = 6'b111000;
            R1:   data_out = 6'b000100;
            R2:   data_out = 6'b000110;
            R3:   data_out = 6'b000111;
            LR3:  data_out = 6'b111111;
            default: data_out = 6'b000000;
        endcase
    end
endmodule
