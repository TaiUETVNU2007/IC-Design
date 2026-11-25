
`include "../Vrparameter.v"
module VrInputRegister #(
    parameter MIN_FLOOR = 0,
    parameter MAX_FLOOR = 3
) (
    input  wire        CLK,
    input  wire        RESET,
    input  wire [MAX_FLOOR : MIN_FLOOR]     Carbin_infloor,  
    input  wire [MAX_FLOOR - 1 : MIN_FLOOR] Hall_up_call,   
    input  wire [MAX_FLOOR : MIN_FLOOR + 1] Hall_down_call,  
    output reg  [MAX_FLOOR : MIN_FLOOR]     clean_infloor,
    output reg  [MAX_FLOOR - 1 : MIN_FLOOR] clean_upcall,
    output reg  [MAX_FLOOR : MIN_FLOOR + 1] clean_downcall
);

    localparam TOTAL_FLOORS = MAX_FLOOR - MIN_FLOOR + 1;
    localparam CALL_FLOORS  = MAX_FLOOR - MIN_FLOOR;
    reg [MAX_FLOOR : MIN_FLOOR]     sync_infloor_1,  sync_infloor_2;
    reg [MAX_FLOOR - 1 : MIN_FLOOR] sync_upcall_1,   sync_upcall_2;
    reg [MAX_FLOOR : MIN_FLOOR + 1] sync_downcall_1, sync_downcall_2;

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            sync_infloor_1  <= {TOTAL_FLOORS{1'b0}};
            sync_infloor_2  <= {TOTAL_FLOORS{1'b0}};

            sync_upcall_1   <= {CALL_FLOORS{1'b0}};
            sync_upcall_2   <= {CALL_FLOORS{1'b0}};

            sync_downcall_1 <= {CALL_FLOORS{1'b0}};
            sync_downcall_2 <= {CALL_FLOORS{1'b0}};

            // Reset các ngõ ra xung sạch
            clean_infloor   <= {TOTAL_FLOORS{1'b0}};
            clean_upcall    <= {CALL_FLOORS{1'b0}};
            clean_downcall  <= {CALL_FLOORS{1'b0}};
        end 
        else begin
            // Đồng bộ hóa tín hiệu nút bấm vào miền xung CLK
            sync_infloor_1  <= Carbin_infloor;
            sync_infloor_2  <= sync_infloor_1;

            sync_upcall_1   <= Hall_up_call;
            sync_upcall_2   <= sync_upcall_1;

            sync_downcall_1 <= Hall_down_call;
            sync_downcall_2 <= sync_downcall_1;

            // 2. Mạch phát hiện cạnh lên (0 -> 1) tạo xung sạch 1 chu kỳ clock:
            // - Tránh trường hợp người dùng ấn giữ nút quá lâu.
            // - Đảm bảo thang máy xóa trạng thái phục vụ về 0 không bị ghi đè lại.
            clean_infloor   <= sync_infloor_1  & ~sync_infloor_2;
            clean_upcall    <= sync_upcall_1   & ~sync_upcall_2;
            clean_downcall  <= sync_downcall_1 & ~sync_downcall_2;
        end
    end
endmodule
