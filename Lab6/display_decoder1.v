module display_decoder1(
    input wire [1:0] p1,
    output reg [7:0] tub_control1
);
    always @(p1) begin  
        case (p1)  
            2'b00: tub_control1 = 8'b00001010;
            2'b01: tub_control1 = 8'b11001110;
            2'b10: tub_control1 = 8'b10110110;
            default: tub_control1 = 8'b10011110;
        endcase  
    end  
endmodule
