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
    input [7:0] total_player,
    input enter,
    input wire [5:0] total, 
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
    output reg[5999:0] player_flat
    );
    reg [20:0] question [49:0];
    parameter is_enter = 4'b0100;
integer k;
// 在 `always` 块中将二维数组展平为一维数组：
always @(posedge clk) begin
    // 将二维数组展平为一维数组
    for (k = 0; k < 50; k = k + 1) begin
        question[k]=mode_question_flat[k * 21 +: 21];
    end
end
reg[29:0] player [3:0][49:0];

integer i, j;
    always @(posedge clk )  begin
            // 用两个嵌套的for循环将二维数组展开成一个6000位的信号
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 50; j = j + 1) begin
                    player_flat[(i * 50 + j) * 30 +: 30] = player[i][j]; // 展开并拼接
                end
            end
        end


reg finish=0;
reg [4:0] total_time = 5'b11000;
reg [4:0] current_time = 5'b11000;
reg [5:0] current = 6'b000000;    //当前赛题
reg [1:0] current_player = 2'b00;//当前选手

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
localparam DELAY_COUNT2 = CLK_FREQ*2; // 1秒延迟的计数值
        
always @(posedge clk) begin
    if (counter2 < DELAY_COUNT2 - 1) begin
        counter2 <= counter2 + 1;
        delay_trigger2 <= 0;
    end else begin
        counter2 <= 0;
        delay_trigger2 <= 1; // 触发信号
    end
end

reg [28:0] counter3 = 0; // 计数器
reg delay_trigger3 = 0;  // 触发信号7
localparam DELAY_COUNT3 = CLK_FREQ; // 1秒延迟的计数值
        
always @(posedge clk) begin
    if (counter3 < DELAY_COUNT3 - 1) begin
        counter3 <= counter3 + 1;
        delay_trigger3 <= 0;
    end else begin
        counter3 <= 0;
        delay_trigger3 <= 1; // 触发信号
    end
end

