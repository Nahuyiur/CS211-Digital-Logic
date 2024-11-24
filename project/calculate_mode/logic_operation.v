`timescale 1ns / 1ps

module logic_operation(
    input [7:0] a,    
    input [7:0] b,    
    output reg [7:0] result,//led显示
    output reg [3:0] op //记录本次状态，用来确定逻辑运算的种类
);
initial begin
    op = 4'b0000;
end
// 操作码逻辑
always @(*) begin
        case (op)
            4'b0001: result = a & b;       // 与操作
            4'b0010: result = a | b;       // 或操作
            4'b0100: result = ~a;          // 非操作
            4'b1000: result = a ^ b;       // 异或操作
            default: result = 8'b0;      // 默认情况
        endcase
end

endmodule