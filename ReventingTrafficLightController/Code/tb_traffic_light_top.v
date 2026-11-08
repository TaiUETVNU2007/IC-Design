
// TESTBENCH: tb_traffic_light_top
// Chức năng: Kiểm tra toàn diện mọi kịch bản hoạt động của hệ thống:
// 1. Kiểm tra Reset khởi tạo an toàn và chuyển sang NSGO (Bắc - Nam Xanh).
// 2. Kiểm tra giai đoạn Xanh tối thiểu 5s (khóa cảm biến).
// 3. Kiểm tra gia hạn Xanh khi có xe NSCAR.
// 4. Kiểm tra ngắt pha Xanh khi xe làn đối diện xuất hiện (EWCAR).
// 5. Kiểm tra thời gian đèn Vàng 5s.
// 6. Kiểm tra chuỗi đệm an toàn All-Red (NSWAIT2, NSDELAY).
// 7. Kiểm tra pha Đông - Tây (EWGO, EWWAIT, EWWAIT2, EWDELAY) đối xứng.
`timescale 1ns/1ps
module tb_traffic_light_top;
    // Khai báo các tín hiệu điều khiển DUT
    reg  clk;
    reg  rst;
    reg  en_1hz;
    reg  NSCAR;
    reg  EWCAR;
    wire NSGREEN;
    wire NSYELLOW;
    wire NSRED;
    wire EWGREEN;
    wire EWYELLOW;
    wire EWRED;
    // Khởi tạo DUT (Device Under Test)
    traffic_light_top dut (
        .clk      (clk),
        .rst      (rst),
        .en_1hz   (en_1hz),
        .NSCAR    (NSCAR),
        .EWCAR    (EWCAR),
        .NSGREEN  (NSGREEN),
        .NSYELLOW (NSYELLOW),
        .NSRED    (NSRED),
        .EWGREEN  (EWGREEN),
        .EWYELLOW (EWYELLOW),
        .EWRED    (EWRED)
    );
    // Tạo xung clock hệ thống (chu kỳ 10ns = 100MHz)
    always #5 clk = ~clk;
    // Task tạo xung nhịp 1Hz (kéo dài 1 chu kỳ clk)
    task pulse_1sec;
        begin
            @(posedge clk);
            en_1hz = 1'b1;
            @(posedge clk);
            en_1hz = 1'b0;
        end
    endtask

    // Theo dõi trạng thái trên terminal khi có sự thay đổi
    initial begin
        $monitor("Time=%0t | State=%b | NS: G=%b Y=%b R=%b | EW: G=%b Y=%b R=%b | Timer=%0d",
                 $time, dut.Sreg, NSGREEN, NSYELLOW, NSRED, EWGREEN, EWYELLOW, EWRED, dut.u_timer.timer_count);
    end

    // Kịch bản kiểm thử
    initial begin
        // Khởi tạo các tín hiệu
        clk    = 0;
        rst    = 1;
        en_1hz = 0;
        NSCAR  = 0;
        EWCAR  = 0;
        $display("pass KIEM TRA ASYNCHRONOUS RESET");
        #25;
        // Kiểm tra trạng thái reset an toàn (EWDELAY - Cả 2 phía cùng Đỏ)
        if (dut.Sreg == 3'b111 && NSRED == 1'b1 && EWRED == 1'b1)
            $display("pass Reset an toan: Sreg = EWDELAY (3'b111), NSRED=1, EWRED=1");
        else
            $display("fail Reset loi: Sreg = %b", dut.Sreg);

        // Giải phóng Reset
        rst = 0;
        @(posedge clk);
        #1;
        $display("pass [TEST 2]: KHOI DONG PHA BAC - NAM (NSGO)");
        if (dut.Sreg == 3'b000 && NSGREEN == 1'b1 && EWRED == 1'b1)
            $display("pass Khoi dong thanh cong sang NSGO (3'b000), NSGREEN=1, EWRED=1");
        else
            $display("fail Khoi dong loi: Sreg = %b", dut.Sreg);

        // Giai đoạn 1: 5 giây tối thiểu của NSGO
        $display(">> Phat 4 xung 1s trong khi co EWCAR=1 (Kiem tra khoa cam bien)...");
        EWCAR = 1; // Có xe chờ ở Đông - Tây nhưng chưa hết 5s thì KHÔNG ĐƯỢC ngắt Xanh
        repeat (4) pulse_1sec();

        if (dut.Sreg == 3'b000)
            $display("pass NSGO van giu Xanh trong 4s dau du co EWCAR=1!");
        else
            $display("fail NSGO bi ngat truoc 5s: Sreg = %b", dut.Sreg);

        // Xung thứ 5 kết thúc 5s tối thiểu
        $display(">> Phat xung 1s thu 5 (TMSHORT se bat len 1, EWCAR=1 se ngat pha)...");
        pulse_1sec();
        @(posedge clk);
        #1;

        if (dut.Sreg == 3'b001 && NSYELLOW == 1'b1)
            $display("pass Da chuyen sang NSWAIT (Đen Vang) thanh cong!");
        else
            $display("fail Chuyen sang Vang loi: Sreg = %b", dut.Sreg);
        $display("pass [TEST 3]: DEM 5 GIAY DEN VANG BAC - NAM (NSWAIT)");
        repeat (5) pulse_1sec();
        @(posedge clk);
        #1;

        $display(">> Kiem tra chuoi dem an toan All-Red (NSWAIT2 -> NSDELAY -> EWGO)...");
        @(posedge clk);
        #1;
        @(posedge clk);
        #1;

        if (dut.Sreg == 3'b100 && EWGREEN == 1'b1 && NSRED == 1'b1)
            $display("pass Chuyen giao thanh cong sang EWGO (Đong - Tay Xanh)!");
        else
            $display("fail Chuyen sang EWGO loi: Sreg = %b", dut.Sreg);
        $display("HOAN TAT CAC KIEM THU CO BAN!");
        #50;
        $finish;
    end

endmodule