always @(posedge clk ) begin
    if(mode==3'b010&enter) begin
            if(current_player==total_player-1&current==total-1&submit&delay_trigger) begin
              mode_entered <=0;
            end
            if(confirm&delay_trigger) begin
              mode_entered <=1;
            end
    end
end
always @(posedge clk ) begin
    if(mode==3'b010&enter) begin
            if((confirm&delay_trigger&mode_entered)|current_time==5'b0) begin
              finish <=1;
            end
     
            if(submit&delay_trigger) begin
              finish <=0;
              
            end 
    end
end
reg [1:0] input_counter = 2'b00;
always @(posedge clk ) begin
    if(mode==3'b010&enter) begin
        if(confirm&delay_trigger) begin
            input_counter <= 2'b00;
        end
        case (question[current][20:18]) //五种运算类型分别操作
           3'b001: begin
            case(input_counter)
            2'b00:begin
                 if (change&delay_trigger) begin
                            player[current_player][current][24:17]<=in;
                            input_counter <= input_counter + 1; // 计数加一
                        end
            end
            2'b01:begin
                if (change&delay_trigger) begin
                            player[current_player][current][16:9]<=in;
                            input_counter <= input_counter + 1; // 计数加一
                        end
            end
            2'b10:begin
                if(confirm&delay_trigger) begin
                            player[current_player][current][29:25]<=5'b10100-current_time;
                            player[current_player][current][8:1]=in;
                            convert_binary(question[current][15:8], question[current][17:16], player[current_player][current][24:1], player[current_player][current][0]);
                            input_counter <= 2'b00; // 重置计数器
                        end
            end
           endcase
                end
            3'b010: begin
                    case(input_counter)
            2'b00:begin
                 if (change&delay_trigger) begin
                            player[current_player][current][24:17]<=in;
                            input_counter <= input_counter + 1; // 计数加一
                        end
            end
            2'b01:begin
                if (change&delay_trigger) begin
                            player[current_player][current][16:9]<=in;
                            input_counter <= input_counter + 1; // 计数加一
                        end
            end
            2'b10:begin
                if(confirm&delay_trigger) begin
                    player[current_player][current][29:25]<=5'b10100-current_time;
                    player[current_player][current][8:1]=in;
                    signed_operation(question[current][15:8], question[current][7:0],question[current][17:16], player[current_player][current][24:1], player[current_player][current][0]);
                    input_counter <= 0; // 重置计数器
                end
            end
           endcase
                end
            3'b011: begin
                if(confirm&&delay_trigger) begin
                    player[current_player][current][29:25]=5'b10100-current_time;
                    player[current_player][current][24:17]=in;
                    shift_operation(question[current][15:8],question[current][7:0],question[current][17:16],in,player[current_player][current][0]);
                end
            end
            3'b100: begin
                if(confirm&&delay_trigger) begin
                    player[current_player][current][29:25]<=5'b10100-current_time;
                player[current_player][current][24:17]<=in;
            bitwise_operation(question[current][15:8],question[current][7:0],question[current][17:16],in,player[current_player][current][0]);
                end
            end
            3'b101: begin
                if(confirm&&delay_trigger) begin
                    player[current_player][current][29:25]<=5'b10100-current_time;
                player[current_player][current][24:17]<=in;
            logic_operation(question[current][15:8],question[current][7:0],question[current][17:16],in,player[current_player][current][0]);
                end
    end
    endcase
    end
end

always @(posedge clk) begin
    if(mode==3'b010&enter) begin
    if(finish&submit&delay_trigger) begin
        if(current<total-1) begin
        current<=current+1;
        end
        else begin
        current<=6'b000000;
        end
end
    end
end

always @(posedge clk) begin
    if(mode==3'b010&enter) begin
    if(current==total-1&submit&delay_trigger&finish&mode_entered) begin
        if(current_player<total_player-1) begin
        current_player<=current_player+1;
        end
        else begin
        current_player<=current_player;
        end
end
    end
end

always @(posedge clk) begin
    if(mode==3'b010&enter&delay_trigger2&mode_entered) begin
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
    if(mode==3'b010&enter) begin
    if(mode_entered) begin
    if(current_time>5'b10100&~finish) begin
        if(current_time==5'b11000) begin
            seg3<=digit_to_seg1((current+1)/10);
            seg4<=digit_to_seg1((current+1)%10);
        end
        else begin
        if(delay_trigger3) begin
            if(seg3==Blank) begin
             seg3<=digit_to_seg1((current+1)/10);
            end
            else begin
            seg3<=Blank;
            end
            if(seg4==Blank) begin
             seg4<=digit_to_seg1((current+1)%10);
            end
            else begin
            seg4<=Blank;
            end
        end
        end
    end
    else begin
        if(question[current][20:18]==3'b001|question[current][20:18]==3'b010) begin
    seg3<=digit_to_seg1(input_counter+1);
    seg4<=digit_to_seg1(input_counter+1);
    end
    else begin
        seg3<=digit_to_seg1((current+1)/10);
        seg4<=digit_to_seg1((current+1)%10);
    end
    end
    if(current_time>5'b10100) begin
        seg7<=Blank;
        seg8<=Blank;
    end
    else begin
        seg7<=digit_to_seg1(current_time/10);
        seg8<=digit_to_seg1(current_time%10);
    end
    seg1<=digit_to_seg1(total/10);
    seg2<=digit_to_seg1(total%10);
    seg5<=digit_to_seg1(question[current][20:18]);
    seg6<=digit_to_seg1(question[current][17:16]+1);
    led1<=question[current][15:8];
    led2<=question[current][7:0];
    end
    else begin
        seg1=digit_to_seg1(2);
        seg2=Blank;
        seg3=Blank;
        seg4=Blank;
        seg5=Blank;
        seg6=Blank;
        seg7=Blank;
        seg8=Blank;
        led1=Blank;
        led2=Blank;
    end
  end
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
    input [7:0] a;        // 输入的二进制值
    input [7:0] b;
    input [1:0] op;
    input [23:0] answer;
    output check;
    
    reg [23:0] r;
    reg signed [7:0] result;  // 修改为 signed 类型，8 位带符号数
    reg [7:0] abs_result;     // 用 8 位来存储绝对值
    reg sign;                 // sign 是符号位
    reg [3:0] hundreds, tens, ones; // 4 位以处理百位、十位、个位

    begin
        // 计算结果
        case(op)
            2'b00: begin
                result = a + b;  // 加法
            end
            2'b01: begin
                result = a - b;  // 减法
            end
            default: result = 8'b00000000;  // 默认情况
        endcase

        sign = result[7];  // 获取符号位

        // 计算绝对值，负数时取补码
        if (sign == 1'b1) 
            abs_result = ~result + 1;  // 负数，取补码
        else
            abs_result = result;      // 正数，直接赋值

        // 计算百位、十位、个位
        hundreds = abs_result / 100;        // 百位
        tens = (abs_result / 10) % 10;      // 十位
        ones = abs_result % 10;             // 个位

        // 拼接成最终的24位数
        r[23] = sign;  // 符号位
        r[19:16] = hundreds;  // 百位
        r[11:8] = tens;       // 十位
        r[3:0] = ones;        // 个位

        // 比较计算结果与期望的答案
        check = (r == answer);
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
