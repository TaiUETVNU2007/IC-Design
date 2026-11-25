
`ifndef VRPARAMETER_VH
`define VRPARAMETER_VH
    parameter MIN_FLOOR = 0;
    parameter MAX_FLOOR = 3;
    parameter NUM_FLOORS = MAX_FLOOR - MIN_FLOOR + 1; // 4 tầng
    parameter NUMBER_STATE =2;
    parameter IDLE        = 2'b00;
    parameter MOVING_UP   = 2'b01;
    parameter MOVING_DOWN = 2'b10;
    parameter DOOR_OPEN   = 2'b11;
    parameter DOOR_TIMEOUT_TICKS = 5; // 5 xung mở cửa
    parameter MOVE_FLOOR_TICKS   = 3; // 3 xung chuyển tầng
`endif
