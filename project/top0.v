`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/25 20:45:52
// Design Name: 
// Module Name: top0
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


module top0(
input clk,
output  [7:0] anode,     
output  [7:0] seg1,
output [7:0] seg2

);

 
 scan_display dut(
 .clk(clk),
 .anode(anode),
 .seg1(seg1),
 .seg2(seg2)
 
 
 );   
endmodule
