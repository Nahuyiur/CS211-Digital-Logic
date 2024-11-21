module display_decoder2(
    input wire [1:0] p2,
    output reg [7:0] tub_control2
);
    always @(p2) begin  
        case (p2)  
            2'b00: tub_control2 = 8'b00001010;
            2'b01: tub_control2 = 8'b11001110;
            2'b10: tub_control2 = 8'b10110110;
            default: tub_control2 = 8'b10011110;
        endcase  
    end  
endmodule
