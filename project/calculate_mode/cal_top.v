`timescale 1ns / 1ps

module cal_top(
    input [4:0] enter,
    input clk,                // 时钟信号
    input reset,              // 复位信号
    input confirm,            // 确定操作的按钮
    input exit,               // 退出按钮
    input select,             // 切换按钮   
    input [7:0] in,           // 拨码开关的输入   
    output reg type_entered,
    output reg[7:0] seg1,      
    output reg[7:0] seg2,   
    output reg[7:0] seg3,   
    output reg[7:0] seg4,   
    output reg[7:0] seg5,   
    output reg[7:0] seg6,   
    output reg[7:0] seg7,   
    output reg[7:0] seg8,    
    output reg [7:0] leds   // LED显示
);

reg [4:0] mode = 5'b00001;            // 模式选择的储存
reg [3:0] op = 4'b0001;              // 运算操作选择的储存
reg [1:0] store = 2'b0;           // 存储状态,00为未操作，01为存储a,10为存储b,11为输出结果
reg [7:0] a = 8'b0;               // 运算数 a
reg [7:0] b = 8'b0;               // 运算数 b

//下面两行的计数器用来控制按下按钮的时间
localparam CLK_FREQ = 50000000; // 假设时钟频率为 50MHz
localparam DELAY_COUNT = CLK_FREQ / 2; // 0.5秒延迟的计数值

//下面四行的reg服务于task scan-display:
reg [24:0] counter = 0; // 计数器，足够容纳 25M 的值
reg delay_trigger = 0;  // 触发信号

reg [2:0] current_digit = 0; 
reg [20:0] counter1 = 0;   


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
parameter Minus= 8'b0000_0010;//"-"

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
            4'd0: digit_to_seg2 = Num0; // 显示 "0"
            4'd1: digit_to_seg2 = Num1; // 显示 "1"
            4'd2: digit_to_seg2 = Num2; // 显示 "2"
            4'd3: digit_to_seg2 = Num3; // 显示 "3"
            4'd4: digit_to_seg2 = Num4; // 显示 "4"
            4'd5: digit_to_seg2 = Num5; // 显示 "5"
            4'd6: digit_to_seg2 = Num6; // 显示 "6"
            4'd7: digit_to_seg2 = Num7; // 显示 "7"
            4'd8: digit_to_seg2 = Num8; // 显示 "8"
            4'd9: digit_to_seg2 = Num9; // 显示 "9"
            default: digit_to_seg2 = Blank; // 空白
        endcase
    end
endfunction



always @(posedge clk) begin//这个always服务于task：scan-display
        counter1 <= counter1 + 1;
        if (counter1 == 10000) begin // 每 1 ms 触发一次 (100 MHz 时钟)
            counter1 <= 0;
            current_digit <= current_digit + 1; // 切换到下一个数码管
            if (current_digit == 7)
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
    if(enter==5'b00001) begin
    if(confirm&&delay_trigger) begin//注意判断条件有delay_trigger=1
        type_entered <= 1;      
    end 
    if(exit&&delay_trigger) begin
        type_entered <= 0;       
    end 
    end
end

parameter type1=5'b00_001;
parameter type2=5'b00_010;
parameter type3=5'b00_100;
parameter type4=5'b01_000;
parameter type5=5'b10_000;

parameter OP1=4'b00_01;
parameter OP2=4'b00_10;
parameter OP3=4'b01_00;
parameter OP4=4'b10_00;
// 该模块用于运算类型切换，点击select按钮切换模式mode，切换顺序为：00001，00010，00100，01000，10000，00001，
//请把mode的五个值参数化
always @(posedge clk) begin
    if(enter==5'b00001) begin
    if(~type_entered&&delay_trigger) begin
    if (select) begin
        case (mode)
            type1: mode <= type2;
            type2: mode <= type3;
            type3: mode <= type4;
            type4: mode <= type5;
            type5: mode <= type1;
        endcase
    end
    end
    end
end

// 该模块用于每个运算类型的操作符切换，点击select按钮切换操作符op，切换顺序为：0001，0010，0100，1000，0001，
//请把op的四个值参数化
always @(posedge clk) begin
    if(enter==5'b00001) begin
    if(type_entered&&delay_trigger)begin
    if (select) begin
        case (op)
            OP1: begin
                if(mode==type1) begin//第一个运算类型（进制转换）只有一个操作符，因此直接回到0001
                op <= OP1;
            end
               else
               op <= OP2;
            end
            OP2: begin
                if(mode==type2) begin//第二个运算类型（符号加减）只有两个操作符，因此直接回到0001
                op <= OP1;
            end
               else
               op <= OP3;
            end
            OP3: op <= OP4;
            OP4: op <= OP1;
        endcase
    end
    end
    end
end

// 该模块用于二元运算的操作步骤切换，点击select按钮切换步骤store，切换顺序为：00，01，10，11，00，
//00清零之前的运算，01提示输入a并时刻显示和存储a,10提示输入b并时刻显示和存储b,11显示最终结果
//请把store的四个值参数化
parameter Step1=2'b00;
parameter Step2=2'b01;
parameter Step3=2'b10;
parameter Step4=2'b11;

always @(posedge clk) begin
    if(type_entered&&delay_trigger)begin
        if (confirm) begin
            case (store)
                Step1: store <=Step2;
                Step2: begin
                    if(mode==type1)begin
                    store <=Step4;
                end
                else begin
                    store <=Step3;
                end
                end
                Step3: store <=Step4;
                Step4: store <=Step1;
            endcase
        end
    end
end


always @(posedge clk) begin//控制leds和seg的输出
        case(type_entered)
        0: begin
            seg2<=Blank;
            seg3<=Blank;
            seg4<=Blank;
            seg5<=Blank;
            seg6<=Blank;
            seg7<=Blank;
            seg8<=Blank;
            leds<=Blank;
        case (mode)//未进入模式的时候seg1亮起，显示此时的运算类型（1，2，3，4，5）
                type1: seg1 <= Num1; 
                type2: seg1 <= Num2; 
                type3: seg1 <= Num3; 
                type4: seg1 <= Num4; 
                type5: seg1 <= Num5; 
                default: seg1 <= Blank; // 默认值以防未定义操作
        endcase
        end
        1: begin         
    case(store)
    2'b00: begin
        seg3<=Blank;
        seg4<=Blank;
        seg5<=Blank;
        seg6<=Blank;
        seg7<=Blank;
        seg8<=Blank;
         case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4）
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
        case (mode)//同时让seg1不要关闭
                type1: seg1 <= Num1; 
                type2: seg1 <= Num2; 
                type3: seg1 <= Num3; 
                type4: seg1 <= Num4; 
                type5: seg1 <= Num5; 
                default: seg1 <= Blank;
        endcase
        leds <= Blank;
    end
    2'b01: begin
         case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4）
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
        case (mode)//同时让seg1不要关闭
                type1: seg1 <= Num1; 
                type2: seg1 <= Num2; 
                type3: seg1 <= Num3; 
                type4: seg1 <= Num4; 
                type5: seg1 <= Num5; 
                default: seg1 <= Blank;
        endcase
        seg3 <= NumA;//这个数码管输出是a，提示输入a
        seg4 <= Blank;//b此时不出现
        leds <= in;//同步显示a的值
        a<=in;//存储a
    end
    2'b10: begin
          case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4）
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
        case (mode)//同时让seg1不要关闭
                type1: seg1 <= Num1; 
                type2: seg1 <= Num2; 
                type3: seg1 <= Num3; 
                type4: seg1 <= Num4; 
                type5: seg1 <= Num5; 
                default: seg1 <= Blank;
        endcase
        seg3 <= NumA;
        seg4 <= NumB;//这个数码管输出是b，提示输入a
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
               case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4）
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
            signed_operation(a,b,op,seg5,seg6,seg7,seg8);
            
            leds<=8'b0;
            end
            5'b00100: begin
                case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4）
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
            shift_operation(a,b,op,leds);
            end
            5'b01000: begin
                case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4）
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
            bitwise_operation(a,b,op,leds);
            end
            5'b10000: begin
                case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4）
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
            logic_operation(a,b,op,leds);
            end
        endcase
        end
    endcase
        end
    endcase
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

    reg [7:0] result;   // 修改结果为 9 位签名数
    reg [7:0] abs_result; 
    reg sign;                    // sign是符号位
    reg [3:0] hundreds, tens, ones; // 改为 4 位以处理数字

begin
    abs_result = 8'b0;
    // 计算结果
    case(op)
        4'b0001: begin
            result = a + b; // 加法
            sign = result[7]; // 获取符号位
            abs_result[6:0] = (sign) ? ~result[6:0] : result[6:0]; // 计算绝对值，注意 abs_result 范围
            if (((a[7] == 0) && (b[7] == 0) && (result[7] == 1)) || // 正 + 正 -> 负
                ((a[7] == 1) && (b[7] == 1) && (result[7] == 0))) begin // 负 + 负 -> 正
                sign = ~sign;
                abs_result = ~result+1;
        end
        end
        4'b0010: begin
            result = a - b; // 减法
            sign = result[7]; // 获取符号位
            abs_result[6:0] = (sign) ? ~result[6:0] : result[6:0]; // 计算绝对值，注意 abs_result 范围
            if (((a[7] == 0) && (b[7] == 1) && (result[7] == 1)) || // 正 + 正 -> 负
                ((a[7] == 1) && (b[7] == 0) && (result[7] == 0))) begin // 负 + 负 -> 正
                sign = ~sign;
                abs_result = ~result+1;
        end
        end
        default: result = 8'b00000000; // 默认情况
    endcase

    // 数字分拆
    hundreds = abs_result / 100;        // 百位
    tens = (abs_result / 10) % 10;      // 十位
    ones = abs_result % 10;              // 个位

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
        default: result = 9'b000000000; // 默认值
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

endmodule
