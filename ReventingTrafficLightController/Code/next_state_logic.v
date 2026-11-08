
module next_state_logic (
    input  wire [2:0] Sreg,      
    input  wire       NSCAR,     
    input  wire       EWCAR,     
    input  wire       TMSHORT,   
    input  wire       TMLONG,    
    output reg  [2:0] Snext,     
    output reg        TMRESET    
);
    localparam NSGO    = 3'b000, 
               NSWAIT  = 3'b001, 
               NSWAIT2 = 3'b010, // Đệm An Toàn 1 Cả 2 làn cùng Đỏ
               NSDELAY = 3'b011, // Đệm An Toàn 2 
               EWGO    = 3'b100, // Đông - Tây Xanh, Bắc - Nam Đỏ
               EWWAIT  = 3'b101, // Đông - Tây Vàng, Bắc - Nam Đỏ
               EWWAIT2 = 3'b110, // Đệm An Toàn 1 Cả 2 làn cùng Đỏ
               EWDELAY = 3'b111; // Đệm An Toàn 2 

    always @(*) begin
        TMRESET = 1'b0;
        case (Sreg)
            NSGO: begin
                if (~TMSHORT) begin
                    Snext   = NSGO;
                    TMRESET = 1'b0;
                end 
                else begin
                    if (NSCAR && ~TMLONG && ~EWCAR) begin
                        Snext   = NSGO;   // Tiếp tục gia hạn Đèn Xanh
                        TMRESET = 1'b0;
                    end 
                    else begin
                        Snext   = NSWAIT; // Chuyển sang Đèn Vàng Bắc - Nam
                        TMRESET = 1'b1;   
                    end
                end
            end

            NSWAIT: begin
                if (TMSHORT) begin
                    Snext   = NSWAIT2; // Chuyển sang Đệm an toàn 1 (All-Red)
                    TMRESET = 1'b1;    // Kích hoạt reset Timer
                end 
                else begin
                    Snext   = NSWAIT;  // Tiếp tục giữ Đèn Vàng
                    TMRESET = 1'b0;
                end
            end

            NSWAIT2: begin
                // Đệm an toàn 1 (Safety Tick 1: Cả 2 làn cùng Đỏ)
                Snext   = NSDELAY;     
                TMRESET = 1'b1;        
            end

            NSDELAY: begin
                // Đệm an toàn 2 (Safety Tick 2: Cả 2 làn cùng Đỏ)
                Snext   = EWGO;        // Chuyển giao quyền ưu tiên sang Đông - Tây Xanh
                TMRESET = 1'b1;        
            end
            EWGO: begin
                if (~TMSHORT) begin
                    // Giai đoạn 1: 0 -> 5s (Bắt buộc giữ Xanh Đông - Tây)
                    Snext   = EWGO;
                    TMRESET = 1'b0;
                end 
                else begin
                    if (EWCAR && ~TMLONG && ~NSCAR) begin
                        Snext   = EWGO;  
                        TMRESET = 1'b0;
                    end 
                    else begin
                        Snext   = EWWAIT;
                        TMRESET = 1'b1;   
                    end
                end
            end

            EWWAIT: begin
                if (TMSHORT) begin
                    Snext   = EWWAIT2; 
                    TMRESET = 1'b1;   
                end 
                else begin
                    Snext   = EWWAIT;  
                    TMRESET = 1'b0;
                end
            end

            EWWAIT2: begin
                Snext   = EWDELAY;     // Chuyển tiếp sang Đệm an toàn 2
                TMRESET = 1'b1;      
            end

            EWDELAY: begin
                Snext   = NSGO;        
                TMRESET = 1'b1;        
            end
            default: begin
                Snext   = EWDELAY;
                TMRESET = 1'b1;
            end
        endcase
    end

endmodule
