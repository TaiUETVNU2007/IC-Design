`timescale 1ns/1ps

module tb_Tbird_Light;

    // Tin hieu dieu khien va quan sat DUT
    reg        CLOCK;
    reg        RESET;
    reg        haz;
    reg        left;
    reg        right;
    wire [5:0] data_out;

    // Ma hoa trang thai theo Table 9-7 
    localparam [2:0] IDLE = 3'b000,
                     L1   = 3'b001,
                     L2   = 3'b011,
                     L3   = 3'b010,
                     R1   = 3'b101,
                     R2   = 3'b111,
                     R3   = 3'b110,
                     LR3  = 3'b100;

    // Gia tri ngo ra {LC, LB, LA, RA, RB, RC} 
    localparam [5:0] OUT_IDLE = 6'b000000,
                     OUT_L1   = 6'b001000,
                     OUT_L2   = 6'b011000,
                     OUT_L3   = 6'b111000,
                     OUT_R1   = 6'b000100,
                     OUT_R2   = 6'b000110,
                     OUT_R3   = 6'b000111,
                     OUT_LR3  = 6'b111111;

    integer pass_count;
    integer fail_count;

    // Khoi tao DUT
    module_Tbird_Light dut (
        .haz      (haz),
        .right    (right),
        .left     (left),
        .CLOCK    (CLOCK),
        .RESET    (RESET),
        .data_out (data_out)
    );

    // Chuoi ky tu hien thi ten trang thai tren Waveform & Log
    reg [39:0] state_ascii;
    always @(*) begin
        case (dut.Scurrent)
            IDLE:    state_ascii = "IDLE ";
            L1:      state_ascii = "L1   ";
            L2:      state_ascii = "L2   ";
            L3:      state_ascii = "L3   ";
            R1:      state_ascii = "R1   ";
            R2:      state_ascii = "R2   ";
            R3:      state_ascii = "R3   ";
            LR3:     state_ascii = "LR3  ";
            default: state_ascii = "UNKN ";
        endcase
    end

    // Tao xung nhịp CLOCK 100MHz (chu ky 10ns)
    initial begin
        CLOCK = 1'b0;
        forever #5 CLOCK = ~CLOCK;
    end

    // Dump waveform cho SimVision (Xcelium) va GTKWave (VCD)
    initial begin
        $timeformat(-9, 0, " ns", 6);
        `ifdef XCELIUM
            $shm_open("waves_tbird.shm");
            $shm_probe("ACTMF");
        `endif
        $dumpfile("tbird_light.vcd");
        $dumpvars(0, tb_Tbird_Light);
    end

    // Task lai ngo vao tai suon am CLOCK de tranh race condition
    task drive_inputs(
        input reg i_haz,
        input reg i_left,
        input reg i_right
    );
        begin
            @(negedge CLOCK);
            haz   = i_haz;
            left  = i_left;
            right = i_right;
        end
    endtask

    // Task tu dong kiem tra (Self-checking) trang thai & ngo ra sau suon duong CLOCK
    task step_and_check(
        input [2:0]   exp_state,
        input [5:0]   exp_out,
        input [511:0] test_desc
    );
        begin
            @(posedge CLOCK);
            #1; // Cho tin hieu on dinh sau suon xung
            if ((dut.Scurrent === exp_state) && (data_out === exp_out)) begin
                pass_count = pass_count + 1;
                $display("[PASS] t=%t | in={H:%b L:%b R:%b} | state=%s (%b) | out=%b | %0s",
                         $time, haz, left, right, state_ascii, dut.Scurrent, data_out, test_desc);
            end
            else begin
                fail_count = fail_count + 1;
                $display("[FAIL] t=%t | in={H:%b L:%b R:%b} | GOT state=%b out=%b | EXP state=%b out=%b | %0s",
                         $time, haz, left, right, dut.Scurrent, data_out, exp_state, exp_out, test_desc);
            end
        end
    endtask

    // Task kiem tra ngay lap tuc (dung cho Asynchronous Reset)
    // 1 vài trường hợp check Toggle Coverage
    task check_immediate(
        input [2:0]   exp_state,
        input [5:0]   exp_out,
        input [511:0] test_desc
    );
        begin
            #1;
            if ((dut.Scurrent === exp_state) && (data_out === exp_out)) begin
                pass_count = pass_count + 1;
                $display("[PASS] t=%t | ASYNC CHECK   | state=%s (%b) | out=%b | %0s",
                         $time, state_ascii, dut.Scurrent, data_out, test_desc);
            end
            else begin
                fail_count = fail_count + 1;
                $display("[FAIL] t=%t | ASYNC CHECK   | GOT state=%b out=%b | EXP state=%b out=%b | %0s",
                         $time, dut.Scurrent, data_out, exp_state, exp_out, test_desc);
            end
        end
    endtask

    // Kich ban kiem thu toan dien (Directed + Full Coverage Closure)
    initial begin
        pass_count = 0;
        fail_count = 0;

        // Khoi tao RESET = 0 -> 1 -> 0 de dat 100% Toggle Coverage tren tin hieu RESET
        RESET = 1'b0;
        haz   = 1'b0;
        left  = 1'b0;
        right = 1'b0;
        #2;
        RESET = 1'b1;
        check_immediate(IDLE, OUT_IDLE, "Power-on Async Reset -> IDLE");
        @(negedge CLOCK);
        RESET = 1'b0;

        $display("\n================ TEST 1: GIU NGUYEN TRANG THAI IDLE (000) ================");
        drive_inputs(1'b0, 1'b0, 1'b0);
        step_and_check(IDLE, OUT_IDLE, "IDLE hold when {haz,left,right}=000");
        step_and_check(IDLE, OUT_IDLE, "IDLE hold 2nd cycle");

        $display("\n================ TEST 2: CHU TRINH XI NHAN TRAI (LEFT = 010) =============");
        drive_inputs(1'b0, 1'b1, 1'b0);
        step_and_check(L1,   OUT_L1,   "IDLE -> L1 (LA on)");
        drive_inputs(1'b0, 1'b0, 1'b0); // Nha nut, chu trinh van phai chay het L2 -> L3 -> IDLE
        step_and_check(L2,   OUT_L2,   "L1 -> L2 (LB, LA on)");
        step_and_check(L3,   OUT_L3,   "L2 -> L3 (LC, LB, LA on)");
        step_and_check(IDLE, OUT_IDLE, "L3 -> IDLE (all off)");

        $display("\n================ TEST 3: CHU TRINH XI NHAN PHAI (RIGHT = 001) ============");
        drive_inputs(1'b0, 1'b0, 1'b1);
        step_and_check(R1,   OUT_R1,   "IDLE -> R1 (RA on)");
        drive_inputs(1'b0, 1'b0, 1'b0);
        step_and_check(R2,   OUT_R2,   "R1 -> R2 (RA, RB on)");
        step_and_check(R3,   OUT_R3,   "R2 -> R3 (RA, RB, RC on)");
        step_and_check(IDLE, OUT_IDLE, "R3 -> IDLE (all off)");

        $display("\n================ TEST 4: KHAN CAP HAZARD DOC LAP (HAZ = 100) =============");
        drive_inputs(1'b1, 1'b0, 1'b0);
        step_and_check(LR3,  OUT_LR3,  "IDLE -> LR3 via haz=1 (all 6 lights on)");
        // Giu haz=1 de kiem tra nhap nhay IDLE <-> LR3 lien tuc
        step_and_check(IDLE, OUT_IDLE, "LR3 -> IDLE (blink off phase)");
        step_and_check(LR3,  OUT_LR3,  "IDLE -> LR3 (blink on phase)");
        drive_inputs(1'b0, 1'b0, 1'b0);
        step_and_check(IDLE, OUT_IDLE, "LR3 -> IDLE (hazard released)");

        $display("\n================ TEST 5: DONG THOI LEFT & RIGHT (011 -> HAZARD) ==========");
        // Kiem tra nhanh FEC: haz=0, left=1, right=1 trong bieu thuc haz || (left && right)
        drive_inputs(1'b0, 1'b1, 1'b1);
        step_and_check(LR3,  OUT_LR3,  "IDLE -> LR3 when left=1 & right=1 (haz=0)");
        drive_inputs(1'b0, 1'b0, 1'b0);
        step_and_check(IDLE, OUT_IDLE, "LR3 -> IDLE");

        $display("\n================ TEST 6: DO UU TIEN HAZ VOI CAC TO HOP CON LAI ===========");
        // {haz, left, right} = 101
        drive_inputs(1'b1, 1'b0, 1'b1);
        step_and_check(LR3,  OUT_LR3,  "IDLE -> LR3 priority {1,0,1}");
        drive_inputs(1'b0, 1'b0, 1'b0);
        step_and_check(IDLE, OUT_IDLE, "LR3 -> IDLE");

        // {haz, left, right} = 110
        drive_inputs(1'b1, 1'b1, 1'b0);
        step_and_check(LR3,  OUT_LR3,  "IDLE -> LR3 priority {1,1,0}");
        drive_inputs(1'b0, 1'b0, 1'b0);
        step_and_check(IDLE, OUT_IDLE, "LR3 -> IDLE");

        // {haz, left, right} = 111
        drive_inputs(1'b1, 1'b1, 1'b1);
        step_and_check(LR3,  OUT_LR3,  "IDLE -> LR3 priority {1,1,1}");
        drive_inputs(1'b0, 1'b0, 1'b0);
        step_and_check(IDLE, OUT_IDLE, "LR3 -> IDLE");

        $display("\n================ TEST 7: KHONG NGAT QUANG GIUA CHU TRINH XI NHAN =========");
        // Dang xi nhan trai (L1), bat haz=1 & right=1 van phai chay du L2 -> L3 -> IDLE roi moi sang LR3
        drive_inputs(1'b0, 1'b1, 1'b0);
        step_and_check(L1,   OUT_L1,   "Start Left Turn -> L1");
        drive_inputs(1'b1, 1'b0, 1'b1); // Gay nhieu giua chu ky
        step_and_check(L2,   OUT_L2,   "L1 -> L2 uninterrupted despite haz=1, right=1");
        step_and_check(L3,   OUT_L3,   "L2 -> L3 uninterrupted despite haz=1, right=1");
        step_and_check(IDLE, OUT_IDLE, "L3 -> IDLE completes Left cycle");
        step_and_check(LR3,  OUT_LR3,  "IDLE -> LR3 takes effect after cycle finishes");
        drive_inputs(1'b0, 1'b0, 1'b0);
        step_and_check(IDLE, OUT_IDLE, "LR3 -> IDLE");

        // Tuong tu cho chu trinh xi nhan phai
        drive_inputs(1'b0, 1'b0, 1'b1);
        step_and_check(R1,   OUT_R1,   "Start Right Turn -> R1");
        drive_inputs(1'b0, 1'b1, 1'b0); // Bat left giua chu ky R1
        step_and_check(R2,   OUT_R2,   "R1 -> R2 uninterrupted despite left=1");
        step_and_check(R3,   OUT_R3,   "R2 -> R3 uninterrupted despite left=1");
        step_and_check(IDLE, OUT_IDLE, "R3 -> IDLE completes Right cycle");
        step_and_check(L1,   OUT_L1,   "IDLE -> L1 takes effect after Right cycle");
        drive_inputs(1'b0, 1'b0, 1'b0);
        step_and_check(L2,   OUT_L2,   "L1 -> L2");
        step_and_check(L3,   OUT_L3,   "L2 -> L3");
        step_and_check(IDLE, OUT_IDLE, "L3 -> IDLE");

        $display("\n================ TEST 8: ASYNC RESET GIUA CAC TRANG THAI DONG ============");
        // Async reset khi dang o L2
        drive_inputs(1'b0, 1'b1, 1'b0);
        step_and_check(L1,   OUT_L1,   "Enter L1 before async reset test");
        step_and_check(L2,   OUT_L2,   "Enter L2 before async reset test");
        #2;
        RESET = 1'b1;
        check_immediate(IDLE, OUT_IDLE, "Async Reset from L2 -> IDLE immediately");
        @(negedge CLOCK);
        RESET = 1'b0;
        haz   = 1'b0;
        left  = 1'b0;
        right = 1'b0;

        // Async reset khi dang o R2
        drive_inputs(1'b0, 1'b0, 1'b1);
        step_and_check(R1,   OUT_R1,   "Enter R1 before async reset test");
        step_and_check(R2,   OUT_R2,   "Enter R2 before async reset test");
        #2;
        RESET = 1'b1;
        check_immediate(IDLE, OUT_IDLE, "Async Reset from R2 -> IDLE immediately");
        @(negedge CLOCK);
        RESET = 1'b0;
        right = 1'b0;
        step_and_check(IDLE, OUT_IDLE, "Recovery after Async Reset -> IDLE");

        $display("\n==========================================================================");
        $display(" TONG KET MO PHONG TBIRD_LIGHT: PASS = %0d | FAIL = %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display(" KET QUA: TAT CA BAI KIEM THU DEU THANH CONG (100%% PASS)!");
        else
            $display(" KET QUA: CO %0d LOI XAY RA!", fail_count);
        $display("==========================================================================\n");

        #20;
        $finish;
    end

endmodule
