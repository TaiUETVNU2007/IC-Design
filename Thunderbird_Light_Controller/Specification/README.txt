
         DỰ ÁN: BỘ ĐIỀU KHIỂN ĐÈN HẬU XE FORD THUNDERBIRD (TBIRD_LIGHT)
                TÀI LIỆU KỊCH BẢN KIỂM THỬ & ĐÁNH GIÁ COVERAGE
1. TỔNG QUAN THIẾT KẾ & MÔI TRƯỜNG KIỂM THỬ
--------------------------------------------------------------------------------
- Kiến trúc RTL (Moore FSM - 8 trạng thái mã hóa Gray theo Table 9-7):
  + module_Tbird_Light.v : Module đỉnh kết nối toàn hệ thống.
  + NextStateLogic.v     : Mạch tổ hợp tính trạng thái kế tiếp (Snext).
  + StateMemory.v        : Thanh ghi trạng thái (Scurrent), đồng bộ sườn dương
                           CLOCK, tích hợp Asynchronous Reset mức cao (RESET).
  + OutputLogic.v        : Mạch giải mã trạng thái ra 6 đèn {LC,LB,LA,RA,RB,RC}.

- Kiến trúc Testbench tự động kiểm tra (tb_Tbird_Light.v):
  + Xung nhịp CLOCK      : Chu kỳ 10ns (tần số 100MHz).
  + Cơ chế chống nhiễu   : Lái ngõ vào tại sườn âm (negedge CLOCK) qua task
                           drive_inputs() để tránh Race Condition với RTL.
  + Cơ chế chấm điểm     : Tự động so sánh cả trạng thái nội (Scurrent) và ngõ ra
                           (data_out) qua task step_and_check() (sau posedge
                           CLOCK 1ns) và check_immediate() (cho Async Reset).
  + Tổng số điểm đo      : 44 phép kiểm tra tự động (PASS = 44, FAIL = 0).


2. CHI TIẾT KỊCH BẢN KIỂM THỬ (TEST PLAN)
[KHỞI TẠO NGUỒN - POWER-ON ASYNC RESET]
- Kích thích : Gán tất cả ngõ vào bằng 0, đưa RESET đi theo chuỗi 0 -> 1 -> 0.
- Kỳ vọng    : FSM về ngay trạng thái IDLE (000), toàn bộ 6 đèn tắt (000000)
               mà không cần chờ sườn xung CLOCK.
- Mục đích   : Đảm bảo trạng thái khởi động an toàn và tạo đủ sườn chuyển đổi
               0->1, 1->0 cho tín hiệu RESET.

[TEST 1: GIỮ NGUYÊN TRẠNG THAI NGHỈ IDLE]
- Kích thích : Giữ {haz, left, right} = 000 liên tiếp qua 2 chu kỳ CLOCK.
- Kỳ vọng    : FSM đứng yên tại IDLE (000), data_out = 000000.
- Mục đích   : Kiểm tra tính ổn định tĩnh, không tự kích hoạt nháy đèn giả.

[TEST 2: CHU TRÌNH XI-NHAN TRÁI CƠ BẢN & TỰ HOÀN TẤT KHI NHẢ NÚT SỚM]
- Kích thích : Bật {haz, left, right} = 010 trong 1 chu kỳ để vào L1, sau đó
               nhả ngay công tắc về 000 trong suốt các chu kỳ còn lại.
- Kỳ vọng    : Đèn trái sáng đuổi từ trong ra ngoài rồi tắt:
               IDLE (000000) -> L1 (001000) -> L2 (011000) -> L3 (111000) -> IDLE.
- Mục đích   : Kiểm chứng hiệu ứng xi-nhan trái và tính năng tự chạy hết chu kỳ
               3 bước dù người lái chỉ gạt nháy cần xi-nhan 1 nhịp ngắn.

[TEST 3: CHU TRÌNH XI-NHAN PHẢI CƠ BẢN & TỰ HOÀN TẤT KHI NHẢ NÚT SỚM]
- Kích thích : Bật {haz, left, right} = 001 trong 1 chu kỳ để vào R1, sau đó
               nhả ngay công tắc về 000.
- Kỳ vọng    : Đèn phải sáng đuổi từ trong ra ngoài rồi tắt:
               IDLE (000000) -> R1 (000100) -> R2 (000110) -> R3 (000111) -> IDLE.
