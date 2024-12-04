`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 15:10:21
// Design Name: 
// Module Name: practice3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module practice3(
    input rst,
    input clk,
    input eva,
    input [1:0] in1,
    input [1:0] in2,
    output [7:0]seg1,
    output [7:0]seg2,
    output reg o1,
    output reg o2,
    output reg o3,
    output s1,
    output s2
    

);
assign s1 = 1;
assign s2 = 1;
reg [1:0]in11=0;
reg [1:0]in22=0;

always@(posedge clk)begin
    if(!confirm)begin
        in11<=2'b11;in22<=2'b11;
    end
    else begin
        in11<=in1;in22<=in2;
    end
end
display_decoder1 dec1_inst (
            .p1(in11),
            .tub_control1(seg1)
            );
        
display_decoder2 dec2_inst (
            .p2(in22),
            .tub_control2(seg2)
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
        end
        else begin
            {o1,o2,o3}<=3'b000;
        end
    end
    endmodule
module display_decoder1(
    input wire [1:0] p1,
    output reg [7:0] tub_control1
);
    always @(p1) begin  
        case (p1)  
            2'b00: tub_control1 = 8'b00001010;
            2'b01: tub_control1 = 8'b11001110;
            2'b10: tub_control1 = 8'b10110110;
            default: tub_control1 = 8'b00000000;
        endcase  
    end  
endmodule

module display_decoder2(
    input wire [1:0] p2,
    output reg [7:0] tub_control2
);
    always @(p2) begin  
        case (p2)  
            2'b00: tub_control2 = 8'b00001010;
            2'b01: tub_control2 = 8'b11001110;
            2'b10: tub_control2 = 8'b10110110;
            default: tub_control2 = 8'b00000000;
        endcase  
    end  
endmodule

