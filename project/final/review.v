`timescale 1ns / 1ps

module review(
    input enter,
    input wire [1049:0] mode_question_flat,
    input wire [5999:0] player_flat,
    input wire [2:0] mode_sel,
    input clk,                // 时钟信号
    input reset,              // 复位信号
    input confirm,            // 确定操作的按钮
    input exit,               // 退出按钮
    input select,             // 切换按钮   
    input [7:0] in,           // 拨码开关的输入   
    input [7:0] total_player,
    input select_answer,
    output reg type_entered,
    output reg[7:0] seg1,      
    output reg[7:0] seg2,   
    output reg[7:0] seg3,   
    output reg[7:0] seg4,   
    output reg[7:0] seg5,   
    output reg[7:0] seg6,   
    output reg[7:0] seg7,   
    output reg[7:0] seg8,    
    output reg [7:0] led1,   // LED显示
    output reg [7:0] led2
);
parameter is_enter=4'b0100;
reg select_answer_entered = 1'b0;
reg[29:0] p [3:0][49:0];
reg [20:0] q [49:0];
reg [15:0] score [3:0];
integer i, j;

    always @(*) begin
        // 将 player_flat 展开到 p [3:0][49:0]
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 50; j = j + 1) begin
                p[i][j] = player_flat[(i * 50 + j) * 30 +: 30];
            end
        end

        // 将 mode_question_flat 展开到 q [49:0]
        for (i = 0; i < 50; i = i + 1) begin
            q[i] = mode_question_flat[i * 21 +: 21];
        end
    end

reg [3:0] mode = 4'b0001;        // 模式选择的储存
reg [2:0] store = 3'b000;           // 存储状态,00为未操作，01为存储a,10为存储b,11为输出结果
reg [1:0] player = 2'b0;               // 运算数 a
reg [5:0] question = 6'b0;               // 运算数 b

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
parameter NumC = 8'b1001_1100; // "C"
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
parameter M1=4'b0001;
parameter M2=4'b0010;
parameter M3=4'b0100;
parameter M4=4'b1000;
parameter is_mode_selected=3'b100;
always @(posedge clk) begin
    if(mode_sel==is_mode_selected&mode==M2&enter) begin
    if (select_answer&delay_trigger) begin
        select_answer_entered <= ~select_answer_entered;
    end
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


always @(posedge clk) begin
    if(mode_sel==is_mode_selected&enter) begin
    if(confirm&&delay_trigger) begin//注意判断条件有delay_trigger=1
        type_entered <= 1;      
    end 
    if(exit&&delay_trigger) begin
        type_entered <= 0;       
    end 
    end
end


// 该模块用于运算类型切换，点击select按钮切换模式mode，切换顺序为：00001，00010，00100，01000，10000，00001
always @(posedge clk) begin
    if(mode_sel==is_mode_selected&enter) begin
    if (select&delay_trigger) begin
        case (mode)
            M1: mode <= M2;
            M2: mode <= M3;
            M3: mode <= M4;
            M4: mode <= M1;
        endcase
    end
    end
end


// 该模块用于二元运算的操作步骤切换，点击select按钮切换步骤store，切换顺序为：00，01，10，11，00，
//00清零之前的运算，01提示输入a并时刻显示和存储a,10提示输入b并时刻显示和存储b,11显示最终结果
parameter Step1=3'b000;
parameter Step2=3'b001;
parameter Step3=3'b010;
parameter Step4=3'b011;
parameter Step5=3'b100;


always @(posedge clk) begin
    if(type_entered&enter)begin
        if (confirm&delay_trigger) begin
            case (store)
                Step1: begin
                    if(mode==M2)begin
                    store <=Step3;
                end
                else store <=Step2;
                end
                Step2: begin
                    store <=Step3;
                end
                Step3: store <=Step4;
                Step4: begin 
                if(mode==M4)begin
                    store <=Step5;
                end
                else begin 
                    store <=Step1;
                end
                end
                Step5: begin
                    store <=Step1;
                end
            endcase
        end
    end
end

reg [1:0] winner;    // 输出胜者的玩家编号 (0-3)
reg [15:0] max_score;       // 当前最优的玩家成绩
reg [1:0] candidate;        // 当前最优玩家编号

always @(posedge clk) begin
    max_score = score[0];   // 假设第一个玩家为当前最优
    candidate = 2'b00;      // 当前最优玩家编号初始化为 0
        // 遍历 4 个玩家进行比较
        for (i = 1; i < 4; i = i + 1) begin
            // 比较正确题目数
            if (score[i][15:10] > max_score[15:10]) begin
                max_score = score[i];
                candidate = i;
            end
            // 如果正确题目数相同，比较答题时间
            else if (score[i][15:10] == max_score[15:10]) begin
                // 比较总答题时间，答题时间少的获胜
                if (score[i][9:0] < max_score[9:0]) begin
                    max_score = score[i];
                    candidate = i;
                end
            end
        end
        winner = candidate;  // 最终获胜者
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
            led1<=Blank;
            led2<=Blank;
        case (mode)//未进入模式的时候seg1亮起，显示此时的运算类型（1，2，3，4，5）
            M1: seg1 <= NumA; 
            M2: seg1 <= NumB; 
            M3: seg1 <= NumC; 
            M4: seg1 <= digit_to_seg1(winner);
                default: seg1 <= Blank; // 默认值以防未定义操作
        endcase
        end
        1: begin    
    case(store)
    Step1: begin
        seg2<=Blank;
        seg3<=Blank;
        seg4<=Blank;
        seg5<=Blank;
        seg6<=Blank;
        seg7<=Blank;
        seg8<=Blank;
        for (i = 0; i < 4; i = i + 1) begin
            score[i][15:10] = 0;  // 清零
            score[i][9:0] = 0;    // 清零
            // 对应 50 个元素的加法
            for (j = 0; j < 50; j = j + 1) begin
                // 累加p[i][j][29:25]部分，放入 score[i][15:10]
                score[i][15:10] = score[i][15:10] + p[i][j][0];
                // 累加p[i][j][0]部分，放入 score[i][9:0]
                score[i][9:0] = score[i][9:0] + p[i][j][29:25];
            end
    end
        case (mode)//同时让seg1不要关闭
            M1: seg1 <= NumA; 
            M2: seg1 <= NumB; 
            M3: seg1 <= NumC; 
            M4: begin
                seg1 <= digit_to_seg1(winner);
                seg2 <= Blank;
                seg3<=Blank;
                seg4<=Blank;
                seg5<=Blank;
                seg6<=Blank;
                seg7<=Blank;
                seg8<=Blank;
            end
            default: seg1 <= Blank; // 默认值以防未定义操作
        endcase
        end
    Step2: begin
        case (mode)//同时让seg1不要关闭
            M1: seg1 <= NumA; 
            M2: seg1 <= NumB; 
            M3: seg1 <= NumC; 
            M4: begin
                seg1 <= digit_to_seg1(winner);
                seg2 <= Blank;
                seg3 <= digit_to_seg1(0);
                seg4 <= digit_to_seg1(score[0][15:10]/10);
                seg5 <= digit_to_seg1(score[0][15:10]%10);
                seg6 <= digit_to_seg1(score[0][9:0]/100);
                seg7 <= digit_to_seg1((score[0][9:0]/10)%10);
                seg8 <= digit_to_seg1(score[0][9:0]%10);
            end
                default: seg1 <= Blank; // 默认值以防未定义操作
        endcase
        if(mode!=M4) begin
        seg2 <= 8'b11001110;//这个数码管输出是p，提示输入p
        seg3 <= Blank;
        player<=in;
        end
    end
    Step3: begin
         case (mode)//同时让seg1不要关闭
            M1: seg1 <= NumA; 
            M2: seg1 <= NumB; 
            M3: seg1 <= NumC; 
            M4: begin
                seg1 <= digit_to_seg1(winner);
                seg2 <= Blank;
                seg3 <= digit_to_seg1(1);
                seg4 <= digit_to_seg1(score[1][15:10]/10);
                seg5 <= digit_to_seg1(score[1][15:10]%10);
                seg6 <= digit_to_seg1(score[1][9:0]/100);
                seg7 <= digit_to_seg1((score[1][9:0]/10)%10);
                seg8 <= digit_to_seg1(score[1][9:0]%10);
            end
                default: seg1 <= Blank; // 默认值以防未定义操作
        endcase
        if(mode!=M4) begin
        if(mode==M2) begin
            seg2<=8'b11100110;
        end
        else begin
            seg3 <= 8'b11100110;
        end
        question<=in;
        end
    end
    Step4: begin
        case(mode)
        M1: begin
            seg1 <= digit_to_seg1((question)/10);
            seg2 <= digit_to_seg1((question)%10);
            seg3 <= Blank;
            seg4 <= digit_to_seg1(p[player][question-1][29:25]/10); 
            seg5 <= digit_to_seg1(p[player][question-1][29:25]%10); 
            seg6 <= digit_to_seg1(score[player][9:0]/100);
            seg7 <= digit_to_seg1((score[player][9:0]/10)%10);
            seg8 <= digit_to_seg1(score[player][9:0]%10);
        end
        M2: begin
            seg1 <= digit_to_seg1((question)/10);
            seg2 <= digit_to_seg1((question)%10);
            seg3 <= Blank;
            seg4 <= digit_to_seg1(q[question-1][20:18]); 
            seg5 <= Blank;
            seg6 <= digit_to_seg1(q[question-1][17:16]+1); 
            seg7 <= Blank;
            seg8 <= Blank;
            if(select_answer_entered)begin//查看正确答案
                 case(q[question-1][20:18])
                3'b001:begin
                convert_binary(q[question-1][17:16],q[(question-1)][15:8],led1,led2 );
                 end
                 3'b010:begin
                signed_operation(q[question-1][17:16],q[(question-1)][15:8],q[(question-1)][7:0],led1,led2 );
                 end
                 3'b001:begin
                shift_operation(q[question-1][17:16],q[(question-1)][15:8],q[(question-1)][7:0],led1,led2 );
                 end
                 3'b001:begin
                bitwise_operation(q[question-1][17:16],q[(question-1)][15:8],q[(question-1)][7:0],led1,led2 );
                 end
                 3'b001:begin
                logic_operation(q[question-1][17:16],q[(question-1)][15:8],q[(question-1)][7:0],led1,led2 );
                 end
          endcase
         end
         else begin
             led1 <= q[(question-1)][15:8];
            led2 <= q[(question-1)][7:0];
         end
        end
        M3: begin
            seg1 <= digit_to_seg1(question/10);
            seg2 <= digit_to_seg1(question%10);
            seg3 <= Blank;
            seg4 <= digit_to_seg1(p[player][question-1][0]); 
            seg5 <= Blank;
            seg6 <= Blank;
            seg7 <= Blank;
            seg8 <= Blank;
            led1 <= p[player][question-1][24:17];
            led2[7:4] <= p[player][question-1][12:9];
            led2[3:0] <= p[player][question-1][4:1];
        end
        M4: begin
                seg1 <= digit_to_seg1(winner);
                seg2 <= Blank;
                seg3 <= digit_to_seg1(2);
                seg4 <= digit_to_seg1(score[2][15:10]/10);
                seg5 <= digit_to_seg1(score[2][15:10]%10);
                seg6 <= digit_to_seg1(score[2][9:0]/100);
                seg7 <= digit_to_seg1((score[2][9:0]/10)%10);
                seg8 <= digit_to_seg1(score[2][9:0]%10);
            end
    endcase
    end
    Step5: begin
        seg1 <= digit_to_seg1(winner);
        seg2 <= Blank;
        seg3 <= digit_to_seg1(3);
        seg4 <= digit_to_seg1(score[3][15:10]/10);
        seg5 <= digit_to_seg1(score[3][15:10]%10);
        seg6 <= digit_to_seg1(score[3][9:0]/100);
        seg7 <= digit_to_seg1((score[3][9:0]/10)%10);
        seg8 <= digit_to_seg1(score[3][9:0]%10);
    end
    endcase
end
        endcase
end

task convert_binary;
        input [1:0] op;
        input  [7:0] bin_value;
        output reg [7:0] answer1;
        output reg [7:0] answer2;


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
            answer1[7:4]= octal_hundreds_out;
            answer1[3:0]=octal_tens_out;
           answer2[7:4] = octal_ones_out;
           answer2[3:0] = 4'b0;
        end
        2'b01: begin
            answer1[7:4]= decimal_hundreds_out;
            answer1[3:0]=decimal_tens_out;
            answer2[7:4] = decimal_ones_out;
            answer2[3:0] = 4'b0;
        end
        2'b10: begin
            answer1[7:4]=  hex_high_out;
            answer1[3:0]= hex_low_out;
            answer2[7:4] = 4'b0;
            answer2[3:0] = 4'b0;
        end
       
    endcase
    
    end
endtask


task signed_operation;
    input [1:0] op;
    input [7:0] a;        // 输入的二进制值
    input [7:0] b;
    
    output reg [7:0] answer1;
    output reg [7:0] answer2;
    
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
            default: result = Blank;  // 默认情况
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
        answer1[7] = sign;  // 符号位
        answer1[3:0] = hundreds;  // 百位
        answer2[7:4] = tens;       // 十位
        answer2[3:0] = ones;        // 个位

       
    end
endtask

task shift_operation;
   input [1:0] op; 
    input signed [7:0] a;    // 输入的 8 位有符号数（算术移位用）
    input [7:0] b;           // 输入的无符号数，表示移位的位数（范围 0~7）
       
  
    output reg [7:0] answer1;
    output reg [7:0] answer2;


    reg [7:0] result;
begin
    // 根据操作代码进行相应的位移操作
    case(op)
        2'b00: result = a <<< b;  // 算术左移
        2'b01: result = a >>> b;  // 算术右移
        2'b10: result = a << b;   // 逻辑左移
        2'b11: result = a >> b;   // 逻辑右移
        default: result = Blank; // 默认值
    endcase
    answer1 = result;
    answer2 = 8'b0;
end
 
endtask

task bitwise_operation;
    input [1:0] operation;
    input [7:0] op_a;     // 任务输入a
    input [7:0] op_b;     // 任务输入b
    
   
    output reg [7:0] answer1;
    output reg [7:0] answer2;
    reg [7:0] result;

    begin
        case (operation)
            2'b00: result = op_a & op_b;  // 与操作
            2'b01: result = op_a | op_b;  // 或操作
            2'b10: result = ~op_a;         // 非操作
            2'b11: result = op_a ^ op_b;  // 异或操作
            default: result = 8'b0;          // 默认情况
        endcase
        answer1 =result;
        answer2= 8'b0;
    end
endtask


task logic_operation;
    input [1:0] operation;
    input [7:0] op_a;       // 任务输入a
    input [7:0] op_b;       // 任务输入b
    
    output reg [7:0] answer1;
    output reg [7:0] answer2;
    reg [7:0] result;

    begin
        case (operation)
            2'b00: result = {8{(op_a != 0) && (op_b != 0)}}; // 逻辑与操作
            2'b01: result = {8{(op_a != 0) || (op_b != 0)}}; // 逻辑或操作
            2'b10: result = {8{!(op_a != 0)}};               // 逻辑非操作
            2'b11: result = {8{(op_a != 0) ^ (op_b != 0)}}; // 逻辑异或操作
            default: result = 8'b0;                          // 默认情况
        endcase
      answer1 =result;
      answer2= 8'b0;
    end
endtask

endmodule
