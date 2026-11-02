`timescale 1ns/1ps

module module_Tbird_Light(
    input haz,
    input right,
    input left,
    input CLOCK,
    input RESET,
    output wire [5:0] data_out
);
    parameter [2:0] IDLE = 3'b000,
                    L1   = 3'b001,
                    L2   = 3'b011,
                    L3   = 3'b010,
                    R1   = 3'b101,
                    R2   = 3'b111,
                    R3   = 3'b110,
                    LR3  = 3'b100;

    wire [2:0] Snext, Scurrent;

    NextStateLogic U1(
        .Scurrent(Scurrent),
        .haz(haz),
        .right(right),
        .left(left),
        .Snext(Snext)
    );

    StateMemory U2(
        .reset(RESET),
        .CLOCK(CLOCK),
        .Snext(Snext),
        .Scurrent(Scurrent)
    );

    OutputLogic U3(
        .Snext(Scurrent),
        .data_out(data_out)
    );
endmodule
