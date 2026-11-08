module Pick ( X, Y, WINMV, BLKMV, MOVE);
    input [1:9] X, Y;
    input [3:0] WINMV, BLKMV;
    output reg [3:0] MOVE;
    `include "TTTdefs.v"
    function MT; // Determine if cell i,j is empty
    input [1:9] X, Y;
    input [1:0] i, j;
    MT = ~X[(i-1)*3+j] & ~Y[(i-1)*3+j];
    endfunction
    always @ (X or Y or WINMV or BLKMV) begin // If available, pick:
            if (WINMV != NONE) MOVE = WINMV; // winning move
            else if (BLKMV != NONE) MOVE = BLKMV; // else blocking move
            else if (MT(X,Y,2,2)) MOVE = MOVE22; // else center cell
            else if (MT(X,Y,1,1)) MOVE = MOVE11; // else corner cells
            else if (MT(X,Y,1,3)) MOVE = MOVE13;
            else if (MT(X,Y,3,1)) MOVE = MOVE31;
            else if (MT(X,Y,3,3)) MOVE = MOVE33;
            else if (MT(X,Y,1,2)) MOVE = MOVE12; // else side cells
            else if (MT(X,Y,2,1)) MOVE = MOVE21;
            else if (MT(X,Y,2,3)) MOVE = MOVE23;
            else if (MT(X,Y,3,2)) MOVE = MOVE32;
            else MOVE = NONE; // else grid is full
        end
endmodule