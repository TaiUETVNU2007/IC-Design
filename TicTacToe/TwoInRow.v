module TwoInRow ( X, Y, MOVE );
    input [1:9] X, Y;
    output reg [3:0] MOVE;
    reg G11, G12, G13, G21, G22, G23, G31, G32, G33;
    `include "TTTdefs.v"
    function R; // Find 2-in-row with empty cell i,j
    input [1:9] X, Y;
    input [1:0] i, j;
    integer jj;
    begin
    R = 1'b1;
    for (jj=1; jj<=3; jj=jj+1)
    if (jj==j) R = R & ~X[(i-1)*3+jj] & ~Y[(i-1)*3+jj];
    else R = R & X[(i-1)*3+jj];
    end
    endfunction

    function C; // Find 2-in-column with empty cell i,j
    input [1:9] X, Y;
    input [1:0] i, j;
    integer ii;
    begin
    C = 1'b1;
    for (ii=1; ii<=3; ii=ii+1)
    if (ii==i) C = C & ~X[(ii-1)*3+j] & ~Y[(ii-1)*3+j];
    else C = C & X[(ii-1)*3+j];
    end
    endfunction
    function D; // Find 2-in-diagonal with empty cell i,j
    input [1:9] X, Y; // This is for 11, 22, 33 diagonal
    input [1:0] i, j;
    integer ii;
    begin
    D = 1'b1;
    for (ii=1; ii<=3; ii=ii+1)
    if (ii==i) D = D & ~X[(ii-1)*3+ii] & ~Y[(ii-1)*3+ii];
    else D = D & X[(ii-1)*3+ii];
    end
    endfunction
    function E; // Find 2-in-diagonal with empty cell i,j
    input [1:9] X, Y; // This is for 13, 22, 31 diagonal
    input [1:0] i, j;
    integer ii;
    begin
    E = 1'b1;
    for (ii=1; ii<=3; ii=ii+1)
    if (ii==i) E = E & ~X[(ii-1)*3+4-ii] & ~Y[(ii-1)*3+4-ii];
    else E = E & X[(ii-1)*3+4-ii];
    end
    endfunction
    always @ (X or Y) begin
    G11 = R(X,Y,1,1) | C(X,Y,1,1) | D(X,Y,1,1);
    G12 = R(X,Y,1,2) | C(X,Y,1,2);
    G13 = R(X,Y,1,3) | C(X,Y,1,3) | E(X,Y,1,3);
    G21 = R(X,Y,2,1) | C(X,Y,2,1);
    G22 = R(X,Y,2,2) | C(X,Y,2,2) | D(X,Y,2,2) | E(X,Y,2,2);
    G23 = R(X,Y,2,3) | C(X,Y,2,3);
    G31 = R(X,Y,3,1) | C(X,Y,3,1) | E(X,Y,3,1);
    G32 = R(X,Y,3,2) | C(X,Y,3,2);
    G33 = R(X,Y,3,3) | C(X,Y,3,3) | D(X,Y,3,3);
    if (G11) MOVE = MOVE11;
    else if (G12) MOVE = MOVE12;
    else if (G13) MOVE = MOVE13;
    else if (G21) MOVE = MOVE21;
    else if (G22) MOVE = MOVE22;
    else if (G23) MOVE = MOVE23;
    else if (G31) MOVE = MOVE31;
    else if (G32) MOVE = MOVE32;
    else if (G33) MOVE = MOVE33;
    else MOVE = NONE;
    end
endmodule