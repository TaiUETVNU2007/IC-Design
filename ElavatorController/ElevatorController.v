`include "Vrparameter.v"

module ElevatorController #(
    parameter MIN_FLOOR = 0,
    parameter MAX_FLOOR = 3
) (
    input  wire                             CLK,
    input  wire                             RESET,
    input  wire [MAX_FLOOR : MIN_FLOOR]     Carbin_infloor,
    input  wire [MAX_FLOOR - 1 : MIN_FLOOR] Hall_up_call,
    input  wire [MAX_FLOOR : MIN_FLOOR + 1] Hall_down_call,
    input  wire [1:0]                       floor_sensor,
    input  wire                             door_closed_sensor,
    input  wire                             overweight_sensor,
    input  wire                             obstruction_sensor,
    output wire                             motor_up,
    output wire                             motor_down,
    output wire                             door_open,
    output wire                             door_close,
    output wire [1:0]                       current_floor,
    output wire                             safety_alert,
    output wire [MAX_FLOOR : MIN_FLOOR]     req_led_in,
    output wire [MAX_FLOOR - 1 : MIN_FLOOR] req_led_up,
    output wire [MAX_FLOOR : MIN_FLOOR + 1] req_led_down
);

    wire [NUMBER_STATE - 1:0]        current_state;
    wire [NUMBER_STATE - 1:0]        before_state;
    wire                             door_closed;
    wire                             door_timeout;
    wire                             move_tick;
    wire [MAX_FLOOR : MIN_FLOOR]     state_infloor;
    wire [MAX_FLOOR - 1 : MIN_FLOOR] state_upcall;
    wire [MAX_FLOOR : MIN_FLOOR + 1] state_downcall;

    assign req_led_in   = state_infloor;
    assign req_led_up   = state_upcall;
    assign req_led_down = state_downcall;

    VrDataUnit #(
        .MIN_FLOOR(MIN_FLOOR),
        .MAX_FLOOR(MAX_FLOOR)
    ) u_data_unit (
        .CLK                (CLK),
        .RESET              (RESET),
        .current_state      (current_state),
        .before_state       (before_state),
        .Carbin_infloor     (Carbin_infloor),
        .Hall_up_call       (Hall_up_call),
        .Hall_down_call     (Hall_down_call),
        .floor_sensor       (floor_sensor),
        .door_closed_sensor (door_closed_sensor),
        .overweight_sensor  (overweight_sensor),
        .obstruction_sensor (obstruction_sensor),
        .current_floor      (current_floor),
        .door_closed        (door_closed),
        .safety_alert       (safety_alert),
        .door_timeout       (door_timeout),
        .move_tick          (move_tick),
        .state_infloor      (state_infloor),
        .state_upcall       (state_upcall),
        .state_downcall     (state_downcall)
    );

    VrControlUnit #(
        .MIN_FLOOR(MIN_FLOOR),
        .MAX_FLOOR(MAX_FLOOR)
    ) u_control_unit (
        .CLK            (CLK),
        .RESET          (RESET),
        .current_floor  (current_floor),
        .door_closed    (door_closed),
        .door_timeout   (door_timeout),
        .move_tick      (move_tick),
        .state_infloor  (state_infloor),
        .state_upcall   (state_upcall),
        .state_downcall (state_downcall),
        .current_state  (current_state),
        .before_state   (before_state),
        .motor_up       (motor_up),
        .motor_down     (motor_down),
        .door_open      (door_open),
        .door_close     (door_close)
    );

endmodule
