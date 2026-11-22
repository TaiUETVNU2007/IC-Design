`timescale 1ns/100ps
module VrMPY8x8_tb ();
`include "VrMPYdefs.v"

    reg Tclk, RST, START;
    wire DONE;
    reg [MPYmsb:0] INP;
    wire [PRODmsb:0] PROD;
    integer ii, jj, cnt;
    integer total_tests, pass_count;

    // Khởi tạo Device Under Test (DUT)
    VrMPY8x8 UUT(
        .CLK(Tclk),
        .RESET(RST),
        .START(START),
        .INP(INP),
        .DONE(DONE),
        .PROD(PROD)
    );

    // Tạo xung clock chu kỳ 10ns (100MHz)
    always begin
        #5 Tclk = 0;
        #5 Tclk = 1;
    end

    initial begin
        // Thiết lập dump waveform (nếu cần xem dạng sóng trên GTKWave/ModelSim)
        $dumpfile("wave.vcd");
        $dumpvars(0, VrMPY8x8_tb);

        // Khởi tạo tín hiệu ban đầu
        RST = 1;
        START = 0;
        INP = 0;
        total_tests = 0;
        pass_count  = 0;

        $display("==========================================================");
        $display("   BAT DAU KIEM THU BO NHAN 8x8 SHIFT-AND-ADD MULTIPLIER   ");
        $display("==========================================================");

        #115;
        RST = 0; // Giải phóng Reset

        // Quét toàn diện tất cả 256 x 256 = 65,536 trường hợp
        for (ii = 0; ii <= 2**MPYwidth - 1; ii = ii + 1) begin
            for (jj = 0; jj <= 2**MPYwidth - 1; jj = jj + 1) begin
                // Chu kỳ 1: Bật START và đưa thừa số thứ nhất (Multiplicand)
                START = 1;
                INP   = ii;
                #10;

                // Chu kỳ 2: Tắt START và đưa thừa số thứ hai (Multiplier)
                START = 0;
                INP   = jj;
                #10;

                // 8 chu kỳ thực hiện dịch và cộng (Shift-and-Add)
                for (cnt = 0; cnt <= MPYwidth - 1; cnt = cnt + 1)
                    #10;

                total_tests = total_tests + 1;

                // Kiểm tra kết quả
                if (PROD !== (ii * jj)) begin
                    $display("[FAIL] Tai thoi diem %0t: ii=%d * jj=%d | Expected=%d, Got=%d (PROD=%b)",
                             $time, ii, jj, ii * jj, PROD, PROD);
                    $stop;
                end else begin
                    pass_count = pass_count + 1;
                end
            end

            // In tiến độ sau mỗi 64 giá trị của ii để người dùng dễ theo dõi
            if (ii % 64 == 0 && ii != 0) begin
                $display("... Da vuot qua %0d / 65536 test cases ...", total_tests);
            end
        end

        $display("==========================================================");
        $display("   KET QUA: DA VUOT QUA TAT CA %0d / %0d TEST CASES!       ", pass_count, total_tests);
        $display("   TRANG THAI: PASS 100%% HOAN HAO!                         ");
        $display("==========================================================");
        $finish;
    end

endmodule
