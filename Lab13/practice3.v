module practice3(
    input rst,
    input clk,
    input eva,
    input [2:0] in1,
    input [2:0] in2,
    output seg1,
    output seg2,
    output o1,
    output o2,
    output o3
);
    reg confirm=1'b0;
    always@(posedge clk,negedge rst)begin
        if(!rst)begin
            confirm<=1'b0;
        end
        else begin
            if(eva)begin
                confirm<=1'b1;
            end
            else
                confirm<=confirm;
        end
    end
    
    always@(posedge clk)begin
        if(confirm)begin
            case ({in1, in2})  
            4'b0001, 4'b0110, 4'b1000:
                {o1, o2, o3} <= 3'b010;
            4'b0010, 4'b0100, 4'b1001:
                {o1, o2, o3} <= 3'b100;
            4'b0000, 4'b0101, 4'b1010:
                {o1, o2, o3} <= 3'b001;
            default:
                {o1, o2, o3} <= 3'b000;
            endcase 

        display_decoder1 dec1_inst (
            .p1(in1),
            .tub_control1(seg1)
            );
        
        display_decoder2 dec2_inst (
            .p2(in2),
            .tub_control2(seg2)
            );
        end

        else 

        begin
            o1<=0;o2<=0;o3<=0;
            display_decoder1 dec1_inst (
            .p1(3'b000),
            .tub_control1(seg1)
            );
        
        display_decoder2 dec2_inst (
            .p2(3'b000),
            .tub_control2(seg2)
            );
        end
    end
    endmodule
module display_decoder1(
    input wire [2:0] p1,
    output reg [7:0] tub_control1
);
    always @(p1) begin  
        case (p1)  
            2'b001: tub_control1 = 8'b00001010;
            2'b010: tub_control1 = 8'b11001110;
            2'b100: tub_control1 = 8'b10110110;
            default: tub_control1 = 8'b00000000;
        endcase  
    end  
endmodule

module display_decoder2(
    input wire [2:0] p2,
    output reg [7:0] tub_control2
);
    always @(p2) begin  
        case (p2)  
            2'b001: tub_control2 = 8'b00001010;
            2'b010: tub_control2 = 8'b11001110;
            2'b100: tub_control2 = 8'b10110110;
            default: tub_control2 = 8'b00000000;
        endcase  
    end  
endmodule
