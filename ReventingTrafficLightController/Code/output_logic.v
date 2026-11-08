
module output_logic (
    input  wire [2:0] Sreg,      // Trạng thái hiện tại từ State Register
    output wire       NSGREEN,   // Đèn Xanh Bắc - Nam
    output wire       NSYELLOW,  // Đèn Vàng Bắc - Nam
    output wire       NSRED,     // Đèn Đỏ Bắc - Nam
    output wire       EWGREEN,   // Đèn Xanh Đông - Tây
    output wire       EWYELLOW,  // Đèn Vàng Đông - Tây
    output wire       EWRED      // Đèn Đỏ Đông - Tây
);

    // Định nghĩa các mã trạng thái
    localparam NSGO    = 3'b000,
               NSWAIT  = 3'b001,
               NSWAIT2 = 3'b010,
               NSDELAY = 3'b011,
               EWGO    = 3'b100,
               EWWAIT  = 3'b101,
               EWWAIT2 = 3'b110,
               EWDELAY = 3'b111;
    assign NSGREEN  = (Sreg == NSGO);
    assign NSYELLOW = (Sreg == NSWAIT);
    assign NSRED    = ~(NSGREEN | NSYELLOW);
    assign EWGREEN  = (Sreg == EWGO);
    assign EWYELLOW = (Sreg == EWWAIT);
    assign EWRED    = ~(EWGREEN | EWYELLOW);

endmodule
