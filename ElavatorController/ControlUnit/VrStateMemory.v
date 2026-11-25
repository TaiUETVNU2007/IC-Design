`include "../Vrparameter.v"
module VrStateMemory (
    input  wire                      CLK,
    input  wire                      RESET,
    input  wire [NUMBER_STATE - 1:0] next_state,
    output reg  [NUMBER_STATE - 1:0] current_state,
    output reg  [NUMBER_STATE - 1:0] before_state
);
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            current_state <= IDLE;
            before_state  <= IDLE;
        end
        else begin
            current_state <= next_state;
            if (current_state != DOOR_OPEN) begin
                before_state <= current_state;
            end
        end
    end

endmodule
