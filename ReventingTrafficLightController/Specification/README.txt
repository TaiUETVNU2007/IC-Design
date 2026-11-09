
TÀI LIỆU THIẾT KẾ CHI TIẾT (DETAILED HARDWARE SPECIFICATION)
HỆ THỐNG ĐIỀU KHIỂN ĐÈN GIAO THÔNG FSM (TRAFFIC LIGHT CONTROLLER)
MỤC LỤC:
1. TỔNG QUAN HỆ THỐNG & KIẾN TRÚC PHẦN CỨNG (SYSTEM ARCHITECTURE)
2. MÔ TẢ CHI TIẾT CÁC MODULE VÀ GIAO TIẾP ĐẦU VÀO / ĐẦU RA (MODULES & PORTS)
   2.1. Top-Level Module: traffic_light_top
   2.2. Module 1: traffic_timer (Khối Datapath - Bộ đếm thời gian)
   2.3. Module 2: state_register (Thanh ghi trạng thái)
   2.4. Module 3: next_state_logic (Khối Control Unit - Logic trạng thái kế tiếp)
   2.5. Module 4: output_logic (Khối Control Unit - Giải mã ngõ ra Moore)
3. BẢNG MÃ HÓA TRẠNG THÁI (STATE ASSIGNMENT / STATE ENCODING)
4. SƠ ĐỒ CHUYỂN TRẠNG THÁI (STATE DIAGRAM)
5. BẢNG CHUYỂN TRẠNG THÁI CHI TIẾT (STATE TRANSITION TABLE)
6. QUY TRÌNH VẬN HÀNH & NGUYÊN LÝ ĐIỀU KHIỂN (EXECUTION LOGIC FLOW)
7. NGUYÊN LÝ THIẾT KẾ AN TOÀN VI MẠCH (HARDWARE RELIABILITY & FAILSAFE)
1. TỔNG QUAN HỆ THỐNG & KIẾN TRÚC PHẦN CỨNG (SYSTEM ARCHITECTURE)
Hệ thống điều khiển đèn tín hiệu giao thông ngã tư 2 làn:
- Hướng Bắc - Nam (North - South: ký hiệu NS)
- Hướng Đông - Tây (East - West: ký hiệu EW)
Hệ thống được thiết kế theo mô hình phân tách chuẩn Control Unit & Datapath:
- Khối Datapath: Bộ đếm thời gian (traffic_timer) chịu trách nhiệm đếm số giây 
  thực tế theo xung nhịp chuẩn 1 Hz và tạo các cờ báo ngưỡng thời gian.
- Khối Control Unit: Máy trạng thái hữu hạn (FSM) gồm 3 module phối hợp:
  + Thanh ghi trạng thái (state_register): Chốt trạng thái đồng bộ.
  + Logic trạng thái tiếp theo (next_state_logic): Mạch tổ hợp tính toán chuyển pha.
  + Logic giải mã ngõ ra (output_logic): Mạch tổ hợp chuẩn Moore điều khiển đèn vật lý.
SƠ ĐỒ KHỐI KIẾN TRÚC TỔNG THỂ (BLOCK DIAGRAM):

                                  TOP-LEVEL: traffic_light_top
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                        │
│   ┌─────────────┐               ┌───────────────────┐               ┌──────────────┐   │
│   │   Sensors   ├──────────────►│                   ├──────────────►│              │   │
│   │(NSCAR,EWCAR)│               │                   │    Snext      │    State     │   │
│   └─────────────┘               │                   │  (3-bit bus)  │   Register   │   │
│                                 │    Next-State     │◄──────────────┤  (3-bit FF)  │   │
│   ┌─────────────┐   TMSHORT     │       Logic       │               └──────┬───────┘   │
│   │traffic_timer├──────────────►│ (Combinational)   │                      │ Sreg      │
│   │  (Counter)  ├──────────────►│                   │                      │ (Current) │
│   └──────▲──────┘    TMLONG     └─────────┬─────────┘                      │           │
│          │                                │ TMRESET                        │           │
│          └────────────────────────────────┘                                │           │
│                                                                            ▼           │
│                                                                     ┌──────────────┐   │
│                                                                     │ Output Logic │   │
│                                                                     │   (Moore)    │   │
│                                                                     └──────┬───────┘   │
│                                                                            │           │
│                                                                            ▼           │
│                                                                         Outputs        │
│                                                                     (NS/EW Lights)     │
└────────────────────────────────────────────────────────────────────────────────────────┘
2. MÔ TẢ CHI TIẾT CÁC MODULE VÀ GIAO TIẾP ĐẦU VÀO / ĐẦU RA (MODULES & PORTS)
2.1. Top-Level Module: traffic_light_top
Nhiệm vụ: Module bọc ngoài cùng (Wrapper), đóng gói toàn bộ hệ thống và kết nối 
4 module con lại với nhau thành mạch hoàn chỉnh.

