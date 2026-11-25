`include "../Vrparameter.v"
module VrTimer (
    input  wire                      CLK,
    input  wire                      RESET,
    input  wire [NUMBER_STATE - 1:0] current_state,
    input  wire                      safety_alert,
    output reg                       door_timeout,
    output reg                       move_tick
);
    reg [2:0] Count;
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            door_timeout <= 1'b0;
            move_tick    <= 1'b0;
            Count        <= 3'd0;
        end
        else begin
            door_timeout <= 1'b0;
            move_tick    <= 1'b0;
            if (current_state == DOOR_OPEN) begin
                if (safety_alert) begin
                    Count <= 3'd0;
                end
                else if (Count == DOOR_TIMEOUT_TICKS - 1) begin
                    door_timeout <= 1'b1;
                    Count        <= 3'd0;
                end
                else begin
                    Count <= Count + 3'd1;
                end
            end
            else if (current_state == MOVING_UP || current_state == MOVING_DOWN) begin
                if (Count == MOVE_FLOOR_TICKS - 1) begin
                    move_tick <= 1'b1;
                    Count     <= 3'd0;
                end
                else begin
                    Count <= Count + 3'd1;
                end
            end
            else begin
                Count <= 3'd0;
            end
        end
    end

endmodule
