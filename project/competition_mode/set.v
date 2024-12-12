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
    input wire [2:0] mode_sel,
    input clk,
    input reset,
    input confirm,
    input select,
    input exit, 
    input [7:0] in,
    output reg [7:0] seg1,
    output reg [7:0] seg2,
    output reg [7:0] seg3,
    output reg [7:0] seg4,
    output reg [7:0] seg5,
    output reg [7:0] seg6,
    output reg [7:0] seg7,
    output reg [7:0] seg8,
    output reg mode_entered,
    output reg [1049:0] mode_question_flat // 用于输出展平后的数组
);
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

reg total = 6'b0;    //赛题总数

 // 模式1:前5位是模式，两位（00表示进制选择(00 b 01 o 10 h)，后八位输入的数据，最后八位全是零
                                //  模式2：前5位是模式，两位表示运算符选择（00 +  11 -），后十六位是ab
                                //  模式3：前5位是模式，两位表示运算选择，01，10，11 分别对应1234），后十六位是ab
                                //  模式4：前5位是模式，两位表示运算选择（00，01，10，11 分别对应1234），后十六位是ab
                                // 模式 5：前5位是模式，两位表示运算选择（00，01，10，11 分别对应1234），后十六位是ab 



reg [2:0] store = 3'b0; 
reg [2:0] current_digit = 0; 
reg [20:0] counter1 = 0; 
reg [4:0] mode = 5'b00001; 

reg [7:0] seg1= 8'b0;    // 最终传入scan-display的数码管
reg [7:0] seg2= 8'b0;     
reg [7:0] seg3= 8'b0;             
reg [7:0] seg4= 8'b0;
reg [7:0] seg5= 8'b0; 
reg [7:0] seg6= 8'b0;     
reg [7:0] seg7= 8'b0;             
reg [7:0] seg8= 8'b0;



//下面两行的计数器用来控制按下按钮的时间
localparam CLK_FREQ = 50000000; // 假设时钟频率为 50MHz
localparam DELAY_COUNT = CLK_FREQ / 2; // 0.5秒延迟的计数值