BẢNG CỔNG GIAO TIẾP (TOP-LEVEL INTERFACE):
| Tên tín hiệu | Hướng | Độ rộng | Tần số / Kiểu | Chức năng chi tiết                               |
|:-------------|:-----:|:-------:|:--------------|:-------------------------------------------------|
| clk          | Input | 1 bit   | System Clock  | Xung clock hệ thống chính toàn cục (toàn hệ thống)|
| rst          | Input | 1 bit   | Async High    | Reset cứng toàn mạch về trạng thái an toàn EWDELAY|
| en_1hz       | Input | 1 bit   | 1-clk Pulse   | Xung cho phép đếm tần số 1 Hz (1 xung = 1 giây)   |
| NSCAR        | Input | 1 bit   | Level         | Cảm biến xe làn Bắc - Nam (1: Có xe, 0: Không xe) |
| EWCAR        | Input | 1 bit   | Level         | Cảm biến xe làn Đông - Tây (1: Có xe, 0: Không xe)|
| NSGREEN      | Output| 1 bit   | Level         | Tín hiệu điều khiển Đèn Xanh làn Bắc - Nam        |
| NSYELLOW     | Output| 1 bit   | Level         | Tín hiệu điều khiển Đèn Vàng làn Bắc - Nam        |
| NSRED        | Output| 1 bit   | Level         | Tín hiệu điều khiển Đèn Đỏ làn Bắc - Nam          |
| EWGREEN      | Output| 1 bit   | Level         | Tín hiệu điều khiển Đèn Xanh làn Đông - Tây       |
| EWYELLOW     | Output| 1 bit   | Level         | Tín hiệu điều khiển Đèn Vàng làn Đông - Tây       |
| EWRED        | Output| 1 bit   | Level         | Tín hiệu điều khiển Đèn Đỏ làn Đông - Tây         |
2.2. Module 1: traffic_timer (Khối Datapath - Bộ đếm thời gian dùng chung)
Nhiệm vụ:
- Hoạt động như bộ định thời dùng chung (Shared Timer) cho cả 2 làn xe.
- Sử dụng thanh ghi đếm nhị phân 8-bit (timer_count) tăng theo từng nhịp en_1hz.
- Nhận lệnh xóa đồng bộ (TMRESET) từ next_state_logic mỗi khi chuyển pha.
- Phát 2 cờ trạng thái thời gian về next_state_logic:
  + TMSHORT = 1 khi timer_count >= 5 (đạt mốc 5 giây tối thiểu/đèn vàng).
  + TMLONG  = 1 khi timer_count >= 60 (đạt mốc 60 giây trần gia hạn tối đa).
- Tự động khóa không tăng khi chạm trần 60s để tránh tràn số (Overflow).

