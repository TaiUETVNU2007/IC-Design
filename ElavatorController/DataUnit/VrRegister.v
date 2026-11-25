
`include "../Vrparameter.v"
module VrRegister (
    input  wire        CLK,
    input  wire        RESET,
    input  wire [1:0]  current_state,  
    input  wire [1:0]  before_state,   
    input  wire [1:0]  current_floor,  
    input  wire [3:0]  clean_infloor,  
    input  wire [2:0]  clean_upcall,   
    input  wire [3:1]  clean_downcall, 
    output reg  [3:0]  state_infloor,
    output reg  [2:0]  state_upcall,
    output reg  [3:1]  state_downcall
);
    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            state_infloor  <= 4'b0000;
            state_upcall   <= 3'b000;
            state_downcall <= 3'b000;
        end 
        else begin
            state_infloor  <= state_infloor  | clean_infloor;
            state_upcall   <= state_upcall   | clean_upcall;
            state_downcall <= state_downcall | clean_downcall;
            if (current_state == DOOR_OPEN) begin
                case (current_floor)
                    2'd0: state_infloor[0] <= 1'b0;
                    2'd1: state_infloor[1] <= 1'b0;
                    2'd2: state_infloor[2] <= 1'b0;
                    2'd3: state_infloor[3] <= 1'b0;
                endcase
                if (before_state == MOVING_UP) begin
                    case (current_floor)
                        2'd0: state_upcall[0] <= 1'b0;
                        2'd1: state_upcall[1] <= 1'b0;
                        2'd2: state_upcall[2] <= 1'b0;
                        2'd3: state_downcall[3] <= 1'b0; 
                    endcase
                end 
                else if (before_state == MOVING_DOWN) begin
                    case (current_floor)
                        2'd0: state_upcall[0] <= 1'b0;   
                        2'd1: state_downcall[1] <= 1'b0;
                        2'd2: state_downcall[2] <= 1'b0;
                        2'd3: state_downcall[3] <= 1'b0;
                    endcase
                end
                else begin 
                    case (current_floor)
                        2'd0: state_upcall[0] <= 1'b0;
                        2'd1: begin state_upcall[1] <= 1'b0; state_downcall[1] <= 1'b0; end
                        2'd2: begin state_upcall[2] <= 1'b0; state_downcall[2] <= 1'b0; end
                        2'd3: state_downcall[3] <= 1'b0;
                    endcase
                end
            end 
        end
    end
endmodule