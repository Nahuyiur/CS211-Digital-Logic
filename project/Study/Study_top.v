`timescale 1ns / 1ps

module study_top(
    input [3:0] enter,
    input clk,                // 时钟信号
    input reset,              // 复位信号
    input confirm,            // 确定操作的按钮
    input exit,               // 退出按钮
    input select,             // 切换按钮   
    input data,
    input [7:0] in,
    output reg [2:0] correct,  
    output reg mode_entered,
    output reg[7:0] seg1,      
    output reg[7:0] seg2,   
    output reg[7:0] seg3,   
    output reg[7:0] seg4,   
    output reg[7:0] seg5,   
    output reg[7:0] seg6,   
    output reg[7:0] seg7,   
    output reg[7:0] seg8 
);
  
//加一个状态按下按钮之后，将显示学情改为1
   reg data_state = 0;
   reg[4:0] data_mode_state  = 5'b00001;//这个用于学情显示下的模式，并不代表真正的模式
  
   reg [7:0] user_input_mode1 [7:0]; //存储模式1下用户输入的八个数据
<<<<<<< HEAD
   reg [7:0] user_input_mode2 [3:0] ; //存储模式2下用户输入的四个数据
=======
   reg [7:0] user_input_mode2 ; //存储模式2下用户输入的四个数据
>>>>>>> dcd3df4c8cc23d7c64197c05bd230f1f12a4ef28
   reg [7:0] user_input_mode3 = 8'b0; 
   reg [7:0] user_input_mode4 = 8'b0;
   reg [7:0] user_input_mode5 = 8'b0;   

   reg answer_result = 1'b0;

    reg [7:0] mode1_answer [7:0] ;//八，十，十六 分别的百十个位，高低位
    reg [7:0] mode2_answer[3:0]  ;//千百十个
    reg[7:0] mode3_answer = 8'b0;
    reg[7:0] mode4_answer = 8'b0 ;
    reg[7:0] mode5_answer = 8'b0;



    reg[7:0] mode1_amount = 8'b0;
    reg[7:0] mode2_amount = 8'b0;
    reg[7:0] mode3_amount = 8'b0;
    reg[7:0] mode4_amount  = 8'b0;
    reg[7:0] mode5_amount = 8'b0;

    reg[7:0] mode1_correct_amount = 8'b0;
    reg[7:0] mode2_correct_amount = 8'b0;
    reg[7:0] mode3_correct_amount = 8'b0;
    reg[7:0] mode4_correct_amount = 8'b0;
    reg[7:0] mode5_correct_amount = 8'b0 ;
   
    reg [3:0] mode1_tens = 4'b0; // 存储模式1正确率的十位
    reg [3:0] mode1_ones = 4'b0;  // 存储模式1正确率的个位
    reg [3:0] mode2_tens = 4'b0; // 存储模式2正确率的十位
    reg [3:0] mode2_ones = 4'b0;  // 存储模式2正确率的个位
    reg [3:0] mode3_tens= 4'b0;   // 存储模式3正确率的十位
    reg [3:0] mode3_ones= 4'b0;   // 存储模式3正确率的个位
    reg [3:0] mode4_tens= 4'b0;   // 存储模式4正确率的十位
    reg [3:0] mode4_ones= 4'b0;   // 存储模式4正确率的个位
    reg [3:0] mode5_tens= 4'b0;   // 存储模式5正确率的十位
    reg [3:0] mode5_ones= 4'b0;   // 存储模式5正确率的个位

reg [4:0] mode = 5'b00001;            // 模式选择的储存
reg [3:0] op = 4'b0001;              // 运算操作选择的储存
reg [2:0] store = 3'b0;           // 存储状态,000为未操作，001为存储a,010为存储b,100为输出结果 111（未修改）
reg [7:0] a = 8'b0;               // 运算数 a
reg [7:0] b = 8'b0;               // 运算数 b

reg [2:0] counter_a = 3'b000; 
reg [2:0] counter_b = 3'b000; 




//下面两行的计数器用来控制按下按钮的时间
localparam CLK_FREQ = 50000000; // 假设时钟频率为 50MHz
localparam DELAY_COUNT = CLK_FREQ / 2; // 0.5秒延迟的计数值

//下面四行的reg服务于task scan-display:
reg [24:0] counter = 0; // 计数器，足够容纳 25M 的值
reg delay_trigger = 0;  // 触发信号

reg [2:0] current_digit = 0; 
reg [20:0] counter1 = 0;   

// 实例化6个子模块（都没有用）


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
parameter Minus= 8'b0000_0010; //"-"
parameter Numa= 8'b0011_1010; //"a"
parameter Numb= 8'b0011_1110; //"b"
parameter Numr= 8'b1000_1100; //"r" 

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
parameter is_enter=4'b0010;
always @(posedge clk) begin
     if(enter==is_enter) begin
    if(confirm&&delay_trigger) begin//注意判断条件有delay_trigger=1
        mode_entered <= 1;            
    end 
    if(exit&&delay_trigger) begin
        mode_entered <= 0;       
    end 
     end
end


//按下data键进入学情查看，data_state变为1，再次按下退出，data_state变为0
always @(posedge clk) begin
     if(enter==is_enter) begin
    if(data&&delay_trigger) begin//注意判断条件有delay_trigger=1
       data_state <= ~data_state;  
    end         
    end 
end



//学情的数码管显示
parameter DM1=5'b00_001;
parameter DM2=5'b00_010;
parameter DM3=5'b00_100;
parameter DM4=5'b01_000;
parameter DM5=5'b10_000;

//进入学情查看后的切换模式，查看相应的题目数量的正确率
always @(posedge clk) begin
     if(enter==is_enter) begin
    if(data_state) begin
    if (select  && delay_trigger) begin
        case (data_mode_state)//非真实选择
            DM1: data_mode_state <= DM2;
            DM2: data_mode_state <= DM3;
            DM3: data_mode_state <= DM4;
            DM4: data_mode_state <= DM5;
            DM5: data_mode_state <= DM1;
        endcase
    end
    end
   end
end


// 该模块用于运算类型切换，点击select按钮切换模式mode，切换顺序为：00001，00010，00100，01000，10000，00001，
parameter M1=5'b00_001;
parameter M2=5'b00_010;
parameter M3=5'b00_100;
parameter M4=5'b01_000;
parameter M5=5'b10_000;

always @(posedge clk) begin
     if(enter==is_enter) begin
    if(~mode_entered&&delay_trigger) begin
    if (select) begin
        case (mode)
            M1: mode <= M2;
            M2: mode <= M3;
            M3: mode <= M4;
            M4: mode <= M5;
            M5: mode <= M1;
        endcase
    end
    end
   end
   
end

// 该模块用于每个运算类型的操作符切换，点击select按钮切换操作符op，切换顺序为：0001，0010，0100，1000，0001，
parameter OP1=4'b00_01;
parameter OP2=4'b00_10;
parameter OP3=4'b01_00;
parameter OP4=4'b10_00;
always @(posedge clk) begin
     if(enter==is_enter) begin
    if(mode_entered&&delay_trigger)begin
    if (select) begin
        case (op)
            OP1: begin
                if(mode==M1) begin//第一个运算类型（进制转换）只有一个操作符，因此直接回到0001
                op <= OP1;
            end
               else
               op<=OP2;
            end
            OP2: begin
                if(mode==M2) begin//第二个运算类型（符号加减）只有两个操作符，因此直接回到0001
                op <= OP1;
            end
               else
               op<=OP3;
            end
            OP3: op <= OP4;
            OP4: op <= OP1;
        endcase
    end
    end
     end
end

// 该模块用于二元运算的操作步骤切换，点击select按钮切换步骤store，切换顺序为：000，001，010，100，111
//000清零之前的运算，001提示输入a并时刻显示和存储a,010提示输入b并时刻显示和存储b,100提示用户输入答案并存储答案 ，111显示最终结果对错
parameter Step1=3'b000;
parameter Step2=3'b001;
parameter Step3=3'b010;
parameter Step4=3'b100;
parameter Step5=3'b111;
parameter Step6=3'b110;
always @(posedge clk) begin
     if(enter==is_enter) begin
    if(mode_entered&&delay_trigger&&~data_state)begin
    if (confirm) begin
        case (store)
            Step1: begin
            store <=Step2;
          
         end   
            Step2: begin
                if(mode==M1)begin
                store <=Step4;

            end
            else begin
                store <=Step3;
            end
            end

            Step3: store <=Step4;


            Step4: begin
            if(mode==M1)begin
               
                
            if (counter_a < 7) begin  
                user_input_mode1[counter_a] <= in; 
                counter_a <= counter_a + 1;

                      
            end 
            else  begin
              store <=Step5;
              counter_a <= 3'b0;
           
         end

        end

        if(mode==M2)begin
           if (counter_b < 3) begin  
                user_input_mode1[counter_b] <= in; 
                counter_b <= counter_b + 1;
                      
            end 
            else  begin
              store <=Step5;
              counter_b <= 3'b0;
           
         end       

              
         end
             if(mode==M3) begin
               user_input_mode3 <= in;
               store <=Step5;
 
            end
              if(mode==M4) begin
               user_input_mode4 <= in;
               store <=Step5;
                
            end
              if(mode==M5) begin
               user_input_mode5 <= in;
               store <=Step5;
                
            end
            end

            Step5: store <= Step6;

            Step6: store <= Step1; 

    endcase
    end
    end
     end
end


always @(posedge clk) begin
     if(enter==is_enter) begin
   if(data_state == 1)begin
   case(data_mode_state) 
    DM1:begin
        if(mode1_amount == mode1_correct_amount &&  mode1_amount != 0)begin
        seg1 <= Num1;         // 显示为"1"
        seg2 <= Blank;         //不显示
        seg3 <= digit_to_seg2(mode1_amount /10);      //题目数量的十位
        seg4 <= digit_to_seg2(mode1_amount % 10);     //题目数量的个位
        seg5 <= Blank;         //不显示
        seg6 <= Num1;          //正确率百位 1
        seg7 <= Num0;         //正确率十位 0
        seg8 <= Num0;         //正确率个位 0
    end

        else begin
              mode1_tens <= ((mode1_correct_amount * 100) / mode1_amount) / 10;  // 十位
              mode1_ones <= ((mode1_correct_amount * 100) / mode1_amount) % 10;  // 个位
             seg1 <= Num1;         // 显示为"1"
             seg2 <= Blank;         //不显示
             seg3 <= digit_to_seg2(mode1_amount /10);      //题目数量的十位
             seg4 <= digit_to_seg2(mode1_amount % 10);     //题目数量的个位
             seg5 <= Blank;         //不显示
             seg6 <= Blank;          //正确率百位 0
             seg7 <= digit_to_seg1(mode1_tens);
             seg8 <= digit_to_seg1(mode1_ones);
        end
        
 end  
    
    
    DM2:begin
    if(mode2_amount == mode2_correct_amount &&  mode2_amount != 0 )begin
        seg1 <= Num2; // 显示 "2"
        seg2 <= Blank;         //不显示
        seg3 <= digit_to_seg2(mode2_amount /10);      //题目数量的十位
        seg4 <= digit_to_seg2(mode2_amount % 10);     //题目数量的个位
        seg5 <= Blank;         //不显示
        seg6 <= Num1;         //正确率百位 1
        seg7 <= Num0;         //正确率十位 0
        seg8 <= Num0;         //正确率个位 0
    end

        else begin
             mode2_tens <= ((mode2_correct_amount * 100) / mode2_amount) / 10;  // 十位
             mode2_ones <= ((mode2_correct_amount * 100) / mode2_amount) % 10;  // 个位
             seg1 <= Num1;         // 显示为"1"
             seg2 <= Blank;         //不显示
             seg3 <= digit_to_seg2(mode2_amount /10);      //题目数量的十位
             seg4 <= digit_to_seg2(mode2_amount % 10);     //题目数量的个位
             seg5 <= Blank;         //不显示
             seg6 <= Blank;          //正确率百位 1
             seg7  <= digit_to_seg2(mode2_tens);
             seg8 <= digit_to_seg2 (mode2_ones);
        end
end


    DM3:begin
    if(mode3_amount == mode3_correct_amount && mode3_amount != 0)begin
        seg1 <= Num3; // 显示 "3"
        seg2 <= Blank;//不显示
        seg3 <= digit_to_seg2(mode3_amount /10);      //题目数量的十位
        seg4 <= digit_to_seg2(mode3_amount % 10);     //题目数量的个位
        seg5 <= Blank;         //不显示
        seg6 <= Num1;         //正确率百位 1
        seg7 <= Num0;         //正确率十位 0
        seg8 <= Num0;         //正确率个位 0
    end

        else begin
             mode3_tens <= ((mode3_correct_amount * 100) / mode3_amount) / 10;  // 十位
             mode3_ones <= ((mode3_correct_amount * 100) / mode3_amount) % 10;  // 个位
             seg1 <= Num3; // 显示 "3"
             seg2 <= Blank;         //不显示
             seg3 <= digit_to_seg2(mode3_amount /10);      //题目数量的十位
             seg4 <= digit_to_seg2(mode3_amount % 10);     //题目数量的个位
             seg5 <= Blank;         //不显示
             seg6 <= Blank;          //正确率百位 0
             seg7  <= digit_to_seg2(mode3_tens);
             seg8 <= digit_to_seg2 (mode3_ones);
        end
  end  
    DM4:begin
  if(mode4_amount == mode4_correct_amount &&  mode4_amount != 0)begin
        seg1 <= Num4; // 显示 "4"
        seg2 <= Blank;         //不显示
        seg3 <= digit_to_seg2(mode4_amount /10);      //题目数量的十位
        seg4 <= digit_to_seg2(mode4_amount % 10);     //题目数量的个位
        seg5 <= Blank;         //不显示
        seg6 <= Num1;         //正确率百位 1
        seg7 <= Num0;         //正确率十位 0
        seg8 <= Num0;         //正确率个位 0
    end

        else begin
            mode4_tens <= ((mode4_correct_amount * 100) / mode4_amount) / 10;  // 十位
             mode4_ones <= ((mode4_correct_amount * 100) / mode4_amount) % 10;  // 个位
             seg1 <= Num4; // 显示 "4"
             seg2 <= Blank;         //不显示
             seg3 <= digit_to_seg2(mode4_amount /10);      //题目数量的十位
             seg4 <= digit_to_seg2(mode4_amount % 10);     //题目数量的个位
             seg5 <= Blank;         //不显示
             seg6 <= Blank;          //正确率百位 1
             seg7  <= digit_to_seg2(mode4_tens);
             seg8 <= digit_to_seg2 (mode4_ones);
        end
 end   
    DM5: begin
   if(mode5_amount == mode5_correct_amount &&  mode5_amount != 0 )begin
        seg1 <= Num5; // 显示 "5"
        seg2 <= Blank;         //不显示
        seg3 <= digit_to_seg2(mode5_amount /10);      //题目数量的十位
        seg4 <= digit_to_seg2(mode5_amount % 10);     //题目数量的个位
        seg5 <= Blank;         //不显示
        seg6 <= Num1;         //正确率百位 1
        seg7 <= Num0;         //正确率十位 0
        seg8 <= Num0;         //正确率个位 0
    end

        else begin
            mode5_tens <= ((mode5_correct_amount * 100) / mode5_amount) / 10;  // 十位
             mode5_ones <= ((mode5_correct_amount * 100) / mode5_amount) % 10;  // 个位
             seg1 <= Num5; // 显示 "5"
             seg2 <= Blank;         //不显示
             seg3 <= digit_to_seg2(mode5_amount /10);      //题目数量的十位
             seg4 <= digit_to_seg2(mode5_amount % 10);     //题目数量的个位
             seg5 <= Blank;         //不显示
             seg6 <= Blank;          //正确率百位 1
             seg7  <= digit_to_seg2(mode5_tens);
             seg8 <= digit_to_seg2 (mode5_ones);
        end   
end
endcase
  end 

  else begin
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
       
      
         case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4）//疑问：对于第一种只有一种数运算符的类型怎么确定运算符
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
        case (mode)//同时让seg1不要关闭
                M1: seg1 <= Num1; 
                M2: seg1 <= Num2; 
                M3: seg1 <= Num3; 
                M4: seg1 <= Num4; 
                M5: seg1 <= Num5; 
                default: seg1 <= Blank;
        endcase
        seg3 <=Blank;
        seg4 <=Blank;
      
    end
    Step2: begin
         case (op)
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
        case (mode)
                M1: seg1 <= Num1; 
                M2: seg1 <= Num2; 
                M3: seg1 <= Num3; 
                M4: seg1 <= Num4; 
                M5: seg1 <= Num5; 
                default: seg1 <= Blank; // 默认值以防未定义操作
        endcase
        seg3 <= Numa;//这个数码管输出是a，提示输入a
        seg4 <= Blank;//b此时不出现
        a<=in;//存储a
    end
    Step3: begin
         case (op)
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
        case (mode)
                M1: seg1 <= Num1; 
                M2: seg1 <= Num2; 
                M3: seg1 <= Num3; 
                M4: seg1 <= Num4; 
                M5: seg1 <= Num5; 
                default: seg1 <= Blank; 
        endcase
        seg3 <= Numa;
        seg4 <= Numb;//这个数码管输出是b，提示输入a
        b<=in;
    end
    Step4: begin//存储答案
        case (mode) //五种运算类型分别操作
            M1: begin
            convert_binary_answer(a);//存储正确答案
            seg3 <= Numr;//显示r，提示输入用户结果(按顺序)
            seg7 <= digit_to_seg1(counter_a);
            end
            M2: begin
                case (op)
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
            signed_operation_answer(a,b,op);
            seg5 <= Numr;//显示r，提示输入用户结果(按顺序)
            seg7 <= digit_to_seg1(counter_b);
            end
            M3: begin
                case (op)
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
            seg5 <= Numr;//显示r，提示输入用户结果(按顺序)
            shift_operation_answer(a,b,op);
            end
            M4: begin
                case (op)
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; 
            endcase
            seg5 <= Numr;//显示r，提示输入用户结果(按顺序)
            bitwise_operation_answer(a,b,op);
            end
            M5: begin
                case (op)
                OP1: seg2 <= Num1; 
                OP2: seg2 <= Num2; 
                OP3: seg2 <= Num3; 
                OP4: seg2 <= Num4; 
                default: seg2 <= Blank; // 默认值以防未定义操作
            endcase
            seg5 <= Numr;//显示r，提示输入用户结果(按顺序)
            logic_operation_answer(a,b,op); 

        end
        endcase
        end
     Step5:
     if(confirm&&delay_trigger) begin
        seg7 <= Blank;
      case (mode)
        M1:begin
         if (user_input_mode1[0] == mode1_answer[0] &&user_input_mode1[1] == mode1_answer[1] && user_input_mode1[2] == mode1_answer[2] && user_input_mode1[3] == mode1_answer[3] && user_input_mode1[4] == mode1_answer[4] && user_input_mode1[5] == mode1_answer[5] && user_input_mode1[6] == mode1_answer[6] && user_input_mode1[7] == mode1_answer[7] ) begin
             answer_result <= 1'b1;
             correct <=2'b01;
            mode1_amount <= mode1_amount + 1;
            mode1_correct_amount   <= mode1_correct_amount + 1;
          end
         else begin
          answer_result <= 1'b0;
          correct <=2'b10;
          mode1_amount <= mode1_amount + 1;
           end
end     
        M2:begin
            
        if (user_input_mode2[0]== mode2_answer[0] &&user_input_mode2[1]== mode2_answer[1] && user_input_mode2[2]== mode2_answer[2] && user_input_mode2[3]== mode2_answer[3] ) begin
            answer_result <= 1'b0;
            correct <=2'b10;
            mode2_amount <= mode2_amount + 1;
            mode2_correct_amount   <= mode2_correct_amount + 1;
        end
           else begin
            correct <=2'b01;
                answer_result <= 1'b1;
                mode2_amount <= mode2_amount + 1;
           end
        end  

        M3:begin
          
            if(user_input_mode3 != mode3_answer )begin
                answer_result <= 1'b0;
                mode3_amount <= mode3_amount + 1;
               correct <=2'b01;
            end
            else begin
            answer_result <= 1'b1;
            correct <=2'b10;
            mode3_amount <= mode3_amount + 1;
            mode3_correct_amount   <= mode3_correct_amount + 1;
           end
    end  
         M4:begin
            if(user_input_mode4 != mode4_answer)begin
               answer_result <= 1'b0;
               correct <=2'b01;
               mode4_amount <= mode4_amount + 1;
            end
            else 
                 begin
                    correct <=2'b10;
                     answer_result <= 1'b1;
                      mode4_amount <= mode4_amount + 1;
                      mode4_correct_amount   <= mode4_correct_amount + 1;
            end
        end
         M5:begin
            if(user_input_mode4 != mode4_answer)begin
                answer_result <= 1'b0;
                correct <=2'b01;
                mode5_amount <= mode5_amount + 1;
            end
            else 
                 begin
                correct <=2'b10;
                answer_result <= 1'b1;
                mode5_amount <= mode5_amount + 1;
               mode5_correct_amount <= mode5_correct_amount + 1;
            end
        end
    endcase
end
    Step6: begin
<<<<<<< HEAD
          correct<=2'b00;
=======
    correct<=2'b00;
>>>>>>> dcd3df4c8cc23d7c64197c05bd230f1f12a4ef28
          case (answer_result)
        1'b0 : 
         seg8 <= NumE;

        1'b1:
         seg8<= NumA;       
        endcase  
    end
   endcase
     end
endcase
end
     end
end

//下面是六个task，对应五个运算类型和一个数码管显示逻辑s
task convert_binary_answer;//存储正确答案
    input [7:0] bin_value; // 输入的二进制值
    begin 
        // 八进制转换逻辑
         mode1_answer[0] = bin_value / 64;  
         mode1_answer[1] =(bin_value / 8) % 8; 
         mode1_answer[2] = bin_value % 8;  

        // 十进制转换逻辑
        mode1_answer[3] = bin_value / 100;  // 百位拼接
         mode1_answer[4] =(bin_value / 10) % 10;  // 十位拼接
        mode1_answer[5]   = bin_value % 10;  // 个位拼接

        // 十六进制转换逻辑
        mode1_answer[6] = bin_value[7:4];  // 十六进制高四位拼接
        mode1_answer[7]  = bin_value[3:0];  // 十六进制低四位拼接

    end
endtask



task signed_operation_answer;
    input [7:0] a;           // 输入的有符号补码数 a
    input [7:0] b;           // 输入的有符号补码数 b
    input [3:0] op;          // 选择计算模式
    

    reg [7:0] result;   // 修改结果为 9 位签名数
    reg [7:0] abs_result; 
    reg sign;                    // sign是符号位
    reg [3:0] hundreds, tens, ones; // 改为 4 位以处理数字

begin
    abs_result = Blank;
    // 计算结果
    case(op)
        OP1: begin
            result = a + b; // 加法
            sign = result[7]; // 获取符号位
            abs_result[6:0] = (sign) ? ~result[6:0] : result[6:0]; // 计算绝对值，注意 abs_result 范围
            if (((a[7] == 0) && (b[7] == 0) && (result[7] == 1)) || // 正 + 正 -> 负
                ((a[7] == 1) && (b[7] == 1) && (result[7] == 0))) begin // 负 + 负 -> 正
                sign = ~sign;
                abs_result = ~result+1;
        end
        end
        OP2: begin
            result = a - b; // 减法
            sign = result[7]; // 获取符号位
            abs_result[6:0] = (sign) ? ~result[6:0] : result[6:0]; // 计算绝对值，注意 abs_result 范围
            if (((a[7] == 0) && (b[7] == 1) && (result[7] == 1)) || // 正 + 正 -> 负
                ((a[7] == 1) && (b[7] == 0) && (result[7] == 0))) begin // 负 + 负 -> 正
                sign = ~sign;
                abs_result = ~result+1;
        end
        end
        default: result = Blank; // 默认情况
    endcase

    // 数字分拆
    abs_result=abs_result%256;
    if(abs_result>127)begin
        abs_result=abs_result-256;
    end

    hundreds = abs_result / 100;        
    tens = (abs_result / 10) % 10;     
    ones = abs_result % 10;              

    mode2_answer[1] = hundreds;
    mode2_answer[2] = tens;
    mode2_answer[3] = ones;
    

    // 符号位作为千位
    if (sign) begin
        mode2_answer[0] = 8'b0000_0001;
    end else begin
        mode2_answer[0] = Blank; 
    end

   


end
endtask


task shift_operation_answer;
    input signed [7:0] a;    // 输入的 8 位有符号数（算术移位用）
    input [7:0] b;           // 输入的无符号数，表示移位的位数（范围 0~7）
    input [3:0] op;          // 选择模式
   
    reg [7:0] result; 

begin
    // 根据操作代码进行相应的位移操作
    case(op)
        OP1: result = a <<< b;  // 算术左移
        OP2: result = a >>> b;  // 算术右移
        OP3: result = a << b;   // 逻辑左移
        OP4: result = a >> b;   // 逻辑右移
        default: result = Blank; // 默认值
    endcase
     mode3_answer = result;
end
endtask

task bitwise_operation_answer;
    input [7:0] op_a;     // 任务输入a
    input [7:0] op_b;     // 任务输入b
    input [3:0] operation; // 操作码
    
    
    reg [7:0] output_result; // 操作结果

    begin
        case (operation)
            OP1: output_result = op_a & op_b;  // 与操作
            OP2: output_result = op_a | op_b;  // 或操作
            OP3: output_result = ~op_a;        // 非操作
            OP4: output_result = op_a ^ op_b;  // 异或操作
            default: output_result = Blank;         // 默认情况
        endcase

       mode4_answer = output_result;
    end
endtask

task logic_operation_answer;
    input [7:0] op_a;       // 任务输入a
    input [7:0] op_b;       // 任务输入b
    input [3:0] operation;   // 操作码

     reg [7:0] output_result; // 操作结果

    begin
        case (operation)
            OP1: output_result = {8{(op_a != 0) && (op_b != 0)}}; // 逻辑与操作
            OP2: output_result = {8{(op_a != 0) || (op_b != 0)}}; // 逻辑或操作
            OP3: output_result = {8{!(op_a != 0)}};               // 逻辑非操作
            OP4: output_result = {8{(op_a != 0) ^ (op_b != 0)}}; // 逻辑异或操作
            default: output_result = Blank;                          // 默认情况
        endcase
           mode5_answer =   output_result;
    end
endtask

endmodule