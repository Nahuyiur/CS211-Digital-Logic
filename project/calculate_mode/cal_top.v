`timescale 1ns / 1ps

module cal_top(
    input clk,                // 时钟信号
    input reset,              // 复位信号
    input confirm,            // 确定操作的按钮
    input exit,               // 退出按钮
    input select,             // 切换按钮   
    input [7:0] in,           // 拨码开关的输入   
    output reg[7:0] Seg1,        // 前四个数码管
    output reg[7:0] Seg2,        // 后四个数码管
    output reg [7:0] leds,    // LED显示
    output reg[7:0] anode        // 数码管使能信号（动态扫描）
);

reg [7:0] seg1= 8'b0;    // 最终传入scan-display的数码管
reg [7:0] seg2= 8'b0;     
reg [7:0] seg3= 8'b0;             
reg [7:0] seg4= 8'b0;
reg [7:0] seg5= 8'b0; 
reg [7:0] seg6= 8'b0;     
reg [7:0] seg7= 8'b0;             
reg [7:0] seg8= 8'b0;

reg [4:0] mode = 5'b00001;            // 模式选择的储存
reg [3:0] op = 4'b0001;              // 运算操作选择的储存
reg [1:0] store = 2'b0;           // 存储状态,00为未操作，01为存储a,10为存储b,11为输出结果
reg [7:0] a = 8'b0;               // 运算数 a
reg [7:0] b = 8'b0;               // 运算数 b
reg mode_entered = 0;          // 0为未进入模式，1为已进入模式

//下面两行的计数器用来控制按下按钮的时间
localparam CLK_FREQ = 50000000; // 假设时钟频率为 50MHz
localparam DELAY_COUNT = CLK_FREQ / 2; // 0.5秒延迟的计数值

//下面四行的reg服务于task scan-display:
reg [24:0] counter = 0; // 计数器，足够容纳 25M 的值
reg delay_trigger = 0;  // 触发信号

reg [2:0] current_digit = 0; 
reg [20:0] counter1 = 0;   

// 实例化6个子模块（都没有用）
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

//下面的两个function用于把十进制整数（四位）转成数码管输出信号
parameter Num0 = 8'b1111_1100; // "0"
parameter Num1 = 8'b0110_0000; // "1"
parameter Num2 = 8'b1101_1010; // "2"
parameter Num3 = 8'b1111_0010; // "3"
parameter Num4 = 8'b0110_0110; // "4"
parameter Num5 = 8'b1011_0110; // "5"
parameter Num6 = 8'b1011_1110; // "6"
parameter Num7 = 8'b1110_0000; // "7"
parameter Num8 = 8'b1111_1110; // "8"
parameter Num9 = 8'b1111_0110; // "9"
parameter NumA = 8'b1110_1110; // "A"
parameter NumB = 8'b0011_1110; // "B"
parameter NumC = 8'b1001_1001; // "C"
parameter NumD = 8'b0111_1010; // "D"
parameter NumE = 8'b1001_1110; // "E"
parameter NumF = 8'b1000_1110; // "F"
parameter Blank = 8'b0000_0000; // 空白
function [7:0] digit_to_seg1;
    input [3:0] digit;  // 输入 4 位数字（支持 0-9 和 A-F）
    begin
        case (digit)
            4'd0: digit_to_seg1 = Num0; // 显示 "0"
            4'd1: digit_to_seg1 = Num1; // 显示 "1"
            4'd2: digit_to_seg1 = Num2; // 显示 "2"
            4'd3: digit_to_seg1 = Num3; // 显示 "3"
            4'd4: digit_to_seg1 = Num4; // 显示 "4"
            4'd5: digit_to_seg1 = Num5; // 显示 "5"
            4'd6: digit_to_seg1 = Num6; // 显示 "6"
            4'd7: digit_to_seg1 = Num7; // 显示 "7"
            4'd8: digit_to_seg1 = Num8; // 显示 "8"
            4'd9: digit_to_seg1 = Num9; // 显示 "9"
            4'd10: digit_to_seg1 = NumA; // 显示 "A"
            4'd11: digit_to_seg1 = NumB; // 显示 "B"
            4'd12: digit_to_seg1 = NumC; // 显示 "C"
            4'd13: digit_to_seg1 = NumD; // 显示 "D"
            4'd14: digit_to_seg1 = NumE; // 显示 "E"
            4'd15: digit_to_seg1 = NumF; // 显示 "F"
            default: digit_to_seg1 = Blank; // 空白
        endcase
    end
endfunction

//这个function和上一个function的区别是没有10-15，不会出现十六进制的转换（比如10不会被转成A）
function [7:0] digit_to_seg2;  // 输出 8 位（包括 dp）
    input [3:0] digit;        // 输入 4 位数字（支持 0-9 和 A-F）
    begin
        case (digit)
            4'd0: digit_to_seg1 = Num0; // 显示 "0"
            4'd1: digit_to_seg1 = Num1; // 显示 "1"
            4'd2: digit_to_seg1 = Num2; // 显示 "2"
            4'd3: digit_to_seg1 = Num3; // 显示 "3"
            4'd4: digit_to_seg1 = Num4; // 显示 "4"
            4'd5: digit_to_seg1 = Num5; // 显示 "5"
            4'd6: digit_to_seg1 = Num6; // 显示 "6"
            4'd7: digit_to_seg1 = Num7; // 显示 "7"
            4'd8: digit_to_seg1 = Num8; // 显示 "8"
            4'd9: digit_to_seg1 = Num9; // 显示 "9"
            default: digit_to_seg2 = Blank; // 空白
        endcase
    end
endfunction


always @(posedge clk) begin//这个always服务于task：scan-display
        counter1 <= counter1 + 1;
        if (counter1 == 10000) begin // 每 1 ms 触发一次 (100 MHz 时钟)
            counter1 <= 0;
            current_digit <= current_digit + 1; // 切换到下一个数码管
        end
        if (current_digit == 8)begin //这个地方由7改成了8
            current_digit <= 0; // 循环激活数码管
        end
    end

always @(posedge clk) begin//该模块用于设定按下按钮的时间,只有delay_trigger变成1的时候相关always才会修改寄存器的值
    
        if (counter < DELAY_COUNT - 1) begin
            counter <= counter + 1;
            delay_trigger <= 0;
        end else begin
            counter <= 0;
            delay_trigger <= 1; // 触发信号
        end
end

//该模块用于进入和退出模式，点击confirm进入模式，mode_entered=1说明进入模式
//请把mode_entered的两个值参数化
always @(posedge clk) begin
    if(confirm&&delay_trigger) begin//注意判断条件有delay_trigger=1
        mode_entered <= 1;            
    end 
    if(exit&&delay_trigger) begin
        mode_entered <= 0;       
    end 
end


// 该模块用于运算类型切换，点击select按钮切换模式mode，切换顺序为：00001，00010，00100，01000，10000，00001，
parameter Mode1=5'b00001;
parameter Mode2=5'b00010;
parameter Mode3=5'b00100;
parameter Mode4=5'b01000;
parameter Mode5=5'b10000;

always @(posedge clk) begin
    if(~mode_entered&&delay_trigger) begin
        if (select) begin
            case (mode)
                Mode1: mode <= Mode2;
                Mode2: mode <= Mode3;
                Mode3: mode <= Mode4;
                Mode4: mode <= Mode5;
                Mode5: mode <= Mode1;
            endcase
        end
    end
end

// 该模块用于每个运算类型的操作符切换，点击select按钮切换操作符op，切换顺序为：0001，0010，0100，1000，0001，
//请把op的四个值参数化
always @(posedge clk) begin
    if(mode_entered&&delay_trigger)begin
    if (select) begin
        case (op)
            4'b0001: begin
                if(mode==5'b00001) begin//第一个运算类型（进制转换）只有一个操作符，因此直接回到0001
                op <= 4'b0001;
            end
               else
               op<=4'b0010;
            end
            4'b0010: begin
                if(mode==5'b00010) begin//第二个运算类型（符号加减）只有两个操作符，因此直接回到0001
                op <= 4'b0001;
            end
               else
               op<=4'b0100;
            end
            4'b0100: op <= 4'b1000;
            4'b1000: op <= 4'b0001;
        endcase
    end
    end
end

// 该模块用于二元运算的操作步骤切换，点击select按钮切换步骤store，切换顺序为：00，01，10，11，00，
//00清零之前的运算，01提示输入a并时刻显示和存储a,10提示输入b并时刻显示和存储b,11显示最终结果
//请把store的四个值参数化
always @(posedge clk) begin
    if(mode_entered&&delay_trigger)begin
    if (confirm) begin
        case (store)
            2'b00: store <=2'b01;
            2'b01: begin
                if(mode==5'b00001)begin
                store <=2'b11;
            end
            else begin
                store <=2'b10;
            end
            end
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
        case (mode)//未进入模式的时候seg1亮起，显示此时的运算类型（1，2，3，4，5）
                5'b00001: seg1 <= 8'b0110_0000; 
                5'b00010: seg1 <= 8'b1101_1010; 
                5'b00100: seg1 <= 8'b1111_0010; 
                5'b01000: seg1 <= 8'b0110_0110; 
                5'b10000: seg1 <= 8'b1011_0110; 
                default: seg1 <= 8'b0000_0000; // 默认值以防未定义操作
        endcase
   
        end
        1: begin
            
    case(store)
    2'b00: begin
        seg3<=8'b0;
        seg4<=8'b0;
        seg5<=8'b0;
        seg6<=8'b0;
        seg7<=8'b0;
        seg8<=8'b0;
         case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4）
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; 
            endcase
        case (mode)//同时让seg1不要关闭
                5'b00001: seg1 <= 8'b0110_0000; 
                5'b00010: seg1 <= 8'b1101_1010; 
                5'b00100: seg1 <= 8'b1111_0010; 
                5'b01000: seg1 <= 8'b0110_0110; 
                5'b10000: seg1 <= 8'b1011_0110; 
                default: seg1 <= 8'b0000_0000;
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
                default: seg2 <= 8'b0000_0000; 
            endcase
        case (mode)
                5'b00001: seg1 <= 8'b0110_0000; 
                5'b00010: seg1 <= 8'b1101_1010; 
                5'b00100: seg1 <= 8'b1111_0010; 
                5'b01000: seg1 <= 8'b0110_0110; 
                5'b10000: seg1 <= 8'b1011_0110; 
                default: seg1 <= 8'b0000_0000; // 默认值以防未定义操作
        endcase
        seg3 <= 8'b00111010;//这个数码管输出是a，提示输入a
        seg4 <= 8'b0;//b此时不出现
        leds <= in;//同步显示a的值
        a<=in;//存储a
    end
    2'b10: begin
         case (op)
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; 
            endcase
        case (mode)
                5'b00001: seg1 <= 8'b0110_0000; 
                5'b00010: seg1 <= 8'b1101_1010; 
                5'b00100: seg1 <= 8'b1111_0010; 
                5'b01000: seg1 <= 8'b0110_0110; 
                5'b10000: seg1 <= 8'b1011_0110; 
                default: seg1 <= 8'b0000_0000; 
        endcase
        seg3 <= 8'b00111010;
        seg4 <= 8'b00111110;//这个数码管输出是b，提示输入a
        leds <= in;
        b<=in;
    end
    2'b11: begin
        case (mode) //五种运算类型分别操作
            5'b00001: begin
            convert_binary(a,seg1,seg2,seg3,seg4,seg5,seg6,seg7,seg8);
            leds<=8'b0;
            end
            5'b00010: begin
                case (op)
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; 
            endcase
            signed_operation(a,b,op,seg5,seg6,seg7,seg8);
            
            leds<=8'b0;
            end
            5'b00100: begin
                case (op)
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; 
            endcase
            shift_operation(a,b,op,leds);
            end
            5'b01000: begin
                case (op)
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; 
            endcase
            bitwise_operation(a,b,op,leds);
            end
            5'b10000: begin
                case (op)
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; // 默认值以防未定义操作
            endcase
            logic_operation(a,b,op,leds);
            end
        endcase
        end
    endcase
        end
    endcase
    display_scan(seg1,seg2,seg3,seg4,seg5,seg6,seg7,seg8,anode,Seg1,Seg2);
end
//下面是六个task，对应五个运算类型和一个数码管显示逻辑s
task convert_binary;
    input [7:0] bin_value; // 输入的二进制值
    output reg [7:0] seg1; // 确保使用 reg 类型
    output reg [7:0] seg2; // 确保使用 reg 类型
    output reg [7:0] seg3; // 确保使用 reg 类型
    output reg [7:0] seg4; // 确保使用 reg 类型
    output reg [7:0] seg5; // 确保使用 reg 类型
    output reg [7:0] seg6; // 确保使用 reg 类型
    output reg [7:0] seg7; // 确保使用 reg 类型
    output reg [7:0] seg8; // 确保使用 reg 类型
    
    reg [3:0] octal_hundreds_out; // 八进制百位输出
    reg [3:0] octal_tens_out;     // 八进制十位输出
    reg [3:0] octal_ones_out;     // 八进制个位输出
    
    reg [3:0] decimal_hundreds_out; // 十进制百位输出
    reg [3:0] decimal_tens_out;     // 十进制十位输出
    reg [3:0] decimal_ones_out;     // 十进制个位输出

    reg [3:0] hex_high_out;         // 十六进制高位输出
    reg [3:0] hex_low_out;          // 十六进制低位输出

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

        // 数码管输出
        seg1 = digit_to_seg1(octal_hundreds_out); // 八进制百位
        seg2 = digit_to_seg1(octal_tens_out);     // 八进制十位
        seg3 = digit_to_seg1(octal_ones_out);     // 八进制个位

        // 十进制数码管输出
        seg4 = digit_to_seg1(decimal_hundreds_out); // 十进制百位
        seg5 = digit_to_seg1(decimal_tens_out);     // 十进制十位
        seg6 = digit_to_seg1(decimal_ones_out);     // 十进制个位

        // 十六进制数码管输出
        seg7 = digit_to_seg1(hex_high_out);         // 十六进制高位
        seg8 = digit_to_seg1(hex_low_out);          // 十六进制低位
    end
endtask


task signed_operation;
    input [7:0] a;           // 输入的有符号补码数 a
    input [7:0] b;           // 输入的有符号补码数 b
    input [3:0] op;          // 选择计算模式
    output reg [7:0] seg1;   // 数码管显示的千位（符号位）
    output reg [7:0] seg2;   // 数码管显示的百位
    output reg [7:0] seg3;   // 数码管显示的十位
    output reg [7:0] seg4;   // 数码管显示的个位

    reg signed [7:0] result;
    reg signed [7:0] abs_result; // 更改为 signed，以便处理负数
    reg sign;                    // sign是符号位
    reg [3:0] thousands,hundreds, tens, ones;
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
    abs_result = (sign) ? -result : result; // 计算绝对值

    // 数字分拆
    
    thousands = (abs_result / 1000) % 10; // 千位
    hundreds = (abs_result / 100) % 10;    // 百位
    tens = (abs_result / 10) % 10;         // 十位
    ones = abs_result % 10;                 // 个位

    // 符号位作为千位
    if (sign) begin
        seg1 = 8'b0000_0010; // 显示 "-"
    end else begin
        seg1 = 8'b1111_1100; // 显示 "0"（即为正数没有符号）
    end

    // 显示百位、十位和个位
    seg2 = digit_to_seg2(hundreds);  // 显示百位
    seg3 = digit_to_seg2(tens);      // 显示十位
    seg4 = digit_to_seg2(ones);      // 显示个位
end
endtask

task shift_operation;
    input signed [7:0] a;    // 输入的 8 位有符号数（算术移位用）
    input [7:0] b;           // 输入的无符号数，表示移位的位数（范围 0~7）
    input [3:0] op;          // 选择模式
    output reg [7:0] result; // 算术左移结果

begin
    // 根据操作代码进行相应的位移操作
    case(op)
        4'b0001: result = a <<< b;  // 算术左移
        4'b0010: result = a >>> b;  // 算术右移
        4'b0100: result = a << b;   // 逻辑左移
        4'b1000: result = a >> b;   // 逻辑右移
        default: result = 8'b0000_0000; // 默认值
    endcase
end
endtask

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

task logic_operation;
    input [7:0] op_a;       // 任务输入a
    input [7:0] op_b;       // 任务输入b
    input [3:0] operation;   // 操作码
    output reg [7:0] output_result; // 操作结果

    begin
        case (operation)
            4'b0001: output_result = {8{(op_a != 0) && (op_b != 0)}}; // 逻辑与操作
            4'b0010: output_result = {8{(op_a != 0) || (op_b != 0)}}; // 逻辑或操作
            4'b0100: output_result = {8{!(op_a != 0)}};               // 逻辑非操作
            4'b1000: output_result = {8{(op_a != 0) ^ (op_b != 0)}}; // 逻辑异或操作
            default: output_result = 8'b0;                          // 默认情况
        endcase
    end
endtask

task display_scan;
input [7:0] data1;
    input [7:0] data2;
    input [7:0] data3;
    input [7:0] data4;
    input [7:0] data5;
    input [7:0] data6;
    input [7:0] data7;
    input [7:0] data8;
    output reg [7:0] anode;      // 数码管使能信号（动态扫描）
    output reg [7:0] seg1;
    output reg [7:0] seg2 ;    
        begin
            anode = 8'b0000_0000;             
            anode[current_digit] = 1;       
            
            case (current_digit)
                3'd0: seg1 = data1;
                3'd1: seg1 = data2; // 显示 "1"
                3'd2: seg1 = data3; // 显示 "2"
                3'd3: seg1 = data4; // 显示 "3"
                3'd4: seg2 = data5; // 显示 "4"
                3'd5: seg2 = data6; // 显示 "5"
                3'd6: seg2 = data7; // 显示 "6"
                3'd7: seg2 = data8; // 显示 "7"
                default: begin
                    seg1 = 8'b1111_1111;      // 默认不显示内容
                    seg2 = 8'b1111_1111;
                end // 默认不显示任何内容
            endcase
        end
    endtask

endmodule
