
module traffic_timer (
    input  wire       clk,       
    input  wire       rst,       // Reset toàn cục (Asynchronous Active-High)
    input  wire       en_1hz,    // Clock enable 1Hz (1 nhịp = 1 giây)
    input  wire       TMRESET,  
    output wire       TMSHORT,   
    output wire       TMLONG     
);
    parameter TIME_SHORT = 8'd5;   
    parameter TIME_LONG  = 8'd60;  // 60 giây xanh tối đa khi gia hạn liên tục
    reg [7:0] timer_count;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            timer_count <= 8'd0;
        end 
        else if (TMRESET) begin
            timer_count <= 8'd0; // Xóa bộ đếm về 0 ngay khi FSM chuyển pha
        end 
        else if (en_1hz) begin
            if (timer_count < TIME_LONG)
                timer_count <= timer_count + 1'b1; // Tăng đếm mỗi giây, dừng ở 60 tránh tràn
        end
    end

    // Khối so sánh tổ hợp tạo tín hiệu cờ gửi về FSM
    assign TMSHORT = (timer_count >= TIME_SHORT);
    assign TMLONG  = (timer_count >= TIME_LONG);

endmodule
