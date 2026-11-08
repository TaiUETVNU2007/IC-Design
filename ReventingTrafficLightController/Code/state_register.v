
// Chức năng: Chốt trạng thái hiện tại (Sreg) từ trạng thái kế tiếp (Snext) theo xung Clock
module state_register (
    input  wire       clk,
    input  wire       rst,
    input  wire [2:0] Snext,     // Trạng thái tiếp theo tính từ Next State Logic
    output reg  [2:0] Sreg       // Trạng thái hiện tại
);
    // Chọn EWDELAY (3'b111) - Đèn Đỏ cả 2 làn.
    localparam EWDELAY = 3'b111;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Sreg <= EWDELAY; // Ép về trạng thái an toàn: Cả 2 làn cùng Đỏ
        end 
        else begin
            Sreg <= Snext;   // Cập nhật trạng thái kế tiếp theo sườn dương clock
        end
    end

endmodule
