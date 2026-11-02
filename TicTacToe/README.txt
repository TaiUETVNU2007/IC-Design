
 TIC-TAC-TOE MOVE PICKER - Combinational "Random-Logic" Example
 (Wakerly, Digital Design, Section 7.5 - Verilog)
1. MÔ TẢ
Mạch tổ hợp chọn nước đi tiếp theo cho người chơi X trong cờ
ca-rô 3x3 (Tic-Tac-Toe). Ngõ vào là trạng thái bàn cờ, ngõ ra
là ô sẽ đánh. Không có clock, không có phần tử nhớ.
Mục đích: minh họa cách mô tả mạch "random logic" (không khớp
khối chuẩn như mux/decoder/adder) bằng Verilog behavioral, chia
module theo chiến lược, và tận dụng mã hóa đối xứng.
2. MÃ HÓA
Bàn cờ: 2 vector 9 bit
  X[1:9] : bit = 1 nếu ô có quân X
  Y[1:9] : bit = 1 nếu ô có quân Y (tức "O")
Mỗi ô (X,Y):  00 = trống | 10 = X | 01 = Y  (11 = không hợp lệ)
Chỉ số ô:  index = (row-1)*3 + column
         col1  col2  col3
  row1 :   1     2     3
  row2 :   4     5     6
  row3 :   7     8     9
Nước đi: 4 bit, định nghĩa trong TTTdefs.v
  MOVE11=1000  MOVE12=0100  MOVE13=0010
  MOVE21=0001  MOVE22=1100  MOVE23=0111
  MOVE31=1011  MOVE32=1101  MOVE33=1110
  NONE  =0000  (không còn nước đi / bàn đầy)
3. CHIẾN LƯỢC (THỨ TỰ ƯU TIÊN)
  1. Thắng : đường (hàng/cột/chéo) có 2 quân X + 1 ô trống
  2. Chặn  : đường có 2 quân Y + 1 ô trống
  3. Kinh nghiệm: ô giữa (22) -> góc (11,13,31,33)
                  -> cạnh (12,21,23,32)
  4. Bàn đầy: NONE
4. CẤU TRÚC FILE / MODULE
  TTTdefs.v   : các parameter mã hóa nước đi (`include)
  TwoInRow.v  : tìm ô trống trên đường có 2 quân X
                (hàm R=hàng, C=cột, D=chéo 11-22-33,
                 E=chéo 13-22-31; ưu tiên ô 11 -> 33)
  Pick.v      : chọn nước cuối: WIN > BLK > giữa > góc > cạnh
  GETMOVE.v   : module top (structural)
           X,Y ---> [U1 TwoInRow (X,Y)] --WIN--+
           Y,X ---> [U2 TwoInRow (Y,X)] --BLK--+--> [U3 Pick] --> MOVE
           X,Y ----------------------------------------^
  U2 nhận X và Y bị tráo -> nước "thắng" của Y chính là ô X
  cần chặn. Nhờ mã hóa đối xứng nên dùng lại được TwoInRow.
5. INTERFACE MODULE TOP
-----------------------
  module GETMOVE (X, Y, MOVE);
    input  [1:9] X, Y;   // trạng thái bàn cờ
    output [3:0] MOVE;   // nước đi cho X (mã trong TTTdefs.v)

  Giả định: ngõ vào là trạng thái hợp lệ (không ô nào có X=Y=1).
  Nếu máy chơi quân Y: tráo X và Y ở ngõ vào GETMOVE.
6. GHI CHÚ
----------
- Verilog-2001 không cho mảng 2 chiều làm port, nên bàn cờ được
  làm phẳng thành vector 9 bit.
- Kết quả tổng hợp (Vivado, Xilinx 7-series) theo sách:
    bản if-else         : 63 LUT, đường trễ dài nhất 5 LUT
    bản case(1'b1)      : 668 LUT (TwoInRow 210 so với 21 LUT)
  Chức năng giống hệt nhau (đã kiểm tra đủ 2^18 tổ hợp ngõ vào)
  -> với random logic, cách viết code có thể làm kết quả tổng
  hợp chênh nhau rất lớn.
- Chiến lược không "nhìn trước" (không xử lý thế nước đôi/fork),
  nên không phải lúc nào cũng chơi tối ưu.