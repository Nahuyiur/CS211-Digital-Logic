

module review(
    input wire [1049:0] mode_question_flat,
    input wire [5999:0] player_flat,
    input wire [63:0] score_flat,
    input wire [2:0] mode_sel,
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
    output reg [7:0] led1,   // LED显示
    output reg [7:0] led2
);


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

        // 将 score_flat 展开到 score [3:0]
        for (i = 0; i < 4; i = i + 1) begin
            score[i] = score_flat[i * 16 +: 16];
        end
    end



    
reg [2:0] mode = 3'b001;        // 模式选择的储存
reg [1:0] store = 2'b0;           // 存储状态,00为未操作，01为存储a,10为存储b,11为输出结果
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
    if(mode_sel==3'b100) begin
    if(confirm&&delay_trigger) begin//注意判断条件有delay_trigger=1
        type_entered <= 1;      
    end 
    if(exit&&delay_trigger) begin
        type_entered <= 0;       
    end 
    end
end

// 该模块用于运算类型切换，点击select按钮切换模式mode，切换顺序为：00001，00010，00100，01000，10000，00001(用type做了参数化)
always @(posedge clk) begin
    if(mode_sel==3'b100) begin
    if(~type_entered&&delay_trigger) begin
    if (select) begin
        case (mode)
            3'b001: mode <= 3'b010;
            3'b010: mode <= 3'b100;
            3'b100: mode <= 3'b001;
        endcase
    end
    end
    end
end


// 该模块用于二元运算的操作步骤切换，点击select按钮切换步骤store，切换顺序为：00，01，10，11，00，
//00清零之前的运算，01提示输入a并时刻显示和存储a,10提示输入b并时刻显示和存储b,11显示最终结果
parameter Step1=2'b00;
parameter Step2=2'b01;
parameter Step3=2'b10;
parameter Step4=2'b11;

always @(posedge clk) begin
    if(type_entered)begin
        if (confirm&&delay_trigger) begin
            case (store)
                Step1: begin
                    if(mode==3'b010)begin
                    store <=Step3;
                end
                else store <=Step2;
                end
                Step2: begin
                    store <=Step3;
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
            led1<=Blank;
            led2<=Blank;
        case (mode)//未进入模式的时候seg1亮起，显示此时的运算类型（1，2，3，4，5）
                3'b001: seg1 <= Num1; 
                3'b010: seg1 <= Num2; 
                3'b100: seg1 <= Num3; 
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
        case (mode)//同时让seg1不要关闭
               3'b001: seg1 <= Num1; 
                3'b010: seg1 <= Num2; 
                3'b100: seg1 <= Num3; 
                default: seg1 <= Blank; // 默认值以防未定义操作
        endcase
        led1 <= Blank;
        led2 <= Blank;
    end
    Step2: begin
        case (mode)//同时让seg1不要关闭
               3'b001: seg1 <= Num1; 
                3'b010: seg1 <= Num2; 
                3'b100: seg1 <= Num3; 
                default: seg1 <= Blank; // 默认值以防未定义操作
        endcase
        seg2 <= 8'b11001110;//这个数码管输出是p，提示输入p
        seg3 <= Blank;
        player<=in;
    end
    Step3: begin
         case (mode)//同时让seg1不要关闭
               3'b001: seg1 <= Num1; 
                3'b010: seg1 <= Num2; 
                3'b100: seg1 <= Num3; 
                default: seg1 <= Blank; // 默认值以防未定义操作
        endcase
        if(mode==3'b010) begin
            seg2<=8'b11100110;
        end
        else begin
            seg3 <= 8'b11100110;
        end
        question<=in;
    end
    Step4: begin
        case(mode)
        3'b001: begin
            seg1 <= digit_to_seg1(player);
            seg2 <= digit_to_seg1((question)/10);
            seg3 <= digit_to_seg1((question)%10);
            seg4 <= Blank;
            seg5 <= digit_to_seg1(p[player][(question-1)][29:25]/10); 
            seg6 <= digit_to_seg1(p[player][(question-1)][29:25]%10); 
            seg7 <= digit_to_seg1(score[player][15:10]/10);
            seg8 <= digit_to_seg1(score[player][15:10]%10);
        end
        3'b010: begin
            seg1 <= digit_to_seg1((question)/10);
            seg2 <= digit_to_seg1((question)%10);
            seg3 <= Blank;
            seg4 <= digit_to_seg1(q[(question-1)][20:18]); 
            seg5 <= digit_to_seg1(q[(question-1)][17:16]+1); 
            seg6 <= Blank;
            seg7 <= Blank;
            seg8 <= Blank;
            led1 <= q[(question-1)][15:8];
            led2 <= q[(question-1)][7:0];
        end
        3'b100: begin
            seg1 <= digit_to_seg1(player);
            seg2 <= digit_to_seg1((question)/10);
            seg3 <= digit_to_seg1((question)%10);
            seg4 <= Blank;
            seg5 <= digit_to_seg1(p[player][(question-1)][0]); 
            seg6 <= Blank;
            seg7 <= Blank;
            seg8 <= Blank;
            led1 <= p[player][(question-1)][24:17];
            led2 <= p[player][(question-1)][24:17];
        end
    endcase
        end
    endcase
        end
    endcase
end



endmodule
