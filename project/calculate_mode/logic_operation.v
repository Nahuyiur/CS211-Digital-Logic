`timescale 1ns / 1ps

module logic_operation(
    input clk,        
    input reset,       
    input [7:0] a,    
    input [7:0] b,    
    input button_press, //切换与，或，非，异或的按钮
    input enable,      // 使能信号
    output reg [7:0] result,//led显示
    output reg [1:0] state //记录本次状态，用来确定逻辑运算的种类
);

reg [1:0] next_state;//下一次的状态

// 同步复位逻辑
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= 2'b00;
    end else begin
        state <= next_state;
    end
end

// 状态机逻辑，每按一次都进入下一种逻辑运算
always @(*) begin
    case (state)
        2'b00: begin
            if (button_press) next_state = 2'b01;
            else next_state = 2'b00;
        end
        2'b01: begin
            if (button_press) next_state = 2'b10;
            else next_state = 2'b01;
        end
        2'b10: begin
            if (button_press) next_state = 2'b11;
            else next_state = 2'b10;
        end
        2'b11: begin
            if (button_press) next_state = 2'b00;
            else next_state = 2'b11;
        end
        default: next_state = 2'b00;
    endcase
end

// 操作码逻辑
always @(*) begin
    if (enable) begin
        case (state)
            2'b00: result = a & b;       // 与操作
            2'b01: result = a | b;       // 或操作
            2'b10: result = ~a;          // 非操作
            2'b11: result = a ^ b;       // 异或操作
            default: result = 8'b0;      // 默认情况
        endcase
end
end

endmodule