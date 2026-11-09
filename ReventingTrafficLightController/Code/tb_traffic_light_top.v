`timescale 1ns/1ps

module tb_traffic_light_top;

    reg clk;
    reg rst;
    reg en_1hz;
    reg NSCAR;
    reg EWCAR;

    wire NSGREEN;
    wire NSYELLOW;
    wire NSRED;
    wire EWGREEN;
    wire EWYELLOW;
    wire EWRED;

    // Khoi tao DUT
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

    // Tao xung clock he thong chu ky 10ns
    always #5 clk = ~clk;

    // Xuat file waveform .vcd de xem bang GTKWave
    initial begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, tb_traffic_light_top);
    end

    // Task tao 1 nhip xung 1s (dung suon duong posedge)
    task pulse_1sec;
        begin
            @(posedge clk);
            #1;
            en_1hz = 1'b1;
            @(posedge clk);
            #1;
            en_1hz = 1'b0;
        end
    endtask

    initial begin
        // Khoi tao gia tri ban dau
        clk    = 0;
        rst    = 1;
        en_1hz = 0;
        NSCAR  = 0;
        EWCAR  = 0;

        $display("=== BAT DAU MO PHONG TRAFFIC LIGHT CONTROLLER ===");

        // 1. Kiem tra Reset
        #20;
        $display("[t=%0t ns] Reset he thong -> Sreg=%b (All-Red: NS_R=%b, EW_R=%b)", $time, dut.Sreg, NSRED, EWRED);
        rst = 0;
        @(posedge clk); #1;
        $display("[t=%0t ns] Khoi dong -> Sreg=%b (Bac - Nam Xanh: NS_G=%b, EW_R=%b)", $time, dut.Sreg, NSGREEN, EWRED);

        // 2. Giai doan 5s xanh toi thieu cua Bac - Nam (khoa cam bien)
        EWCAR = 1; // Co xe ben Dong - Tay cho nhung chua het 5s khong duoc ngat Xanh
        repeat (5) pulse_1sec();
        $display("[t=%0t ns] Het 5s xanh NS -> Sreg=%b, timer=%0d", $time, dut.Sreg, dut.u_timer.timer_count);

        // 3. Chuyen sang Den Vang Bac - Nam (5 giay)
        @(posedge clk); #1;
        $display("[t=%0t ns] Chuyen sang Vang NS -> Sreg=%b (NS_Y=%b, EW_R=%b)", $time, dut.Sreg, NSYELLOW, EWRED);
        repeat (5) pulse_1sec();
        $display("[t=%0t ns] Het 5s vang NS -> Sreg=%b, timer=%0d", $time, dut.Sreg, dut.u_timer.timer_count);

        // 4. Chuoi dem an toan All-Red truoc khi sang Dong - Tay
        @(posedge clk); #1;
        $display("[t=%0t ns] Dem an toan 1 -> Sreg=%b (All-Red: NS_R=%b, EW_R=%b)", $time, dut.Sreg, NSRED, EWRED);
        @(posedge clk); #1;
        $display("[t=%0t ns] Dem an toan 2 -> Sreg=%b (All-Red: NS_R=%b, EW_R=%b)", $time, dut.Sreg, NSRED, EWRED);

        // 5. Chuyen giao sang Dong - Tay Xanh (5 giay toi thieu)
        @(posedge clk); #1;
        $display("[t=%0t ns] Dong - Tay Xanh -> Sreg=%b (EW_G=%b, NS_R=%b)", $time, dut.Sreg, EWGREEN, NSRED);
        NSCAR = 1; // Co xe ben Bac - Nam cho
        repeat (5) pulse_1sec();
        $display("[t=%0t ns] Het 5s xanh EW -> Sreg=%b, timer=%0d", $time, dut.Sreg, dut.u_timer.timer_count);

        // 6. Chuyen sang Den Vang Dong - Tay (5 giay)
        @(posedge clk); #1;
        $display("[t=%0t ns] Chuyen sang Vang EW -> Sreg=%b (EW_Y=%b, NS_R=%b)", $time, dut.Sreg, EWYELLOW, NSRED);
        repeat (5) pulse_1sec();
        $display("[t=%0t ns] Het 5s vang EW -> Sreg=%b, timer=%0d", $time, dut.Sreg, dut.u_timer.timer_count);

        // 7. Chuoi dem an toan All-Red truoc khi quay lai Bac - Nam
        @(posedge clk); #1;
        $display("[t=%0t ns] Dem an toan 1 -> Sreg=%b (All-Red: NS_R=%b, EW_R=%b)", $time, dut.Sreg, NSRED, EWRED);
        @(posedge clk); #1;
        $display("[t=%0t ns] Dem an toan 2 -> Sreg=%b (All-Red: NS_R=%b, EW_R=%b)", $time, dut.Sreg, NSRED, EWRED);

        // 8. Quay tro lai Bac - Nam Xanh (hoan tat 1 vong chu trinh)
        @(posedge clk); #1;
        $display("[t=%0t ns] Hoan tat 1 vong -> Sreg=%b (Bac - Nam Xanh tro lai)", $time, dut.Sreg);

        $display("=== HOAN TAT 1 VONG MO PHONG THANH CONG ===");
        #30;
        $finish;
    end

endmodule
