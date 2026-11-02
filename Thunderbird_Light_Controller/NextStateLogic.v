`timescale 1ns/1ps

module NextStateLogic (
    input [2:0] Scurrent,
    input haz,
    input left,
    input right,
    output reg [2:0] Snext
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
        case (Scurrent)
            IDLE: begin
                if (haz || (left && right))
                    Snext = LR3;
                else if (left)
                    Snext = L1;
                else if (right)
                    Snext = R1;
                else
                    Snext = IDLE;
            end
            // Xi nhan trai
            L1:  Snext = L2;
            L2:  Snext = L3;
            L3:  Snext = IDLE;

            // Xi nhan phai
            R1:  Snext = R2;
            R2:  Snext = R3;
            R3:  Snext = IDLE;

            // Khan cap (Hazard)
            LR3: Snext = IDLE;

            default: Snext = IDLE;
        endcase
    end
endmodule