//下面四行的reg服务于task scan-display:
reg [24:0] counter = 0; // 计数器，足够容纳 25M 的值
reg delay_trigger = 0;  // 触发信号


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
    if(mode_sel==3'b001) begin
    if(confirm&&delay_trigger) begin//注意判断条件有delay_trigger=1
        mode_entered <= 1;            
    end 
    if(exit&&delay_trigger) begin
        mode_entered <= 0;       
    end 
    end
end


// 该模块用于运算类型切换，点击select按钮切换模式mode，切换顺序为：00001，00010，00100，01000，10000，00001，
//请把mode的五个值参数化

always @(posedge clk) begin
    if(mode_sel==3'b001) begin
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
   



end

// 该模块用于每个运算类型的操作符切换，点击select按钮切换操作符op，切换顺序为：0001，0010，0100，1000，0001，
//请把op的四个值参数化
always @(posedge clk) begin
    if(mode_sel==3'b001) begin
    if(mode_entered&&delay_trigger)begin
    if (select) begin
        case (op)
            4'b0001: begin
               op<=4'b0010;
            end
            4'b0010: begin
                if(mode==5'b00010) begin//第二个运算类型（符号加减）只有两个操作符，因此直接回到0001
                op <= 4'b0001;
            end
               else
               op<=4'b0100;
            end
            4'b0100: begin
                 if(mode==5'b00001) begin//第1个运算类型（符号加减）只有三个操作符(选择进制)，因此直接回到0001
                op <= 4'b0001;
            end else
                op <= 4'b1000;
            end   
            4'b1000: op <= 4'b0001;
        endcase
    end
    end
    end
end

// 该模块用于二元运算的操作步骤切换，点击select按钮切换步骤store，切换顺序为：000，001，010，100，111
//000清零之前的运算，001提示输入a并时刻显示和存储a,010提示输入b并时刻显示和存储b
//请把store的四个值参数化
always @(posedge clk) begin
    if(mode_sel==3'b001) begin
    if(mode_entered&&delay_trigger)begin
    if (confirm) begin
        case (store)
            3'b000: begin
            store <=3'b001;
        end   
            3'b001: begin
                if(mode==5'b00001)begin
                store <=3'b000;

            end
            else begin
                store <=3'b010;
            end
            end

            3'b010: store <=3'b000;
    endcase
    end
    end
    end
end

always @(posedge clk) begin
    if(mode_sel==3'b001) begin
     case(mode_entered)
        0: begin
            seg2<=8'b0;
            seg3<=8'b0;
            seg4<=8'b0;
            seg5<=8'b0;
            seg6<=8'b0;
            seg7<=8'b0;
            seg8<=8'b0;
        
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
        3'b000: begin
        seg3<=8'b0;
        seg4<=8'b0;
        seg5<=8'b0;
        seg6<=8'b0;
        seg7<=8'b0;
        seg8<=8'b0;
       
      
        case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4)
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
      
    end
    3'b001: begin

        seg3 <= 8'b00111010;//这个数码管输出是a，提示输入a
        seg4 <= 8'b0;//b此时不出现

        case (mode)
                5'b00001:begin
            case (op)
                4'b0001: begin
                seg2 <= 8'b0110_0000;
                mode_question[total][17:16] <= 2'b00;
                end
                4'b0010:begin 
                seg2 <= 8'b1101_1010; 
                mode_question[total][17:16] <= 2'b01;
                end
                4'b0100: begin
                seg2 <= 8'b1111_0010; 
                mode_question[total][17:16] <= 2'b10;
                end
                default: seg2 <= 8'b0000_0000; 
            endcase
                seg1 <= 8'b0110_0000; 
                 mode_question[total][20:18] <= 3'b001;
                 mode_question[total][15:8]  <= in;
                 mode_question[total][7:0]  <= 8'b00000000;
                 total <= total + 1'b1;

            end

            5'b00010:begin
            case (op)
                4'b0001: begin
                seg2 <= 8'b0110_0000;
                mode_question[total][17:16] <= 2'b00;
                end
                4'b0010: begin
                seg2 <= 8'b1101_1010; 
                mode_question[total][17:16] <= 2'b11;
                end
                default: seg2 <= 8'b0000_0000; 
            endcase
                 seg1 <= 8'b1101_1010; 
                 mode_question[total][20:18] <= 3'b010;
                 mode_question[total][15:8]  <= in;
                

            end

            5'b00100:begin
            case (op)
                4'b0001: begin
                seg2 <= 8'b0110_0000;
                mode_question[total][17:16] <= 2'b00;
                end
                4'b0010: begin 
                seg2 <= 8'b1101_1010; 
                mode_question[total][17:16] <= 2'b01;
                end
                4'b0100: begin
                seg2 <= 8'b1111_0010; 
                mode_question[total][17:16] <= 2'b10;
                end
                4'b1000: begin
                seg2 <= 8'b0110_0110; 
                mode_question[total][17:16] <= 2'b11;
                end
                default: seg2 <= 8'b0000_0000; 
            endcase
                seg1 <= 8'b1111_0010; 
                 mode_question[total][20:18] <= 3'b011;
                 mode_question[total][15:8]  <= in;
            

            end

            5'b01000:begin
            case (op)
               4'b0001:begin 
                seg2 <= 8'b0110_0000;
                mode_question[total][17:16] <= 2'b00;
               end
                4'b0010: begin
                seg2 <= 8'b1101_1010; 
                mode_question[total][17:16] <= 2'b01;
                end
                4'b0100:begin 
                seg2 <= 8'b1111_0010; 
                mode_question[total][17:16] <= 2'b10;
                end
                4'b1000: begin
                seg2 <= 8'b0110_0110; 
                mode_question[total][17:16] <= 2'b11;
                end
                default: seg2 <= 8'b0000_0000;
            endcase
                seg1 <= 8'b0110_0110; 
                 mode_question[total][20:18] <= 3'b100;
                 mode_question[total][15:8]  <= in;
        

            end

            5'b10000:begin
            case (op)
                4'b0001: begin
                seg2 <= 8'b0110_0000;
                mode_question[total][17:16] <= 2'b00;
                end
                4'b0010: begin 
                seg2 <= 8'b1101_1010; 
                mode_question[total][17:16] <= 2'b01;
                end
                4'b0100: begin
                seg2 <= 8'b1111_0010; 
                mode_question[total][17:16] <= 2'b10;
                end
                4'b1000: begin
                seg2 <= 8'b0110_0110; 
                mode_question[total][17:16] <= 2'b11;
                end
                default: seg2 <= 8'b0000_0000;
            endcase
                seg1 <= 8'b1011_0110; 
                 mode_question[total][20:18] <= 3'b101;
                 mode_question[total][15:8]  <= in;
           

            end
        endcase
end
    3'b010: begin

        seg3 <= 8'b00111010;
        seg4 <= 8'b00111110;

         case (mode)
                5'b00010:begin
            case (op)
                4'b0001: begin
                seg2 <= 8'b0110_0000;
                end
                4'b0010:begin 
                seg2 <= 8'b1101_1010; 
                end
                default: seg2 <= 8'b0000_0000; 
            endcase
                 seg1 <= 8'b1101_1010; 
                mode_question[total][7:0]  <= in;
                total <= total + 1'b1;

            end

            5'b00100:begin
            case (op)
                4'b0001:begin  
                seg2 <= 8'b0110_0000;
                end
                4'b0010: begin 
                seg2 <= 8'b1101_1010; 
               end
                4'b0100: begin 
                seg2 <= 8'b1111_0010; 
              end
                4'b1000: begin 
                seg2 <= 8'b0110_0110; 
            end
                default: seg2 <= 8'b0000_0000; 
            endcase
                seg1 <= 8'b1111_0010; 
                 mode_question[total][7:0]  <= in;
                 total <= total + 1'b1;
            end

            5'b01000:begin
            case (op)
               4'b0001: begin 
                seg2 <= 8'b0110_0000;
                end
                4'b0010: begin 
                seg2 <= 8'b1101_1010; 
            end
                4'b0100: begin 
                seg2 <= 8'b1111_0010; 
           end
                4'b1000: begin 
                seg2 <= 8'b0110_0110; 
          end
                default: seg2 <= 8'b0000_0000;
            endcase
                seg1 <= 8'b0110_0110; 
                 mode_question[total][7:0]  <= in;
                 total <= total + 1'b1;
            end

            5'b10000:begin
            case (op)
                4'b0001: begin 
                seg2 <= 8'b0110_0000;
             end
                4'b0010: begin 
                seg2 <= 8'b1101_1010; 
          end
                4'b0100: begin 
                seg2 <= 8'b1111_0010; 
               end
                4'b1000: begin 
                seg2 <= 8'b0110_0110; 
              end
                default: seg2 <= 8'b0000_0000;
            endcase
                seg1 <= 8'b1011_0110; 
                 mode_question[total][7:0] <= in;
                total <= total + 1'b1;

            end
        endcase    
    end   
    endcase
end
endcase
    end
end
endmodule
