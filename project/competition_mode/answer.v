`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/11 15:07:12
// Design Name: 
// Module Name: time
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

 
module answer (
    input wire [2:0] mode,
    input clk,
    input reset,
    input confirm,
    input submit,
    input exit, 
    input change,
    input [7:0] in,
    input [1049:0] mode_question_flat,
    output reg [7:0] seg1,
    output reg [7:0] seg2,
    output reg [7:0] seg3,
    output reg [7:0] seg4,
    output reg [7:0] seg5,
    output reg [7:0] seg6,
    output reg [7:0] seg7,
    output reg [7:0] seg8,
    output reg [7:0] led1,
    output reg [7:0] led2,
    output reg mode_entered,
    output reg[119:0] player_flat 
    );
    reg [20:0] question [49:0];
    integer i;
// 在 `always` 块中将二维数组展平为一维数组：
always @(posedge clk) begin
    // 将二维数组展平为一维数组
    for (i = 0; i < 50; i = i + 1) begin
        question[i]=mode_question_flat[i * 21 +: 21];
    end
end
reg[29:0] player [1:0];
always @(posedge clk) begin
    // 将二维数组展平为一维数组
    for (i = 0; i < 4; i = i + 1) begin
        player_flat[i * 30 +: 30]=player[i];
    end
end

reg finish=1;
reg [4:0] total_time = 5'b10111;
reg [4:0] current_time = 5'b10111;
reg [5:0] total = 6'b000101;    //赛题总数
reg [1:0] total_player = 2'b11;   //选手总数
reg [5:0] current = 6'b000001;    //当前赛题
reg [1:0] current_player = 2'b0;//当前选手

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
parameter Numa = 8'b0011_1110; // "A"
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

reg [24:0] counter = 0; // 计数器
reg delay_trigger = 0;  // 触发信号
localparam CLK_FREQ = 50000000; // 假设时钟频率为 50MHz
localparam DELAY_COUNT = CLK_FREQ / 2; // 0.5秒延迟的计数值
    
always @(posedge clk) begin
    if (counter < DELAY_COUNT - 1) begin
        counter <= counter + 1;
        delay_trigger <= 0;
    end else begin
        counter <= 0;
        delay_trigger <= 1; // 触发信号
    end
end
reg [28:0] counter2 = 0; // 计数器
reg delay_trigger2 = 0;  // 触发信号7
localparam DELAY_COUNT2 = CLK_FREQ; // 1秒延迟的计数值
        
always @(posedge clk) begin
    if (counter2 < DELAY_COUNT2 - 1) begin
        counter2 <= counter2 + 1;
        delay_trigger2 <= 0;
    end else begin
        counter2 <= 0;
        delay_trigger2 <= 1; // 触发信号
    end
end

always @(posedge clk ) begin
    if(mode==3'b010) begin
            if(exit&delay_trigger) begin
              mode_entered <=0;
            end
            if(confirm&delay_trigger) begin
              mode_entered <=1;
            end
    end
end
always @(posedge clk ) begin
    if(mode==3'b010) begin
            if((confirm&delay_trigger)|current_time==5'b0) begin
              finish <=1;
            end
     
            if(submit&delay_trigger) begin
              finish <=0;
            end 
    end
end
reg [2:0] input_counter = 0;
always @(posedge clk ) begin
    if(mode==3'b010) begin
    if(~finish) begin
        case (mode) //五种运算类型分别操作
           5'b00001: begin
            case(input_counter)
            2'b00:begin
                 if (change) begin
                            player[current_player][24:17]<=in;
                            input_counter <= input_counter + 1; // 计数加一
                        end
            end
            2'b01:begin
                if (change) begin
                            player[current_player][16:9]<=in;
                            input_counter <= input_counter + 1; // 计数加一
                        end
            end
            2'b10:begin
                if(confirm&&delay_trigger) begin
                            player[current][29:25]<=5'b10100-current_time;
                            player[current_player][8:1]=in;
                            convert_binary_answer(question[current][15:8], question[current][17:16], player[current_player][24:1], player[current_player][0]);
                            input_counter <= 0; // 重置计数器
                        end
            end
           endcase
                end
            5'b00010: begin
                    case(input_counter)
            2'b00:begin
                 if (change) begin
                            player[current_player][24:17]<=in;
                            input_counter <= input_counter + 1; // 计数加一
                        end
            end
            2'b01:begin
                if (change) begin
                            player[current_player][16:9]<=in;
                            input_counter <= input_counter + 1; // 计数加一
                        end
            end
            2'b10:begin
                if(confirm&&delay_trigger) begin
                            player[current][29:25]<=5'b10100-current_time;
                            player[current_player][8:1]=in;
                            signed_operation(question[current][15:8], question[current][7:0],question[current][17:16], player[current_player][24:1], player[current_player][0]);
                            input_counter <= 0; // 重置计数器
                        end
            end
           endcase
                end
            5'b00100: begin
                if(confirm&&delay_trigger) begin
                    player[current][29:25]<=5'b10100-current_time;
                    player[current][24:17]<=in;
                    shift_operation(question[current][15:8],question[current][7:0],question[current][17:16],in,player[current_player][0]);
                end
            end
            5'b01000: begin
                if(confirm&&delay_trigger) begin
                    player[current][29:25]<=5'b10100-current_time;
                player[current][24:17]<=in;
            bitwise_operation(question[current][15:8],question[current][7:0],question[current][17:16],in,player[current_player][0]);
                end
            end
            5'b10000: begin
                if(confirm&&delay_trigger) begin
                    player[current][29:25]<=5'b10100-current_time;
                player[current][24:17]<=in;
            logic_operation(question[current][15:8],question[current][7:0],question[current][17:16],in,player[current_player][0]);
                end
    end
    endcase
    end
end
end

always @(posedge clk) begin
    if(mode==3'b010) begin
    if(finish&submit&delay_trigger) begin
        if(current<total) begin
        current<=current+1;
        end
        else begin
        current<=1;
        end
end
    end
end

always @(posedge clk) begin
    if(mode==3'b010) begin
    if(current==total&submit&delay_trigger) begin
        if(current_player<total_player) begin
        current_player<=current_player+1;
        end
        else begin
        current_player<=0;
        end
end
    end
end

always @(posedge clk) begin
    if(mode==3'b010&delay_trigger2) begin
    case(finish)
    0: begin
        if(current_time>5'b0) begin
        current_time<=current_time-1;
        end
        else begin
        current_time<=5'b11000;
        end
end
    1: begin
        current_time<=5'b11000;
end
endcase
    end
end

  always @(posedge clk) begin
    if(current_time>5'b10100&~finish) begin
        if(delay_trigger) begin
            if(seg3==Blank) begin
             seg3<=digit_to_seg1(current/10);
            end
            else begin
            seg3<=Blank;
            end
            if(seg4==Blank) begin
             seg4<=digit_to_seg1(current%10);
            end
            else begin
            seg4<=Blank;
            end
        end
    end
    else begin
        seg3<=digit_to_seg1(current/10);
        seg4<=digit_to_seg1(current%10);
    end
    if(current_time>5'b10100) begin
        seg7<=digit_to_seg1(Blank);
        seg8<=digit_to_seg1(Blank);
    end
    else begin
        seg7<=digit_to_seg1(current_time/10);
        seg8<=digit_to_seg1(current_time%10);
    end
    seg1<=digit_to_seg1(total/10);
    seg2<=digit_to_seg1(total%10);
    seg5<=digit_to_seg1(question[current][20:18]);
    seg6<=digit_to_seg1(question[current][17:16]+1);
    led1<=digit_to_seg1(question[current][15:8]);
    led2<=digit_to_seg1(question[current][7:0]);
    end

task convert_binary;
    input [7:0] bin_value; // 输入的二进制值
    input [1:0] op;
    input [23:0] answer;
    output check;
    reg [23:0] result;
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

    case(op)
        2'b00: begin
            result[19:16]= octal_hundreds_out;
            result[11:8]=octal_tens_out;
            result[3:0]=octal_ones_out;
        end
        2'b01: begin
            result[19:16]= decimal_hundreds_out;
            result[11:8]=decimal_tens_out;
            result[3:0]=decimal_ones_out;
        end
        2'b10: begin
            result[11:8]=hex_high_out;
            result[3:0]=hex_low_out;
        end
        default: result = 24'b0; // 默认值
    endcase
    check = (result==answer);
    end
endtask


task signed_operation;
    input [7:0] a; // 输入的二进制值
    input [7:0] b;
    input [1:0] op;
    input [23:0] answer;
    output check;
    reg [23:0] r;
    reg [7:0] result;   // 修改结果为 9 位签名数
    reg [7:0] abs_result; 
    reg sign;                    // sign是符号位
    reg [3:0] hundreds, tens, ones; // 改为 4 位以处理数字

    begin
    abs_result = 8'b0;
    // 计算结果
    case(op)
        2'b00: begin
            result = a + b; // 加法
            sign = result[7]; // 获取符号位
            abs_result[6:0] = (sign) ? ~result[6:0] : result[6:0]; // 计算绝对值，注意 abs_result 范围
        end
        2'b01: begin
            result = a - b; // 减法
            sign = result[7]; // 获取符号位
            abs_result[6:0] = (sign) ? ~result[6:0] : result[6:0]; // 计算绝对值，注意 abs_result 范围
        end
        default: result = 8'b00000000; // 默认情况
    endcase
    hundreds = abs_result / 100;        // 百位
    tens = (abs_result / 10) % 10;      // 十位
    ones = abs_result % 10;              // 个位

    r[23]=sign;
    r[19:16]= hundreds;
    r[11:8]=tens;
    r[3:0]=ones;
    check = (r==answer);

    end
endtask

task shift_operation;
    input signed [7:0] a;    // 输入的 8 位有符号数（算术移位用）
    input [7:0] b;           // 输入的无符号数，表示移位的位数（范围 0~7）
    input [1:0] op;          // 选择模式
    input [7:0] answer;
    output reg  check; 
    reg [7:0] result;
begin
    // 根据操作代码进行相应的位移操作
    case(op)
        2'b00: result = a <<< b;  // 算术左移
        2'b01: result = a >>> b;  // 算术右移
        2'b10: result = a << b;   // 逻辑左移
        2'b11: result = a >> b;   // 逻辑右移
        default: result = 8'b00000000; // 默认值
    endcase
    check = (result==answer);
end
 
endtask

task bitwise_operation;
    input [7:0] op_a;     // 任务输入a
    input [7:0] op_b;     // 任务输入b
    input [1:0] operation; // 操作码
    input [7:0] answer;
    output reg  check; 
    reg [7:0] result;

    begin
        case (operation)
            2'b00: result = op_a & op_b;  // 与操作
            2'b01: result = op_a | op_b;  // 或操作
            2'b10: result = ~op_a;         // 非操作
            2'b11: result = op_a ^ op_b;  // 异或操作
            default: result = 8'b0;          // 默认情况
        endcase
        check = (result==answer);
    end
endtask

task logic_operation;
    input [7:0] op_a;       // 任务输入a
    input [7:0] op_b;       // 任务输入b
    input [1:0] operation;   // 操作码
    input [7:0] answer;
    output reg  check; 
    reg [7:0] result;

    begin
        case (operation)
            2'b00: result = {8{(op_a != 0) && (op_b != 0)}}; // 逻辑与操作
            2'b01: result = {8{(op_a != 0) || (op_b != 0)}}; // 逻辑或操作
            2'b10: result = {8{!(op_a != 0)}};               // 逻辑非操作
            2'b11: result = {8{(op_a != 0) ^ (op_b != 0)}}; // 逻辑异或操作
            default: result = 8'b0;                          // 默认情况
        endcase
        check = (result==answer);
    end
endtask
endmodule
