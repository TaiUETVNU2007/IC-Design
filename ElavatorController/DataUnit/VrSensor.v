`include "../Vrparameter.v"

module VrSensor #(
    parameter MAX_FLOOR = 3,
    parameter MIN_FLOOR = 0
)(
    input  wire       CLK,
    input  wire       RESET,
    input  wire [1:0] floor_sensor,
    input  wire       door_closed_sensor,
    input  wire       overweight_sensor,
    input  wire       obstruction_sensor,
    output reg  [1:0] current_floor,
    output reg        door_closed,
    output reg        safety_alert
);

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            current_floor <= 2'b00;
            door_closed   <= 1'b1;
            safety_alert  <= 1'b0;
        end
        else begin
            current_floor <= floor_sensor;
            door_closed   <= door_closed_sensor;
            // LƯU Ý LOGIC: Gán trực tiếp biểu thức OR để khi hết vật cản/quá tải,
            // safety_alert tự động trở về 0 (cũ chỉ có if bật lên 1 mà không có nhánh tắt về 0)
            safety_alert  <= overweight_sensor | obstruction_sensor;
        end
    end

endmodule
