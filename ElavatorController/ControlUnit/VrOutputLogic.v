`include "../Vrparameter.v"
module VrOutputLogic (
    input  wire [NUMBER_STATE - 1:0] current_state,
    output reg                       motor_down,
    output reg                       motor_up,
    output reg                       door_close,
    output reg                       door_open 
);
    always @(*) begin
        if (current_state == DOOR_OPEN) begin
            door_open  = 1'b1;
            door_close = 1'b0;
            motor_down = 1'b0;
            motor_up   = 1'b0;
        end
        else if (current_state == MOVING_UP) begin
            door_open  = 1'b0;
            door_close = 1'b1;
            motor_down = 1'b0;
            motor_up   = 1'b1;
        end
        else if (current_state == MOVING_DOWN) begin
            door_open  = 1'b0;
            door_close = 1'b1;
            motor_down = 1'b1;
            motor_up   = 1'b0;
        end
        else begin
            door_open  = 1'b0;
            door_close = 1'b1;
            motor_down = 1'b0;
            motor_up   = 1'b0;
        end
    end
endmodule
