module Initialization (
    input wire clk,
    input wire reset,
    output reg init_clear     //输出一个清楚信号，竞赛模式中引入一下这个信号就可以，为1 就是清除，为0 就是不清除                         


);
always @(posedge clk or posedge reset) begin
        if (~reset) begin
            init_clear <= 1'b1;
        end else begin
            init_clear <= 1'b0;
        end
    end


    
endmodule