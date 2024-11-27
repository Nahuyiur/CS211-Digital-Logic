`timescale 1ns / 1ps

module cal_top(
    input clk,                // 时钟信号
    input reset,              // 复位信号
    input confirm,            // 确定操作的按钮
    input exit,               // 退出按钮
    input select,             // 切换按钮   
    input [7:0] in,           // 拨码开关的输入   
    output [7:0] Seg1,        // 前四个数码管
    output [7:0] Seg2,        // 后四个数码管
    output reg [7:0] leds,    // LED显示
    output [7:0] anode        // 数码管使能信号（动态扫描）
);

reg [7:0] seg1= 8'b0;    // 最终传入scan-display的数码管
reg [7:0] seg2= 8'b0;     
reg [7:0] seg3= 8'b0;             
reg [7:0] seg4= 8'b0;
reg [7:0] seg5= 8'b0; 
reg [7:0] seg6= 8'b0;     
reg [7:0] seg7= 8'b0;             
reg [7:0] seg8= 8'b0;
wire [7:0] seg11= 8'b0;     // 第一个模式的数码管输出
wire [7:0] seg12= 8'b0;  
wire [7:0] seg13= 8'b0;  
wire [7:0] seg14= 8'b0;  
wire [7:0] seg15= 8'b0;  
wire [7:0] seg16= 8'b0;  
wire [7:0] seg17= 8'b0;  
wire [7:0] seg18= 8'b0;  
wire [7:0] seg21= 8'b0;     // 第二个模式的数码管输出
wire [7:0] seg22= 8'b0;
wire [7:0] seg23= 8'b0;
wire [7:0] result3= 8'b0;   // 第三种模式的 LED 输出
wire [7:0] result4= 8'b0;   // 第四种模式的 LED 输出
wire [7:0] result5= 8'b0;   // 第五种模式的 LED 输出

reg [4:0] mode = 5'b00001;            // 模式选择
reg [3:0] op = 4'b0001;              // 运算操作选择
reg [1:0] store = 2'b0;           // 存储状态,00为未操作，01为存储a,10为存储b,11为输出结果
reg [7:0] a = 8'b0;               // 运算数 a
reg [7:0] b = 8'b0;               // 运算数 b
reg mode_entered = 0;          // 0为未进入模式，1为已进入模式

localparam CLK_FREQ = 50000000; // 假设时钟频率为 50MHz
localparam DELAY_COUNT = CLK_FREQ / 2; // 0.5秒延迟的计数值

reg [24:0] counter = 0; // 计数器，足够容纳 25M 的值
reg delay_trigger = 0;  // 触发信号

// 实例化子模块
binary_converter u_binary_converter (
    .binary(a),
    .seg1(seg11),
    .seg2(seg12),
    .seg3(seg13),
    .seg4(seg14),
    .seg5(seg15),
    .seg6(seg16),
    .seg7(seg17),
    .seg8(seg18)
);

signed_calculate u_signed_calculate(
    .a(a),
    .b(b),
    .op(op),
    .seg1(seg21),
    .seg2(seg22),
    .seg3(seg23)
);

shift_operation u_shift_operation(
    .a(a),
    .b(b),
    .op(op),
    .result(result3)
);

bitwise u_bitwise(
    .a(a),
    .b(b),
    .op(op),
    .result(result4)
);

logic_operation u_logic_operation(
    .a(a),
    .b(b),
    .op(op),
    .result(result5)
);

scan_display scan(
    .clk(clk),                   // 输入时钟信号
    .anode(anode),              // 数码管使能信号（动态扫描）
    .data1(seg1),
    .data2(seg2),
    .data3(seg3),
    .data4(seg4),
    .data5(seg5),
    .data6(seg6),
    .data7(seg7),
    .data8(seg8),
    .seg1(Seg1), 
    .seg2(Seg2)
);

always @(posedge clk) begin//该模块用于设定按下按钮的时间
    
        if (counter < DELAY_COUNT - 1) begin
            counter <= counter + 1;
            delay_trigger <= 0;
        end else begin
            counter <= 0;
            delay_trigger <= 1; // 触发信号
        end
end

always @(posedge clk) begin//该模块用于进入和退出模式
    if(confirm&&delay_trigger) begin
        mode_entered <= 1;            
    end 
    if(exit&&delay_trigger) begin
        mode_entered <= 0;            
    end 
end


always @(posedge clk) begin// 模式切换
    if(~mode_entered&&delay_trigger) begin
    if (select) begin
        case (mode)
            5'b00001: mode <= 5'b00010;
            5'b00010: mode <= 5'b00100;
            5'b00100: mode <= 5'b01000;
            5'b01000: mode <= 5'b10000;
            5'b10000: mode <= 5'b00001;
        endcase
    end
    end
end


always @(posedge clk) begin// 操作符切换
    if(mode_entered&&delay_trigger)begin
    if (select) begin
        case (op)
            4'b0001: op <= 4'b0010;
            4'b0010: op <= 4'b0100;
            4'b0100: op <= 4'b1000;
            4'b1000: op <= 4'b0001;
        endcase
    end
    end
end

always @(posedge clk) begin//操作情况切换
    if(mode_entered&&delay_trigger)begin
    if (confirm) begin
        case (store)
            2'b00: store <=2'b01;
            2'b01: store <=2'b10;
            2'b10: store <=2'b11;
            2'b11: store <=2'b00;
        endcase
    end
    end
end


always @(posedge clk) begin//控制leds和seg的输出
        case(mode_entered)
        0: begin
            seg2<=8'b0;
            seg3<=8'b0;
            seg4<=8'b0;
            seg5<=8'b0;
            seg6<=8'b0;
            seg7<=8'b0;
            seg8<=8'b0;
            leds<=8'b0;
        case (mode)
                5'b00001: seg1 <= 8'b0110_0000; 
                5'b00010: seg1 <= 8'b1101_1010; 
                5'b00100: seg1 <= 8'b1111_0010; 
                5'b01000: seg1 <= 8'b0110_0110; 
                5'b10000: seg1 <= 8'b1011_0110; 
                default: seg1 <= 8'b0000_0000; // 默认值以防未定义操作
        endcase
   
        end
        1: begin
            if(store!=11) begin
            seg5<=8'b0;
            seg6<=8'b0;
            seg7<=8'b0;
            seg8<=8'b0;
            case (op)
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; // 默认值以防未定义操作
            endcase
            end
    case(store)
    2'b00: begin
         case (op)
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; // 默认值以防未定义操作
            endcase
        case (mode)
                5'b00001: seg1 <= 8'b0110_0000; 
                5'b00010: seg1 <= 8'b1101_1010; 
                5'b00100: seg1 <= 8'b1111_0010; 
                5'b01000: seg1 <= 8'b0110_0110; 
                5'b10000: seg1 <= 8'b1011_0110; 
                default: seg1 <= 8'b0000_0000; // 默认值以防未定义操作
        endcase
        seg3 <=8'b0;
        seg4 <=8'b0;
        leds <= 8'b0;
    end
    2'b01: begin
         case (op)
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; // 默认值以防未定义操作
            endcase
        case (mode)
                5'b00001: seg1 <= 8'b0110_0000; 
                5'b00010: seg1 <= 8'b1101_1010; 
                5'b00100: seg1 <= 8'b1111_0010; 
                5'b01000: seg1 <= 8'b0110_0110; 
                5'b10000: seg1 <= 8'b1011_0110; 
                default: seg1 <= 8'b0000_0000; // 默认值以防未定义操作
        endcase
        seg3 <= 8'b00111010;
        seg4 <= 8'b0;
        leds <= in;
        a<=in;
    end
    2'b10: begin
         case (op)
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; // 默认值以防未定义操作
            endcase
        case (mode)
                5'b00001: seg1 <= 8'b0110_0000; 
                5'b00010: seg1 <= 8'b1101_1010; 
                5'b00100: seg1 <= 8'b1111_0010; 
                5'b01000: seg1 <= 8'b0110_0110; 
                5'b10000: seg1 <= 8'b1011_0110; 
                default: seg1 <= 8'b0000_0000; // 默认值以防未定义操作
        endcase
        seg3 <= 8'b00111010;
        seg4 <= 8'b00111110;
        leds <= in;
        b<=in;
    end
    2'b11: begin
        case (mode) 
            5'b00001: begin
                convert_binary(a,seg1,seg2,seg3,seg4,seg5,seg6,seg7,seg8);
                leds<=8'b0;
            end
            5'b00010: begin
            seg1 <= seg21;
            seg2 <= seg22;
            seg3 <= seg23;
            seg4<=8'b0;
            seg5<=8'b0;
            seg6<=8'b0;
            seg7<=8'b0;
            seg8<=8'b0;
            leds<=8'b0;
            end
            5'b00100: begin
            signed_operation(a,b,op,seg1,seg2,seg3);
            end
            5'b01000: begin
            bitwise_operation(a,b,op,leds);
            end
            5'b10000: begin
            leds <= result5;
            end
        endcase
        end
    endcase
        end
    endcase
end

task convert_binary;
        input [7:0] bin_value; // 输入的二进制值
        output [3:0] octal_hundreds_out; // 八进制百位输出
        output [3:0] octal_tens_out;     // 八进制十位输出
        output [3:0] octal_ones_out;     // 八进制个位输出
        
        output [3:0] decimal_hundreds_out; // 十进制百位输出
        output [3:0] decimal_tens_out;     // 十进制十位输出
        output [3:0] decimal_ones_out;     // 十进制个位输出

        output [3:0] hex_high_out;         // 十六进制高位输出
        output [3:0] hex_low_out;          // 十六进制低位输出
    begin
        // 八进制转换逻辑
        octal_hundreds_out = bin_value / 64;
        octal_tens_out     = (bin_value / 8) % 8;
        octal_ones_out     = bin_value % 8;

        // 十进制转换逻辑
        decimal_hundreds_out = bin_value / 100;
        decimal_tens_out     = (bin_value / 10) % 10;
        decimal_ones_out     = bin_value % 10;

        // 十六进制转换逻辑
        hex_high_out = bin_value[7:4];
        hex_low_out  = bin_value[3:0];
    end
    endtask

task signed_operation;
    input [7:0] a;           // 输入的有符号补码数 a
    input [7:0] b;           // 输入的有符号补码数 b
    input [3:0] op;          // 选择计算模式
    output reg [7:0] seg1;   // 数码管显示的百位（符号位）
    output reg [7:0] seg2;   // 数码管显示的十位
    output reg [7:0] seg3;   // 数码管显示的个位
    reg signed [7:0] result;
    reg [6:0] abs_result;
    reg sign;                // sign是符号位

begin
    // 计算结果
    case(op)
        4'b0001: result = a + b; // 加法
        4'b0010: result = a - b; // 减法
        4'b0100: result = a + b; // 加法 (相同操作)
        4'b1000: result = a - b; // 减法 (相同操作)
        default: result = 8'b0000_0000; // 默认情况
    endcase

    sign = result[7]; // 获取符号位
    abs_result = (sign == 0) ? result[6:0] : -result[6:0]; // 计算绝对值

    // 数码管段码生成逻辑
    // 第一个数码管：显示符号
    if (sign) begin
        seg1 = 8'b0000_0010; // 显示 "-"
    end else begin
        seg1 = 8'b1111_1100; // 显示 "0"
    end

    // 第二个数码管：显示十位
    seg2 = digit_to_seg(abs_result / 10);

    // 第三个数码管：显示个位
    seg3 = digit_to_seg(abs_result % 10);
end
endtask

// 数码管段码生成逻辑函数
function [7:0] digit_to_seg;  // 输出 8 位（包括 dp）
    input [3:0] digit;        // 输入 4 位数字（支持 0-9 和 A-F）
    begin
        case (digit)
            4'd0: digit_to_seg = 8'b1111_1100; // 显示 "0"
            4'd1: digit_to_seg = 8'b0110_0000; // 显示 "1"
            4'd2: digit_to_seg = 8'b1101_1010; // 显示 "2"
            4'd3: digit_to_seg = 8'b1111_0010; // 显示 "3"
            4'd4: digit_to_seg = 8'b0110_0110; // 显示 "4"
            4'd5: digit_to_seg = 8'b1011_0110; // 显示 "5"
            4'd6: digit_to_seg = 8'b1011_1110; // 显示 "6"
            4'd7: digit_to_seg = 8'b1110_0000; // 显示 "7"
            4'd8: digit_to_seg = 8'b1111_1110; // 显示 "8"
            4'd9: digit_to_seg = 8'b1111_0110; // 显示 "9"
            default: digit_to_seg = 8'b0000_0000; // 空白
        endcase
    end
endfunction

task bitwise_operation;
    input [7:0] op_a;     // 任务输入a
    input [7:0] op_b;     // 任务输入b
    input [3:0] operation; // 操作码
    output [7:0] output_result; // 操作结果

    begin
        case (operation)
            4'b0001: output_result = op_a & op_b;  // 与操作
            4'b0010: output_result = op_a | op_b;  // 或操作
            4'b0100: output_result = ~op_a;         // 非操作
            4'b1000: output_result = op_a ^ op_b;  // 异或操作
            default: output_result = 8'b0;          // 默认情况
        endcase
    end
endtask
endmodule
