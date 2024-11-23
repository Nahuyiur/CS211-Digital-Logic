module comparator(
    input wire [1:0] p1,
    input wire [1:0] p2,
    output reg o1,
    output reg o2,
    output reg o3
);
    always @(p1, p2) begin  
        case ({p1, p2})  
            4'b0001, 4'b0110, 4'b1000:
                {o1, o2, o3} = 3'b010;
            4'b0010, 4'b0100, 4'b1001:
                {o1, o2, o3} = 3'b100;
            4'b0000, 4'b0101, 4'b1010:
                {o1, o2, o3} = 3'b001;
            default:
                {o1, o2, o3} = 3'b000;
        endcase  
    end  
endmodule