- Mục đích   : Kiểm chứng hiệu ứng xi-nhan phải và cơ chế tự hoàn tất chu kỳ.

[TEST 4: CHẾ ĐỘ CẢNH BÁO KHẨN CẤP ĐỘC LẬP (HAZARD BLINKING)]
- Kích thích : Giữ {haz, left, right} = 100 liên tục qua nhiều chu kỳ, sau đó
               nhả về 000.
- Kỳ vọng    : 6 đèn chớp tắt đồng loạt liên tục:
               IDLE (000000) -> LR3 (111111) -> IDLE (000000) -> LR3 (111111),
               và dừng ở IDLE (000000) khi tắt haz.
- Mục đích   : Kiểm chứng chức năng nháy cảnh báo nguy hiểm liên tục.

[TEST 5: BẬT ĐỒNG THỜI XI-NHAN TRÁI VÀ PHẢI (XỬ LÝ THAO TÁC NHẦM)]
- Kích thích : Đưa tổ hợp {haz, left, right} = 011 (haz=0 nhưng left=1, right=1).
- Kỳ vọng    : FSM chuyển từ IDLE sang LR3 (111111), sau đó về IDLE khi nhả nút.
- Mục đích   : Kiểm chứng yêu cầu an toàn khi tài xế gạt nhầm cả 2 hướng cùng lúc
               và đóng kín độ phủ biểu thức (FEC) cho nhánh (left && right).

[TEST 6: QUYỀN ƯU TIÊN TUYỆT ĐỐI CỦA HAZARD VỚI CÁC TỔ HỢP CÒN LẠI]
- Kích thích : Lần lượt kích các tổ hợp {haz, left, right} = 101, 110 và 111.
- Kỳ vọng    : Trong cả 3 trường hợp, FSM đều ưu tiên vào LR3 (111111) thay vì
               rẽ trái (L1) hoặc rẽ phải (R1).
- Mục đích   : Quét cạn đủ 8/8 tổ hợp ngõ vào tại IDLE, chứng minh haz có mức
               ưu tiên cao nhất và các điều kiện chuyển trạng thái loại trừ nhau.

[TEST 7: CHỐNG NGẮT QUÃNG GIỮA CHU KỲ & CHUYỂN TIẾP NỐI ĐUÔI (CORNER CASE)]
- Kích thích :
  + Kịch bản 7a: Khởi động rẽ trái vào L1 (010), ngay khi đang ở L1 lập tức bật
                 gây nhiễu {haz, left, right} = 101 (vừa haz vừa right).
  + Kịch bản 7b: Khởi động rẽ phải vào R1 (001), ngay khi đang ở R1 lập tức đổi
                 ý gạt sang rẽ trái {haz, left, right} = 010.
- Kỳ vọng    :
  + 7a: Không bị ngắt ngang ở L1; vẫn chạy đủ L2 -> L3 -> IDLE, rồi ngay nhịp
        kế tiếp mới chuyển sang LR3.
  + 7b: Không bị nhảy tắt từ R1 sang L1; vẫn chạy đủ R2 -> R3 -> IDLE, rồi ngay
        nhịp kế tiếp mới bắt đầu chu trình rẽ trái L1 -> L2 -> L3 -> IDLE.
- Mục đích   : Chứng minh tính bất khả xâm phạm của chu trình xi-nhan đang chạy
               và khả năng bắt lệnh mới nối đuôi mượt mà ngay khi về IDLE.