BẢNG CỔNG GIAO TIẾP:
| Tên cổng  | Hướng | Độ rộng | Nguồn / Đích       | Chức năng                                    |
|:----------|:-----:|:-------:|:-------------------|:---------------------------------------------|
| clk       | Input | 1 bit   | Top-level clk      | Xung nhịp đồng bộ của bộ đếm                 |
| rst       | Input | 1 bit   | Top-level rst      | Reset bất đồng bộ mức cao, xóa timer về 0    |
| en_1hz    | Input | 1 bit   | Top-level en_1hz   | Cho phép tăng bộ đếm thêm 1 đơn vị (1 giây)  |
| TMRESET   | Input | 1 bit   | next_state_logic   | Lệnh xóa đồng bộ timer_count về 0 từ FSM     |
| TMSHORT   | Output| 1 bit   | next_state_logic   | Cờ báo timer_count >= 5s                     |
| TMLONG    | Output| 1 bit   | next_state_logic   | Cờ báo timer_count >= 60s                    |
2.3. Module 2: state_register (Khối Control Unit - Thanh ghi lưu trạng thái FSM)
Nhiệm vụ:
- Lưu trữ trạng thái hiện tại của hệ thống (Sreg) dưới dạng 3-bit D Flip-Flop.
- Cập nhật Sreg <= Snext tại mỗi sườn dương xung clock hệ thống (posedge clk).
- Khởi tạo an toàn tuyệt đối khi rst = 1: Ép trạng thái về EWDELAY (3'b111).
  Tại trạng thái này, cả 2 hướng đều Đèn Đỏ, và nhịp clock kế tiếp sẽ bắt đầu 
  chính xác tại NSGO (Bắc - Nam Xanh) đúng theo đặc tả hệ thống.

BẢNG CỔNG GIAO TIẾP:
| Tên cổng  | Hướng | Độ rộng | Nguồn / Đích       | Chức năng                                    |
|:----------|:-----:|:-------:|:-------------------|:---------------------------------------------|
| clk       | Input | 1 bit   | Top-level clk      | Xung clock chốt trạng thái                   |
| rst       | Input | 1 bit   | Top-level rst      | Reset ép trạng thái về an toàn EWDELAY (111) |
| Snext     | Input | 3 bit   | next_state_logic   | Trạng thái kế tiếp cần nạp vào thanh ghi     |
| Sreg      | Output| 3 bit   | output, next_state | Trạng thái hiện tại xuất ra hệ thống         |
2.4. Module 3: next_state_logic (Khối Control Unit - Logic trạng thái kế tiếp)
Nhiệm vụ:
- Là mạch tổ hợp thuần túy (Pure Combinational Logic), không tạo Latch.
- Tiếp nhận trạng thái hiện tại (Sreg), tín hiệu cảm biến (NSCAR, EWCAR) 
  và cờ thời gian (TMSHORT, TMLONG).
- Tính toán trạng thái kế tiếp (Snext) cho chu kỳ clock sau.
- Phát tín hiệu xóa bộ đếm (TMRESET = 1) khi quyết định chuyển sang pha mới.
- Cung cấp nhánh default phục hồi an toàn về EWDELAY nếu mạch gặp trạng thái lạ.

BẢNG CỔNG GIAO TIẾP:
| Tên cổng  | Hướng | Độ rộng | Nguồn / Đích       | Chức năng                                    |
|:----------|:-----:|:-------:|:-------------------|:---------------------------------------------|
| Sreg      | Input | 3 bit   | state_register     | Trạng thái hiện tại của FSM                  |
| NSCAR     | Input | 1 bit   | Top-level NSCAR    | Trạng thái cảm biến xe làn Bắc - Nam         |
| EWCAR     | Input | 1 bit   | Top-level EWCAR    | Trạng thái cảm biến xe làn Đông - Tây        |
| TMSHORT   | Input | 1 bit   | traffic_timer      | Cờ báo hết thời gian tối thiểu 5s / đèn Vàng |
| TMLONG    | Input | 1 bit   | traffic_timer      | Cờ báo chạm trần gia hạn tối đa 60s          |
| Snext     | Output| 3 bit   | state_register     | Trạng thái kế tiếp của FSM                   |
| TMRESET   | Output| 1 bit   | traffic_timer      | Lệnh phát xung xóa bộ đếm timer về 0         |
2.5. Module 4: output_logic (Khối Control Unit - Giải mã ngõ ra Moore Machine)-
Nhiệm vụ:
- Giải mã trạng thái hiện tại Sreg thành 6 tín hiệu đèn thực tế của 2 làn xe.
- Chuẩn máy Moore 100%: Đầu ra chỉ phụ thuộc duy nhất vào Sreg, hoàn toàn cách ly 
  với các cảm biến ngõ vào, triệt tiêu mọi nguy cơ nhiễu tín hiệu (Glitches/Hazards).
- Thiết kế an toàn loại trừ lẫn nhau (Mutual Exclusion):
  Đèn Đỏ được định nghĩa là phủ định của (Xanh | Vàng). Một làn xe không bao giờ 
  có thể sáng 2 bóng đèn cùng một lúc trong bất kỳ trường hợp nào.

BẢNG CỔNG GIAO TIẾP:
| Tên cổng  | Hướng | Độ rộng | Nguồn / Đích       | Biểu thức logic giải mã                      |
|:----------|:-----:|:-------:|:-------------------|:---------------------------------------------|
| Sreg      | Input | 3 bit   | state_register     | Trạng thái hiện tại của FSM                  |
| NSGREEN   | Output| 1 bit   | Top-level NSGREEN  | Sreg == NSGO (3'b000)                        |
| NSYELLOW  | Output| 1 bit   | Top-level NSYELLOW | Sreg == NSWAIT (3'b001)                      |
| NSRED     | Output| 1 bit   | Top-level NSRED    | ~(NSGREEN \| NSYELLOW)                       |
| EWGREEN   | Output| 1 bit   | Top-level EWGREEN  | Sreg == EWGO (3'b100)                        |
| EWYELLOW  | Output| 1 bit   | Top-level EWYELLOW | Sreg == EWWAIT (3'b101)                      |
| EWRED     | Output| 1 bit   | Top-level EWRED    | ~(EWGREEN \| EWYELLOW)                       |
3. BẢNG MÃ HÓA TRẠNG THÁI (STATE ASSIGNMENT / STATE ENCODING)
================================================================================
Hệ thống sử dụng không gian 3 bit để mã hóa đầy đủ 8 trạng thái (000 đến 111).
Đặc tính mã hóa:
- Bit Sreg[2] = 0: Thuộc nhóm pha Bắc - Nam (NS active).
- Bit Sreg[2] = 1: Thuộc nhóm pha Đông - Tây (EW active).

| Tên trạng thái | Mã nhị phân | Đèn Bắc - Nam | Đèn Đông - Tây | Ý nghĩa hoạt động                          |
|:---------------|:-----------:|:-------------:|:--------------:|:-------------------------------------------|
| NSGO           |    3'b000   |     XANH      |       ĐỎ       | Làn Bắc - Nam di chuyển (Xanh)             |
| NSWAIT         |    3'b001   |     VÀNG      |       ĐỎ       | Làn Bắc - Nam cảnh báo dừng (Vàng 5s)      |
| NSWAIT2        |    3'b010   |      ĐỎ       |       ĐỎ       | Safety Tick 1 (All-Red xả xe ngã tư)       |
| NSDELAY        |    3'b011   |      ĐỎ       |       ĐỎ       | Safety Tick 2 (All-Red chuyển giao sang EW)|
| EWGO           |    3'b100   |      ĐỎ       |      XANH      | Làn Đông - Tây di chuyển (Xanh)            |
| EWWAIT         |    3'b101   |      ĐỎ       |      VÀNG      | Làn Đông - Tây cảnh báo dừng (Vàng 5s)     |
| EWWAIT2        |    3'b110   |      ĐỎ       |       ĐỎ       | Safety Tick 1 (All-Red xả xe ngã tư)       |
| EWDELAY        |    3'b111   |      ĐỎ       |       ĐỎ       | Safety Tick 2 (All-Red / Trạng thái Reset) |

================================================================================
4. SƠ ĐỒ CHUYỂN TRẠNG THÁI (STATE DIAGRAM)
================================================================================

       [RESET: rst = 1]
              │
              ▼
    ┌──────────────────┐
    │     EWDELAY      │◄──────────────────────────────────────────────────┐
    │  (All-Red / Safe)│                                                   │
    └─────────┬────────┘                                                   │
              │                                                            │
              ▼ (Clock tick sau Reset, phát TMRESET=1)                     │
    ┌──────────────────┐                                                   │
┌──►│       NSGO       │                                                   │
│   │ (Bắc - Nam Xanh) │                                                   │
└───┤                  │ (TMSHORT=0) HOẶC (TMSHORT=1 & NSCAR & ~EWCAR & ~TMLONG)
    └─────────┬────────┘                                                   │
              │                                                            │
              ▼ (TMSHORT=1 & (~NSCAR | EWCAR | TMLONG)) [Phát TMRESET=1]   │
    ┌──────────────────┐                                                   │
┌──►│      NSWAIT      │                                                   │
│   │ (Bắc - Nam Vàng) │                                                   │
└───┤                  │ (~TMSHORT: Giữ Vàng trong 5s)                     │
    └─────────┬────────┘                                                   │
              │                                                            │
              ▼ (TMSHORT=1: Hết 5s Vàng) [Phát TMRESET=1]                  │
    ┌──────────────────┐                                                   │
    │     NSWAIT2      │ (Safety Tick 1: Cả hai làn cùng Đỏ)               │
    └─────────┬────────┘                                                   │
              │                                                            │
              ▼ (Unconditional 1-clock tick) [Phát TMRESET=1]              │
    ┌──────────────────┐                                                   │
    │     NSDELAY      │ (Safety Tick 2: Cả hai làn cùng Đỏ)               │
    └─────────┬────────┘                                                   │
              │                                                            │
              ▼ (Unconditional 1-clock tick) [Phát TMRESET=1]              │
    ┌──────────────────┐                                                   │
┌──►│       EWGO       │                                                   │
│   │(Đông - Tây Xanh) │                                                   │
└───┤                  │ (TMSHORT=0) HOẶC (TMSHORT=1 & EWCAR & ~NSCAR & ~TMLONG)
    └─────────┬────────┘                                                   │
              │                                                            │
              ▼ (TMSHORT=1 & (~EWCAR | NSCAR | TMLONG)) [Phát TMRESET=1]   │
    ┌──────────────────┐                                                   │
┌──►│      EWWAIT      │                                                   │
│   │(Đông - Tây Vàng) │                                                   │
└───┤                  │ (~TMSHORT: Giữ Vàng trong 5s)                     │
    └─────────┬────────┘                                                   │
              │                                                            │
              ▼ (TMSHORT=1: Hết 5s Vàng) [Phát TMRESET=1]                  │
    ┌──────────────────┐                                                   │
    │     EWWAIT2      │ (Safety Tick 1: Cả hai làn cùng Đỏ)               │
    └─────────┬────────┘                                                   │
              │                                                            │
              ▼ (Unconditional 1-clock tick) [Phát TMRESET=1]              │
              └────────────────────────────────────────────────────────────┘

================================================================================
5. BẢNG CHUYỂN TRẠNG THÁI CHI TIẾT (STATE TRANSITION TABLE)
================================================================================

| Sreg | Điều kiện chuyển tiếp                       | Snext | TMRESET | NS Lights | EW Lights | Mô tả chuyển pha                         |
|:----:|:--------------------------------------------|:-----:|:-------:|:---------:|:---------:|:-----------------------------------------|
| NSGO | ~TMSHORT                                    | NSGO  |    0    |   XANH    |    ĐỎ     | Chưa đủ 5s: Khóa cảm biến, bắt buộc Xanh |
| NSGO | TMSHORT & NSCAR & ~EWCAR & ~TMLONG          | NSGO  |    0    |   XANH    |    ĐỎ     | Còn xe NS, EW trống, chưa trần: Gia hạn  |
| NSGO | TMSHORT & (~NSCAR \| EWCAR \| TMLONG)       | NSWAIT|    1    |   XANH    |    ĐỎ     | Hết xe / EW chờ / chạm 60s: Sang Vàng    |
|------|---------------------------------------------|-------|---------|-----------|-----------|------------------------------------------|
|NSWAIT| ~TMSHORT                                    | NSWAIT|    0    |   VÀNG    |    ĐỎ     | Chưa đủ 5s Vàng: Tiếp tục giữ Vàng       |
|NSWAIT| TMSHORT                                     |NSWAIT2|    1    |   VÀNG    |    ĐỎ     | Hết 5s Vàng: Chuyển sang All-Red 1       |
|------|---------------------------------------------|-------|---------|-----------|-----------|------------------------------------------|
|NSWAIT2| 1'b1 (Vô điều kiện)                        |NSDELAY|    1    |    ĐỎ     |    ĐỎ     | All-Red Tick 1 -> Chuyển All-Red Tick 2  |
|------|---------------------------------------------|-------|---------|-----------|-----------|------------------------------------------|
|NSDELAY| 1'b1 (Vô điều kiện)                        | EWGO  |    1    |    ĐỎ     |    ĐỎ     | All-Red Tick 2 -> Chuyển giao sang EW Xanh|
|------|---------------------------------------------|-------|---------|-----------|-----------|------------------------------------------|
| EWGO | ~TMSHORT                                    | EWGO  |    0    |    ĐỎ     |   XANH    | Chưa đủ 5s: Khóa cảm biến, bắt buộc Xanh |
| EWGO | TMSHORT & EWCAR & ~NSCAR & ~TMLONG          | EWGO  |    0    |    ĐỎ     |   XANH    | Còn xe EW, NS trống, chưa trần: Gia hạn  |
| EWGO | TMSHORT & (~EWCAR \| NSCAR \| TMLONG)       | EWWAIT|    1    |    ĐỎ     |   XANH    | Hết xe / NS chờ / chạm 60s: Sang Vàng    |
|------|---------------------------------------------|-------|---------|-----------|-----------|------------------------------------------|
|EWWAIT| ~TMSHORT                                    | EWWAIT|    0    |    ĐỎ     |   VÀNG    | Chưa đủ 5s Vàng: Tiếp tục giữ Vàng       |
|EWWAIT| TMSHORT                                     |EWWAIT2|    1    |    ĐỎ     |   VÀNG    | Hết 5s Vàng: Chuyển sang All-Red 1       |
|------|---------------------------------------------|-------|---------|-----------|-----------|------------------------------------------|
|EWWAIT2| 1'b1 (Vô điều kiện)                        |EWDELAY|    1    |    ĐỎ     |    ĐỎ     | All-Red Tick 1 -> Chuyển All-Red Tick 2  |
|------|---------------------------------------------|-------|---------|-----------|-----------|------------------------------------------|
|EWDELAY| 1'b1 (Vô điều kiện)                        | NSGO  |    1    |    ĐỎ     |    ĐỎ     | All-Red Tick 2 -> Vòng lại Bắc - Nam Xanh|
|------|---------------------------------------------|-------|---------|-----------|-----------|------------------------------------------|
|default| Bất kỳ trạng thái lỗi                      |EWDELAY|    1    |    ĐỎ     |    ĐỎ     | Tự phục hồi về trạng thái an toàn All-Red|

================================================================================
6. QUY TRÌNH VẬN HÀNH & NGUYÊN LÝ ĐIỀU KHIỂN (EXECUTION LOGIC FLOW)
================================================================================

6.1. Khởi động và Reset hệ thống (System Reset & Safe Initialization)
- Khi cấp tín hiệu rst = 1 (Async Active-High), thanh ghi trạng thái state_register 
  ngay lập tức ép Sreg về EWDELAY (3'b111).
- Tại trạng thái này: NSRED = 1, EWRED = 1 (Tất cả các hướng đều Đèn Đỏ). 
  Đây là trạng thái khởi tạo an toàn tuyệt đối cho người và phương tiện.
- Khi rst = 0, tại sườn dương xung clock kế tiếp:
  + next_state_logic tính Snext = NSGO (3'b000) và phát xung TMRESET = 1.
  + traffic_timer xóa timer_count về 0.
  + Hệ thống bước vào trạng thái vận hành chính thức đầu tiên: NSGO (Bắc - Nam Xanh).

6.2. Pha Đèn Xanh tối thiểu 5s (Minimum Green Phase & Sensor Lock)
- Khi bắt đầu vào NSGO (hoặc EWGO), timer_count = 0 nên TMSHORT = 0.
- Trong khoảng thời gian từ 0s đến dưới 5s (~TMSHORT):
  FSM giữ cố định Snext = NSGO bất chấp mọi tín hiệu cảm biến xe (NSCAR, EWCAR).
- Mục đích: Đảm bảo thời gian xanh tối thiểu để các phương tiện đã khởi hành 
  qua ngã tư an toàn, không bị chuyển đèn đột ngột gây tai nạn dồn toa.

6.3. Pha Gia hạn Đèn Xanh linh hoạt (Green Extension Phase)
- Khi timer_count >= 5 (TMSHORT = 1), hệ thống chuyển sang chế độ quét cảm biến:
  + Nếu làn Bắc - Nam vẫn còn dòng xe chạy (NSCAR = 1),
  + Làn Đông - Tây chưa có xe xếp hàng chờ (EWCAR = 0),
  + Và tổng thời gian xanh chưa chạm ngưỡng tối đa (TMLONG = 0, tức < 60s):
  ==> FSM quyết định giữ tiếp Snext = NSGO (Gia hạn thời gian xanh).
- Tính năng này tối ưu hóa lưu lượng giao thông thực tế, giải phóng triệt để 
  đoàn xe trên trục đường chính khi trục đường phụ đang trống.

6.4. Kết thúc pha và chuyển Đèn Vàng 5s (Phase Termination & Yellow Transition)
- Pha Đèn Xanh lập tức kết thúc và chuyển sang NSWAIT khi thỏa mãn 1 trong 3 điều kiện:
  (1) NSCAR = 0 : Làn Bắc - Nam đã hết xe qua lại.
  (2) EWCAR = 1 : Làn đối diện (Đông - Tây) đã có xe xuất hiện và đang chờ.
  (3) TMLONG = 1: Đã chạm ngưỡng tối đa 60s (chống chiếm dụng làn, chia sẻ quyền ưu tiên).
- Khi quyết định chuyển sang NSWAIT, next_state_logic phát TMRESET = 1 để nạp 
  lại bộ đếm về 0, chuẩn bị tính thời gian cho pha đèn Vàng.
- Tại NSWAIT: Đèn Vàng duy trì chính xác 5 giây cho đến khi TMSHORT = 1.

6.5. Chuỗi đệm an toàn All-Red (Safety Clearance Buffer Sequence)
- Sau khi kết thúc 5s đèn Vàng, hệ thống bước vào chuỗi 2 nhịp đệm an toàn:
  + Nhịp 1: NSWAIT2 (3'b010) - Cả hai hướng cùng bật Đèn Đỏ.
  + Nhịp 2: NSDELAY (3'b011) - Cả hai hướng tiếp tục giữ Đèn Đỏ.
- Trong toàn bộ chuỗi này, TMRESET luôn được giữ ở mức 1 để nạp sẵn timer = 0.
- Mục đích: Dọn sạch hoàn toàn các phương tiện còn kẹt giữa giao lộ trước khi 
  bật Đèn Xanh cho luồng phương tiện chiều cắt ngang.

6.6. Chuyển giao quyền ưu tiên (Handover to East-West Phase)
- Sau khi hoàn thành NSDELAY, FSM tự động nhảy sang EWGO (3'b100).
- Chu trình lặp lại hoàn toàn đối xứng cho làn Đông - Tây:
  EWGO (5s - 60s) -> EWWAIT (5s) -> EWWAIT2 (All-Red 1) -> EWDELAY (All-Red 2)
  -> Quay trở lại NSGO.

================================================================================
7. NGUYÊN LÝ THIẾT KẾ AN TOÀN VI MẠCH (HARDWARE RELIABILITY & FAILSAFE)
================================================================================
1. Chống chốt nhớ ngoài ý muốn (Inferred Latches):
   Toàn bộ các tín hiệu ngõ ra của next_state_logic (Snext, TMRESET) luôn được gán 
   giá trị mặc định ở đầu khối always @(*) trước khi đi vào lệnh case.
2. Tự phục hồi trạng thái (Self-Recovering FSM):
   Nhánh default của cấu trúc case luôn ép mạch về trạng thái an toàn EWDELAY (All-Red) 
   và phát lệnh reset timer, triệt tiêu nguy cơ vi mạch bị treo (Lockup/Deadlock) 
   do bức xạ hay sụt nguồn làm nhảy trạng thái bất hợp lệ.
3. Chuẩn máy trạng thái Moore (Noise Immunity):
   Khối output_logic chỉ phụ thuộc vào các Flip-Flop của thanh ghi trạng thái Sreg, 
   hoàn toàn độc lập với các cảm biến vật lý bên ngoài (NSCAR, EWCAR), loại bỏ 
   hoàn toàn xung gai (Glitch) xuất hiện ở ngõ ra điều khiển đèn vật lý.
4. An toàn loại trừ lẫn nhau (Mutually Exclusive Fail-safe):
   Tín hiệu Đèn Đỏ được ràng buộc phần cứng: RED = ~(GREEN | YELLOW). 
   Không bao giờ xảy ra tình trạng chập cháy hay hiển thị sai 2 đèn trên cùng một làn.

================================================================================
KẾT THÚC TÀI LIỆU
================================================================================
