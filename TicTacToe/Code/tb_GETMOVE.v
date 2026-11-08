`timescale 1ns/1ps

module tb_GETMOVE;
    reg  [1:9] X;
    reg  [1:9] Y;
    wire [3:0] MOVE;

    // Khởi tạo Device Under Test (DUT)
    GETMOVE dut (
        .X(X),
        .Y(Y),
        .MOVE(MOVE)
    );

    // Hàm chuyển mã MOVE (4-bit) sang chuỗi text để dễ đọc log
    function [55:0] move_to_str;
        input [3:0] m;
        case (m)
            4'b1000: move_to_str = "MOVE11";
            4'b0100: move_to_str = "MOVE12";
            4'b0010: move_to_str = "MOVE13";
            4'b0001: move_to_str = "MOVE21";
            4'b1100: move_to_str = "MOVE22";
            4'b0111: move_to_str = "MOVE23";
            4'b1011: move_to_str = "MOVE31";
            4'b1101: move_to_str = "MOVE32";
            4'b1110: move_to_str = "MOVE33";
            default: move_to_str = "NONE  ";
        endcase
    endfunction

    initial begin
        $display("==================================================================");
        $display("   BAT DAU TEST MO PHONG GETMOVE (TIC-TAC-TOE MOVE PICKER)        ");
        $display("==================================================================");

        // Kịch bản 1: Bàn cờ trống -> Ưu tiên đánh ô trung tâm (2,2)
        X = 9'b000000000;
        Y = 9'b000000000;
        #20;
        $display("[Test 1 - Ban co trong]         X=%b Y=%b => MOVE = %b (%s) [Expected: MOVE22]",
                 X, Y, MOVE, move_to_str(MOVE));

        // Kịch bản 2: Ô giữa (2,2) đã bị Y chiếm -> Đánh ô góc (1,1)
        X = 9'b000000000;
        Y = 9'b000010000; // ô 5 (row 2, col 2)
        #20;
        $display("[Test 2 - O giua da bi chiem]   X=%b Y=%b => MOVE = %b (%s) [Expected: MOVE11]",
                 X, Y, MOVE, move_to_str(MOVE));

        // Kịch bản 3: X có 2 quân hàng 1 (ô 1, ô 2), ô 3 trống -> X THẮNG (WIN) ở ô 3 (1,3)
        // Lưu ý: Vector [1:9]: bit 1=1, bit 2=1, bit 3=0
        X = 9'b110000000;
        Y = 9'b000010000;
        #20;
        $display("[Test 3 - X sap thang hang 1]   X=%b Y=%b => MOVE = %b (%s) [Expected: MOVE13]",
                 X, Y, MOVE, move_to_str(MOVE));

        // Kịch bản 4: Y sắp thắng hàng 2 (ô 4, ô 5), ô 6 trống -> X phải CHẶN (BLOCK) ở ô 6 (2,3)
        X = 9'b100000000; // X o o 1
        Y = 9'b000110000; // Y o o 4, o 5
        #20;
        $display("[Test 4 - Y sap thang -> CHAN]  X=%b Y=%b => MOVE = %b (%s) [Expected: MOVE23]",
                 X, Y, MOVE, move_to_str(MOVE));

        // Kịch bản 5: Bàn cờ đã đầy -> Không còn nước đi (NONE)
        X = 9'b101010101;
        Y = 9'b010101010;
        #20;
        $display("[Test 5 - Ban co da day]        X=%b Y=%b => MOVE = %b (%s) [Expected: NONE]",
                 X, Y, MOVE, move_to_str(MOVE));

        $display("==================================================================");
        $display("   MO PHONG HOAN TAT THANH CONG!                                  ");
        $display("==================================================================");
        #50;
        $finish;
    end

endmodule
