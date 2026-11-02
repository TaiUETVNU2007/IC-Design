`timescale 1ns/1ps

module StateMemory(
    input CLOCK,
    input [2:0] Snext,
    input reset,
    output reg [2:0] Scurrent
);
    parameter [2:0] IDLE = 3'b000,
                    L1   = 3'b001,
                    L2   = 3'b011,
                    L3   = 3'b010,
                    R1   = 3'b101,
                    R2   = 3'b111,
                    R3   = 3'b110,
                    LR3  = 3'b100;

    always @(posedge CLOCK or posedge reset) begin
        if (reset == 1'b1) begin
            Scurrent <= IDLE;
        end
        else begin
            Scurrent <= Snext;
        end
    end
endmodule
