module GETMOVE ( X, Y, MOVE );
    input [1:9] X, Y ;
    output [3:0] MOVE;
    wire [3:0] WIN, BLK;
    TwoInRow U1 ( .X(X), .Y(Y), .MOVE(WIN) );
    TwoInRow U2 ( .X(Y), .Y(X), .MOVE(BLK) );
    Pick U3 ( .X(X), .Y(Y), .WINMV(WIN), .BLKMV(BLK), .MOVE(MOVE) );
endmodule