[TEST 8: ASYNCHRONOUS RESET CẮT NGANG TRẠNG THÁI ĐỘNG & PHỤC HỒI]
- Kích thích : Cho mạch chạy vào giữa chu trình tại L2 (và lặp lại tương tự tại
               R2), chờ lệch pha xung nhịp (#2ns) rồi kéo RESET = 1, sau đó nhả
               RESET = 0 ở sườn âm CLOCK.
- Kỳ vọng    : Ngay thời điểm RESET = 1, trạng thái lập tức về IDLE (000) và
               data_out = 000000 không cần đợi CLOCK; sau khi nhả RESET, mạch
               hoạt động ổn định trở lại tại IDLE.
- Mục đích   : Kiểm chứng quyền cưỡng bức tức thời của phần cứng Reset và khả
               năng phục hồi (Recovery) sạch sẽ.


3. ĐÁNH GIÁ ĐỘ ỔN ĐỊNH COVERAGE & CÁC NHU CẦU ĐƯỢC THỎA MÃN
--------------------------------------------------------------------------------
TRẠNG THÁI TỔNG THỂ: ĐÃ ỔN ĐỊNH VÀ ĐẠT 100% COVERAGE CLOSURE.
Toàn bộ các thước đo Code Coverage và Nhu cầu Chức năng (Functional) đều đã hội
tụ tối đa, cụ thể như sau:

A. VỀ CODE COVERAGE (ĐO TRÊN CẤU TRÚC MÃ NGUỒN RTL - ĐẠT 100%)
1. Block / Statement Coverage (100%):
   - Thỏa mãn qua: Khởi tạo nguồn + TEST 1 -> TEST 8.
   - Minh chứng  : Mọi câu lệnh gán trong StateMemory, NextStateLogic và
                   OutputLogic đều được thực thi (kể cả nhánh default lúc mới
                   cấp nguồn khi thanh ghi chưa Reset).

2. Branch / Decision Coverage (100%):
   - Thỏa mãn qua: Khởi tạo nguồn + TEST 1, 2, 3, 4, 8.
   - Minh chứng  : Phủ đủ 2 nhánh True/False của if(reset), 4 nhánh phân luồng
                   if - else if - else tại IDLE, và toàn bộ các nhánh case(state).

3. Expression / FEC Coverage (100%):
   - Thỏa mãn qua: Tổ hợp kết quả từ TEST 1 (000), TEST 2 (010), TEST 3 (001),
                   TEST 4 (100), TEST 5 (011) và TEST 6 (101, 110, 111).
   - Minh chứng  : Biểu thức phức hợp `haz || (left && right)` được chứng minh
                   rằng từng biến đơn lẻ (haz, left, right) đều độc lập quyết
                   định được đầu ra biểu thức (100% Focused Expression Coverage),
                   đồng thời vét cạn 8/8 dòng bảng chân trị ngõ vào.

4. FSM State & Transition Coverage (100%):
   - Thỏa mãn qua: TEST 1 -> TEST 4 (11 cung đồng bộ) và TEST 8 (cung Async).
   - Minh chứng  : Đi qua đủ 8/8 trạng thái (IDLE, L1..L3, R1..R3, LR3) và đủ
                   11/11 cung chuyển trạng thái chuẩn trên sơ đồ Figure 9-25.

5. Toggle Coverage (100% trên toàn bộ 17/17 bit tín hiệu):
   - Thỏa mãn qua: Khởi tạo RESET (0->1->0) + TEST 2, 3, 4.
   - Minh chứng  : Tất cả 5 cổng vào (CLOCK, RESET, haz, left, right), 6 bit dây
                   trạng thái nội (Scurrent[2:0], Snext[2:0]) và 6 bit đèn ngõ ra
                   (data_out[5:0]) đều có đầy đủ chuyển đổi 0 -> 1 và 1 -> 0.

B. VỀ NHU CẦU CHỨC NĂNG THỰC TẾ (FUNCTIONAL REQUIREMENTS - ĐẠT 7/7 NHU CẦU)
1. Nhu cầu an toàn khi cấp nguồn & sự cố phần cứng -> Thỏa mãn qua Init & TEST 8.
2. Nhu cầu giữ đèn tắt ổn định khi xe đi thẳng     -> Thỏa mãn qua TEST 1.
3. Nhu cầu hiệu ứng đèn chạy đúng chiều Trái/Phải  -> Thỏa mãn qua TEST 2 & 3.
4. Nhu cầu gạt xi-nhan 1 chạm vẫn nháy đủ 3 bước   -> Thỏa mãn qua TEST 2 & 3.
5. Nhu cầu nháy khẩn cấp 6 bóng đồng bộ liên tục   -> Thỏa mãn qua TEST 4.
6. Nhu cầu ưu tiên khẩn cấp & xử lý gạt nhầm 2 bên -> Thỏa mãn qua TEST 5 & 6.
7. Nhu cầu không gãy hiệu ứng khi đổi công tắc giữa chừng và tự nối tiếp lệnh mới
                                                   -> Thỏa mãn qua TEST 7.