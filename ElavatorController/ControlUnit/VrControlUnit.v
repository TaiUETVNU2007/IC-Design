`include "../Vrparameter.v"

module VrControlUnit #(
    parameter MIN_FLOOR = 0,
    parameter MAX_FLOOR = 3
) (
    input  wire                             CLK,
    input  wire                             RESET,
    input  wire [1:0]                       current_floor,
    input  wire                             door_closed,
    input  wire                             door_timeout,
    input  wire                             move_tick,
    input  wire [MAX_FLOOR : MIN_FLOOR]     state_infloor,
    input  wire [MAX_FLOOR - 1 : MIN_FLOOR] state_upcall,
    input  wire [MAX_FLOOR : MIN_FLOOR + 1] state_downcall,
    output wire [NUMBER_STATE - 1:0]        current_state,
    output wire [NUMBER_STATE - 1:0]        before_state,
    output wire                             motor_up,
    output wire                             motor_down,
    output wire                             door_open,
    output wire                             door_close
);

    wire [NUMBER_STATE - 1:0] next_state;

    VrNextStateLogic #(
        .MIN_FLOOR(MIN_FLOOR),
        .MAX_FLOOR(MAX_FLOOR)
    ) u_next_state_logic (
        .current_state  (current_state),
        .before_state   (before_state),
        .current_floor  (current_floor),
        .door_closed    (door_closed),
        .door_timeout   (door_timeout),
        .move_tick      (move_tick),
        .state_infloor  (state_infloor),
        .state_upcall   (state_upcall),
        .state_downcall (state_downcall),
        .next_state     (next_state)
    );

    VrStateMemory u_state_memory (
        .CLK           (CLK),
        .RESET         (RESET),
        .next_state    (next_state),
        .current_state (current_state),
        .before_state  (before_state)
    );

    VrOutputLogic u_output_logic (
        .current_state (current_state),
        .motor_down    (motor_down),
        .motor_up      (motor_up),
        .door_close    (door_close),
        .door_open     (door_open)
    );

endmodule
