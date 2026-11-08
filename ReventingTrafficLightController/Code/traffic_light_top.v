
module traffic_light_top (
    input  wire clk,        // Xung nhịp hệ thống chính (System Clock)
    input  wire rst,        // Tín hiệu Reset cứng toàn cục (Asynchronous Active-High)
    input  wire en_1hz,     // Xung Clock Enable 1Hz điều khiển nhịp đếm giây
    input  wire NSCAR,      // Cảm biến xe làn Bắc - Nam (1: Có xe, 0: Không xe)
    input  wire EWCAR,      // Cảm biến xe làn Đông - Tây (1: Có xe, 0: Không xe)
    output wire NSGREEN,    // Đèn Xanh làn Bắc - Nam
    output wire NSYELLOW,   // Đèn Vàng làn Bắc - Nam
    output wire NSRED,      // Đèn Đỏ làn Bắc - Nam
    output wire EWGREEN,    // Đèn Xanh làn Đông - Tây
    output wire EWYELLOW,   // Đèn Vàng làn Đông - Tây
    output wire EWRED       // Đèn Đỏ làn Đông - Tây
);

    // Bus và dây nối tín hiệu nội bộ giữa các Module
    wire [2:0] Sreg;       // Trạng thái hiện tại từ State Register
    wire [2:0] Snext;      // Trạng thái kế tiếp từ Next State Logic
    wire       TMRESET;    // Xung reset bộ đếm từ Next State Logic đến Timer
    wire       TMSHORT;    // Cờ báo đạt mốc 5s từ Timer đến Next State Logic
    wire       TMLONG;     // Cờ báo chạm trần 60s từ Timer đến Next State Logic
    traffic_timer u_timer (
        .clk     (clk),
        .rst     (rst),
        .en_1hz  (en_1hz),
        .TMRESET (TMRESET),
        .TMSHORT (TMSHORT),
        .TMLONG  (TMLONG)
    );
    // 2. Khối Control Unit: Thanh ghi trạng thái (Sequential Logic)
    state_register u_state_reg (
        .clk   (clk),
        .rst   (rst),
        .Snext (Snext),
        .Sreg  (Sreg)
    );
    next_state_logic u_next_state (
        .Sreg    (Sreg),
        .NSCAR   (NSCAR),
        .EWCAR   (EWCAR),
        .TMSHORT (TMSHORT),
        .TMLONG  (TMLONG),
        .Snext   (Snext),
        .TMRESET (TMRESET)
    );
    // 4. Khối Control Unit: Logic giải mã ngõ ra đèn (Moore Output Logic)
    output_logic u_output (
        .Sreg     (Sreg),
        .NSGREEN  (NSGREEN),
        .NSYELLOW (NSYELLOW),
        .NSRED    (NSRED),
        .EWGREEN  (EWGREEN),
        .EWYELLOW (EWYELLOW),
        .EWRED    (EWRED)
    );

endmodule
