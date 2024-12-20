`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/12 22:42:46
// Design Name: 
// Module Name: set
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


module set(
    input enter,
    input wire [2:0] mode_sel,
    input clk,
    input reset,
    input confirm,
    input select,
    input exit, 
    input [7:0] in,
    output reg [7:0] total_player=8'b00000100,
    output reg [7:0] seg1,
    output reg [7:0] seg2,
    output reg [7:0] seg3,
    output reg [7:0] seg4,
    output reg [7:0] seg5,
    output reg [7:0] seg6,
    output reg [7:0] seg7,
    output reg [7:0] seg8,
    output reg [5:0] total=6'b000000,
    output reg mode_entered,
    output reg [1049:0] mode_question_flat // 用于输出展平后的数组
);
parameter is_enter=4'b0100;
reg [20:0] mode_question [49:0];
integer i;

// 在 `always` 块中将二维数组展平为一维数组：
always @(posedge clk) begin
    // 将二维数组展平为一维数组
    for (i = 0; i < 50; i = i + 1) begin
        mode_question_flat[i * 21 +: 21] = mode_question[i];
    end
end
reg [3:0] op = 4'b0001; 

  //赛题总数

 // 模式1:前5位是模式，两位（00表示进制选择(00 b 01 o 10 h)，后八位输入的数据，最后八位全是零
//  模式2：前5位是模式，两位表示运算符选择（00 +  11 -），后十六位是ab
//  模式3：前5位是模式，两位表示运算选择，01，10，11 分别对应1234），后十六位是ab
//  模式4：前5位是模式，两位表示运算选择（00，01，10，11 分别对应1234），后十六位是ab
// 模式 5：前5位是模式，两位表示运算选择（00，01，10，11 分别对应1234），后十六位是ab 



reg [2:0] store = 3'b0; 
reg [2:0] current_digit = 0; 
reg [20:0] counter1 = 0; 
reg [4:0] mode = 5'b00001; 

parameter is_selected=3'b001;

//下面两行的计数器用来控制按下按钮的时间
localparam CLK_FREQ = 50000000; // 假设时钟频率为 50MHz
localparam DELAY_COUNT = CLK_FREQ / 2; // 0.5秒延迟的计数值


//下面四行的reg服务于task scan-display:
reg [24:0] counter = 0; // 计数器，足够容纳 25M 的值
reg delay_trigger = 0;  // 触发信号

localparam SCAN_DELAY = 10000;
always @(posedge clk) begin//这个always服务于task：scan-display
        counter1 <= counter1 + 1;
        if (counter1 == SCAN_DELAY) begin // 每 1 ms 触发一次 (100 MHz 时钟)
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
    if(mode_sel==is_selected&enter) begin
    if(confirm&&delay_trigger) begin//注意判断条件有delay_trigger=1
        mode_entered <= 1;            
    end 
    if(exit&&delay_trigger) begin
        mode_entered <= 0;       
    end 
    end
end


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

// 该模块用于运算类型切换，点击select按钮切换模式mode，切换顺序为：00001，00010，00100，01000，10000，00001，

parameter M1=5'b00_001;
parameter M2=5'b00_010;
parameter M3=5'b00_100;
parameter M4=5'b01_000;
parameter M5=5'b10_000;
parameter M6=5'b11_111;

always @(posedge clk) begin
    if(mode_sel==is_selected&enter) begin
    if(~mode_entered&&delay_trigger) begin
    if (select) begin
        case (mode)
            M1: mode <= M2;
            M2: mode <= M3;
            M3: mode <= M4;
            M4: mode <= M5;
            M5: mode <= M6;
            M6: mode <= M1;
        endcase
    end
    end
   end
end

parameter OP1=4'b00_01;
parameter OP2=4'b00_10;
parameter OP3=4'b01_00;
parameter OP4=4'b10_00;
// 该模块用于每个运算类型的操作符切换，点击select按钮切换操作符op，切换顺序为：0001，0010，0100，1000，0001，
//请把op的四个值参数化
always @(posedge clk) begin
    if(mode_sel==is_selected&enter) begin
    if(mode_entered&&delay_trigger)begin
    if (select) begin
        case (op)
            OP1: begin
               op<=OP2;
            end
            OP2: begin
                if(mode==M2) begin//第二个运算类型（符号加减）只有两个操作符，因此直接回到0001
                op <= OP1;
            end
               else
               op<=OP3;
            end
            OP3: begin
                 if(mode==M1) begin//第1个运算类型（符号加减）只有三个操作符(选择进制)，因此直接回到0001
                op <= OP1;
                 end else begin
                op <= OP4;
                end
            end   
            OP4: op <= OP1;
        endcase
    end
    end
    end
end

// 该模块用于二元运算的操作步骤切换，点击select按钮切换步骤store，切换顺序为：000，001，010，100，111
//000清零之前的运算，001提示输入a并时刻显示和存储a,010提示输入b并时刻显示和存储b
parameter Step1=3'b000;
parameter Step2=3'b001;
parameter Step3=3'b010;
parameter Step4=3'b100;
parameter Step5=3'b111;

always @(posedge clk) begin
    if(mode_sel==is_selected&enter) begin
    if(mode_entered&&delay_trigger)begin
    if (confirm) begin
        case (store)
            Step1: begin
            store <=Step2;
        end   
            Step2: begin
                if(mode==M1|mode==M6)begin
                store <=Step1;

            end
            else begin
                store <=Step3;
            end
            end

            Step3: store <=Step1;
    endcase
    end
    end
    end
end


parameter operat1=2'b00;
parameter operat2=2'b01;
parameter operat3=2'b10;
parameter operat4=2'b11;

parameter calmode1=3'b001;
parameter calmode2=3'b010;
parameter calmode3=3'b011;
parameter calmode4=3'b100;
parameter calmode5=3'b101;
always @(posedge clk) begin
    if(mode_sel==is_selected&enter) begin
     case(mode_entered)
        0: begin
            seg2<=Blank;
            seg3<=Blank;
            seg4<=Blank;
            seg5<=Blank;
            seg6<=Blank;
            seg7<=Blank;
            seg8<=Blank;
        
        case (mode)//未进入模式的时候seg1亮起，显示此时的运算类型（1，2，3，4，5）
                M1: seg1 <= Num1; 
                M2: seg1 <= Num2; 
                M3: seg1 <= Num3; 
                M4: seg1 <= Num4; 
                M5: seg1 <= Num5; 
                M6: seg1 <= Num6;
                default: seg1 <= Blank; // 默认值以防未定义操作
        endcase
   
     end
    
    1: begin
            
    case(store)
        Step1: begin
        seg3<=Blank;
        seg4<=Blank;
        seg5<=Blank;
        seg6<=Blank;
        seg7<=Blank;
        seg8<=Blank;
       
      
        case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4)
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
         case (mode)//同时让seg1不要关闭
                M1: begin
                    case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4)
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase



                seg1 <= Num1;
                end 
                M2: begin
                    case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4)
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
                    seg1 <= Num2;
                end 
                M3:begin
                    case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4)
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
                     seg1 <= Num3; 
                     end
                M4:begin 
                    case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4)
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
                    seg1 <= Num4;
                     end
                M5: begin 
                    case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4)
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
                    seg1 <= Num5; 

                end
                M6:begin 
                    seg1 <= Num6; 
                    seg2 <= 8'b11101100;
                    total_player <= in;
                   
                end
                default: seg1 <= Blank;
        endcase
        seg3 <=8'b0;
        seg4 <=8'b0;
      
    end
    Step2: begin
if(mode == M6 )begin
            seg3 <= digit_to_seg1(total_player) ;
        end
        else begin
        seg3 <= 8'b00111010;//这个数码管输出是a，提示输入a
        seg4 <= Blank;//b此时不出现
        if(confirm&&delay_trigger) begin
        case (mode)
                M1:begin
            case (op)
                OP1: begin
                seg2 <= Num1;
                mode_question[total][17:16] <= operat1;
                end
                OP2:begin 
                seg2 <= Num2; 
                mode_question[total][17:16] <= operat2;
                end
                OP3: begin
                seg2 <= Num3; 
                mode_question[total][17:16] <= operat3;
                end
                default: seg2 <= Blank; 
            endcase
                seg1 <= Num1; 
                 mode_question[total][20:18] <= calmode1;
                 mode_question[total][15:8]  <= in;
                 mode_question[total][7:0]  <= 8'b00000000;
                 total <= total + 1'b1;
                 seg8<=digit_to_seg1(total%10);
            end

            M2:begin
            case (op)
                OP1: begin
                seg2 <= Num1;
                mode_question[total][17:16] <= operat1;
                end
                OP2: begin
                seg2 <= Num2; 
                mode_question[total][17:16] <= operat4;
                end
                default: seg2 <= Blank; 
            endcase
                 seg1 <= Num2; 
                 mode_question[total][20:18] <= calmode2;
                 mode_question[total][15:8]  <= in;
            end

            M3:begin
            case (op)
                OP1: begin
                seg2 <= Num1;
                mode_question[total][17:16] <= operat1;
                end
                OP2: begin 
                seg2 <= Num2; 
                mode_question[total][17:16] <= operat2;
                end
                OP3: begin
                seg2 <= Num3; 
                mode_question[total][17:16] <= operat3;
                end
                OP4: begin
                seg2 <= Num4; 
                mode_question[total][17:16] <= operat4;
                end
                default: seg2 <= Blank; 
            endcase
                seg1 <= Num3; 
                 mode_question[total][20:18] <= calmode3;
                 mode_question[total][15:8]  <= in;
            

            end

            M4:begin
            case (op)
               OP1:begin 
                seg2 <= Num1;
                mode_question[total][17:16] <= operat1;
               end
                OP2: begin
                seg2 <= Num2; 
                mode_question[total][17:16] <= operat2;
                end
                OP3:begin 
                seg2 <= Num3; 
                mode_question[total][17:16] <= operat3;
                end
                OP4: begin
                seg2 <= Num4; 
                mode_question[total][17:16] <= operat4;
                end
                default: seg2 <= Blank;
            endcase
                seg1 <= Num4; 
                 mode_question[total][20:18] <= calmode4;
                 mode_question[total][15:8]  <= in;
        

            end

            M5:begin
            case (op)
                OP1: begin
                seg2 <= Num1;
                mode_question[total][17:16] <= operat1;
                end
                OP2: begin 
                seg2 <= Num2; 
                mode_question[total][17:16] <= operat2;
                end
                OP3: begin
                seg2 <= Num3; 
                mode_question[total][17:16] <= operat3;
                end
                OP4: begin
                seg2 <= Num4; 
                mode_question[total][17:16] <= operat4;
                end
                default: seg2 <= Blank;
            endcase
                seg1 <= Num5; 
                 mode_question[total][20:18] <= calmode5;
                 mode_question[total][15:8]  <= in;
           

            end
        endcase
end
    end
    end
    Step3: begin

        seg3 <= 8'b00111010;
        seg4 <= 8'b00111110;
if(confirm&&delay_trigger) begin
         case (mode)
                M2:begin
            case (op)
                OP1: begin
                seg2 <= Num1;
                end
                OP2:begin 
                seg2 <= Num2; 
                end
                default: seg2 <= Blank; 
            endcase
                 seg1 <= Num2; 
                mode_question[total][7:0]  <= in;
                total <= total + 1'b1;

            end

            M3:begin
            case (op)
                OP1:begin  
                seg2 <= Num1;
                end
                OP2: begin 
                seg2 <= Num2; 
               end
                OP3: begin 
                seg2 <= Num3; 
              end
                OP4: begin 
                seg2 <= Num4; 
            end
                default: seg2 <= Blank; 
            endcase
                seg1 <= Num3; 
                 mode_question[total][7:0]  <= in;
                 total <= total + 1'b1;
            end

            M4:begin
            case (op)
               OP1: begin 
                seg2 <= Num1;
                end
                OP2: begin 
                seg2 <= Num2; 
            end
                OP3: begin 
                seg2 <= Num3; 
           end
                OP4: begin 
                seg2 <= Num4; 
          end
                default: seg2 <= Blank;
            endcase
                seg1 <= Num4; 
                 mode_question[total][7:0]  <= in;
                 total <= total + 1'b1;
            end

            M5:begin
            case (op)
                OP1: begin 
                seg2 <= Num1;
             end
                OP2: begin 
                seg2 <= Num2; 
          end
                OP3: begin 
                seg2 <= Num3; 
               end
                OP4: begin 
                seg2 <= Num4; 
              end
                default: seg2 <= Blank;
            endcase
                seg1 <= Num5; 
                 mode_question[total][7:0] <= in;
                total <= total + 1'b1;

            end
        endcase    
end
    end   
    endcase
end
endcase
    end
    seg8<=digit_to_seg1(total%10);
end

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

endmodule
