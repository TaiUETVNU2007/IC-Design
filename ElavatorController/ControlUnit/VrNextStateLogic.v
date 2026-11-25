`include "../Vrparameter.v"
module VrNextStateLogic #(
    parameter MIN_FLOOR = 0,
    parameter MAX_FLOOR = 3
) (
    input  wire [1:0]                       current_state,
    input  wire [1:0]                       before_state,
    input  wire [1:0]                       current_floor,
    input  wire                             door_closed,
    input  wire                             door_timeout,
    input  wire                             move_tick,
    input  wire [MAX_FLOOR : MIN_FLOOR]     state_infloor,
    input  wire [MAX_FLOOR - 1 : MIN_FLOOR] state_upcall,
    input  wire [MAX_FLOOR : MIN_FLOOR + 1] state_downcall,
    output reg  [1:0]                       next_state
);
    localparam TOTAL_FLOORS = MAX_FLOOR - MIN_FLOOR + 1;
    wire [MAX_FLOOR : MIN_FLOOR] full_up   = {1'b0, state_upcall};
    wire [MAX_FLOOR : MIN_FLOOR] full_down = {state_downcall, 1'b0};
    wire [MAX_FLOOR : MIN_FLOOR] any_req   = state_infloor | full_up | full_down;
    wire [MAX_FLOOR : MIN_FLOOR] above_mask = {TOTAL_FLOORS{1'b1}} << (current_floor - MIN_FLOOR + 1);
    wire [MAX_FLOOR : MIN_FLOOR] below_mask = ~({TOTAL_FLOORS{1'b1}} << (current_floor - MIN_FLOOR));
    wire req_at_current   = any_req[current_floor];
    wire req_above        =   |(any_req & above_mask);
    wire req_below        = |(any_req & below_mask);
    wire stop_moving_up   = state_infloor[current_floor] | full_up[current_floor]   | (full_down[current_floor] & ~req_above);
    wire stop_moving_down = state_infloor[current_floor] | full_down[current_floor] | (full_up[current_floor]   & ~req_below);
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (req_at_current)
                    next_state = DOOR_OPEN;
                else if (req_above && door_closed)
                    next_state = MOVING_UP;
                else if (req_below && door_closed)
                    next_state = MOVING_DOWN;
                else
                    next_state = IDLE;
            end
            MOVING_UP: begin
                if (move_tick) begin
                    if (stop_moving_up)
                        next_state = DOOR_OPEN;
                    else if (req_above && door_closed)
                        next_state = MOVING_UP;
                    else if (req_below && door_closed)
                        next_state = MOVING_DOWN;
                    else
                        next_state = IDLE;
                end
                else begin
                    next_state = MOVING_UP;
                end
            end
            MOVING_DOWN: begin
                if (move_tick) begin
                    if (stop_moving_down)
                        next_state = DOOR_OPEN;
                    else if (req_below && door_closed)
                        next_state = MOVING_DOWN;
                    else if (req_above && door_closed)
                        next_state = MOVING_UP;
                    else
                        next_state = IDLE;
                end
                else begin
                    next_state = MOVING_DOWN;
                end
            end
            DOOR_OPEN: begin
                if (door_timeout && door_closed) begin
                    if (before_state == MOVING_DOWN) begin
                        if (req_below)
                            next_state = MOVING_DOWN;
                        else if (req_above)
                            next_state = MOVING_UP;
                        else
                            next_state = IDLE;
                    end
                    else begin
                        if (req_above)
                            next_state = MOVING_UP;
                        else if (req_below)
                            next_state = MOVING_DOWN;
                        else
                            next_state = IDLE;
                    end
                end
                else begin
                    next_state = DOOR_OPEN;
                end
            end

            default: next_state = IDLE;
        endcase
    end
endmodule
