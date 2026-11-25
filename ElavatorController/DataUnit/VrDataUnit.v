`include "../Vrparameter.v"

module VrDataUnit #(
    parameter MIN_FLOOR = 0,
    parameter MAX_FLOOR = 3
) (
    input  wire                             CLK,
    input  wire                             RESET,
    input  wire [NUMBER_STATE - 1:0]        current_state,
    input  wire [NUMBER_STATE - 1:0]        before_state,
    input  wire [MAX_FLOOR : MIN_FLOOR]     Carbin_infloor,
    input  wire [MAX_FLOOR - 1 : MIN_FLOOR] Hall_up_call,
    input  wire [MAX_FLOOR : MIN_FLOOR + 1] Hall_down_call,
    input  wire [1:0]                       floor_sensor,
    input  wire                             door_closed_sensor,
    input  wire                             overweight_sensor,
    input  wire                             obstruction_sensor,
    output wire [1:0]                       current_floor,
    output wire                             door_closed,
    output wire                             safety_alert,
    output wire                             door_timeout,
    output wire                             move_tick,
    output wire [MAX_FLOOR : MIN_FLOOR]     state_infloor,
    output wire [MAX_FLOOR - 1 : MIN_FLOOR] state_upcall,
    output wire [MAX_FLOOR : MIN_FLOOR + 1] state_downcall
);

    wire [MAX_FLOOR : MIN_FLOOR]     clean_infloor;
    wire [MAX_FLOOR - 1 : MIN_FLOOR] clean_upcall;
    wire [MAX_FLOOR : MIN_FLOOR + 1] clean_downcall;

    VrInputRegister #(
        .MIN_FLOOR(MIN_FLOOR),
        .MAX_FLOOR(MAX_FLOOR)
    ) u_input_register (
        .CLK            (CLK),
        .RESET          (RESET),
        .Carbin_infloor (Carbin_infloor),
        .Hall_up_call   (Hall_up_call),
        .Hall_down_call (Hall_down_call),
        .clean_infloor  (clean_infloor),
        .clean_upcall   (clean_upcall),
        .clean_downcall (clean_downcall)
    );

    VrRegister u_register (
        .CLK            (CLK),
        .RESET          (RESET),
        .current_state  (current_state),
        .before_state   (before_state),
        .current_floor  (current_floor),
        .clean_infloor  (clean_infloor),
        .clean_upcall   (clean_upcall),
        .clean_downcall (clean_downcall),
        .state_infloor  (state_infloor),
        .state_upcall   (state_upcall),
        .state_downcall (state_downcall)
    );

    VrSensor #(
        .MAX_FLOOR(MAX_FLOOR),
        .MIN_FLOOR(MIN_FLOOR)
    ) u_sensor (
        .CLK                (CLK),
        .RESET              (RESET),
        .floor_sensor       (floor_sensor),
        .door_closed_sensor (door_closed_sensor),
        .overweight_sensor  (overweight_sensor),
        .obstruction_sensor (obstruction_sensor),
        .current_floor      (current_floor),
        .door_closed        (door_closed),
        .safety_alert       (safety_alert)
    );

    VrTimer u_timer (
        .CLK           (CLK),
        .RESET         (RESET),
        .current_state (current_state),
        .safety_alert  (safety_alert),
        .door_timeout  (door_timeout),
        .move_tick     (move_tick)
    );

endmodule
