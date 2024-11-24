`timescale 1ns / 1ps

module cal_top(
    input clk,                      // 时钟信号
    input reset,                    // 复位信号
    input enable,                   // 进入退出模式的按钮
    input button_press,             // 切换逻辑运算的按钮      
    input [7:0] a,                  // 逻辑操作数a
    input [7:0] b,                  // 逻辑操作数b   
    input [3:0] shift_op,           // 移位操作选择
    input [1:0] signed_op,          // 有符号数操作选择
    input [3:0] bitwise_op,         // 位运算操作选择
    input [3:0] logic_op,           // 逻辑运算操作选择
    output [6:0] seg1,              // 八进制百位数码管显示
    output [6:0] seg2,              // 八进制十位数码管显示
    output [6:0] seg3,              // 八进制个位数码管显示
    output [6:0] seg4,              // 十进制百位数码管显示
    output [6:0] seg5,              // 十进制十位数码管显示
    output [6:0] seg6,              // 十进制个位数码管显示
    output [6:0] seg7,              // 十六进制高位数码管显示
    output [6:0] seg8,              // 十六进制低位数码管显示
    output [7:0] leds,              // LED显示
);

 reg [4:0] current_state = 5'b00001; // 当前状态
 reg [4:0] next_state;   // 下一个状态
 reg mode_entered;//0为未进入模式，1为已确认进入模式
    // 计算类型定义
    localparam STATE_BINARY_CONVERTER = 5'b00001,
               STATE_SIGNED_CALCULATE = 5'b00010,
               STATE_SHIFT_OPERATION = 5'b00100,
               STATE_BITWISE_OPERATION = 5'b01000,
               STATE_LOGIC_OPERATION = 5'b10000;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= STATE_BINARY_CONVERTER;//初始模式为进制转换
        mode_entered <= 0;//初始默认未进入模式
    end 
    else if (button_press && !mode_entered) begin
        current_state <= next_state;//若未进入模式，则可以切换模式
        mode_entered <= 1;//同时记录进入模式
    end 
    else if (!mode_entered && enable) begin
            mode_entered <= 1;//若未进入模式，按下enable键进入模式
    end
    else if (mode_entered && enable) begin
        mode_entered <= 0; // 若已进入模式，则按下enable键退出模式
    end
end

    // 确定下一个状态
    always @() begin
        case (current_state)
            STATE_BINARY_CONVERTER: next_state = STATE_SIGNED_CALCULATE;
            STATE_SIGNED_CALCULATE: next_state = STATE_SHIFT_OPERATION;
            STATE_SHIFT_OPERATION: next_state = STATE_BITWISE_OPERATION;
            STATE_BITWISE_OPERATION: next_state = STATE_LOGIC_OPERATION;
            STATE_LOGIC_OPERATION: next_state = STATE_BINARY_CONVERTER;
            default: next_state = STATE_BINARY_CONVERTER;
        endcase
    end

    // 内部寄存器定义
    reg [1:0] next_signed_op;
    reg [3:0] next_bitwise_op;
    reg [3:0] next_logic_op;
    reg [3:0] next_shift_op;

    // 状态机逻辑
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            next_signed_op <= 2'b01;
            next_bitwise_op <= 4'b0001;
            next_logic_op <= 4'b0001;
            next_shift_op <= 4'b0001;
        end else begin
            case (current_state)
            STATE_SIGNED_CALCULATE:
            case (signed_op)
        2'b01: begin
            if (button_press) next_op = 2'b10;
            else next_op = 2'b01;
        end
        2'b10: begin
            if (button_press) next_op = 2'b01;
            else next_op = 2'b10;
        end
        default: next_op = 2'b01;
    endcase
            STATE_SHIFT_OPERATION:
            case (shift_op)
        4'b0001: begin
            if (button_press) next_op = 4'b0010;
            else next_op = 4'b0001;
        end
        4'b0010: begin
            if (button_press) next_op = 4'b0100;
            else next_op = 4'b0010;
        end
        4'b0100: begin
            if (button_press) next_op = 4'b1000;
            else next_op = 4'b0100;
        end
        4'b1000: begin
            if (button_press) next_op = 4'b0001;
            else next_op = 4'b1000;
        end
        default: next_op = 4'b0001;
    endcase
        STATE_BITWISE_OPERATION:
        case (bitwise_op)
        4'b0001: begin
            if (button_press) next_op = 4'b0010;
            else next_op = 4'b0001;
        end
        4'b0010: begin
            if (button_press) next_op = 4'b0100;
            else next_op = 4'b0010;
        end
        4'b0100: begin
            if (button_press) next_op = 4'b1000;
            else next_op = 4'b0100;
        end
        4'b1000: begin
            if (button_press) next_op = 4'b0001;
            else next_op = 4'b1000;
        end
        default: next_op = 4'b0001;
    endcase
    STATE_LOGIC_OPERATION:
     case (logic_op)
        4'b0001: begin
            if (button_press) next_op = 4'b0010;
            else next_op = 4'b0001;
        end
        4'b0010: begin
            if (button_press) next_op = 4'b0100;
            else next_op = 4'b0010;
        end
        4'b0100: begin
            if (button_press) next_op = 4'b1000;
            else next_op = 4'b0100;
        end
        4'b1000: begin
            if (button_press) next_op = 4'b0001;
            else next_op = 4'b1000;
        end
        default: next_op = 4'b0001;
    endcase
        
    endcase
        end
    end

   
    if (current_state == 5'b00001&&mode_entered==1) begin// Binary Converter Module
    binary_converter u_binary_converter (
        .binary(a),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .seg4(seg4),
        .seg5(seg5),
        .seg6(seg6),
        .seg7(seg7),
        .seg8(seg8),
        .leds(leds)
    );
    end
    else if (current_state == 5'b00010&&mode_entered==1) begin// Signed Calculate Module
    signed_calculate u_signed_calculate(
        .a(a),
        .b(b),
        .op(signed_op),
        .seg1(signed_seg1),
        .seg2(signed_seg2),
        .seg3(signed_seg3)
    );
    end
    else if (current_state == 5'b00100&&mode_entered==1) begin// Shift Operation Module
    shift_operation u_shift_operation(
        .a(a),
        .b(b),
        .op(shift_op),
        .leds(leds)
    );
    end
    else if (current_state == 5'b01000&&mode_entered==1) begin// Bitwise Operation Module
         bitwise u_bitwise(
        .a(a),
        .b(b),
        .op(bitwise_op),
        .result(leds)
    );
    end
    else if (current_state == 5'b10000&&mode_entered==1) begin// Logic Operation Module
    logic_operation u_logic_operation(
        .a(a),
        .b(b),
        .op(logic_op),
        .result(leds)
    );
    end
   
endmodule