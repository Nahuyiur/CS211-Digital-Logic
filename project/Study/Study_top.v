`timescale 1ns / 1ps

module Study_top(
    input clk,                // 时钟信号
    input reset,              // 复位信号
    input confirm,            // 确定操作的按钮
    input exit,               // 退出按钮
    input select,             // 切换按钮   
    input data,
    input [7:0] in,  
    output reg[1:0] result,//判断对错
   
  

    output reg[7:0] Seg1,        // 前四个数码管
    output reg[7:0] Seg2,        // 后四个数码管
    output reg[7:0] anode       // 数码管使能信号（动态扫描）
);
  
//加一个状态按下按钮之后，将显示学情改为1
   reg data_state = 0;
   reg[4:0] data_mode_state  = 5'b00001;//这个用于学情显示下的模式，并不代表真正的模式
  
   reg [7:0] user_input_mode1 [7:0]; //存储模式1下用户输入的八个数据
   reg [7:0] user_input_mode2  ; //存储模式2下用户输入的四个数据
   reg [7:0] user_input_mode3 = 8'b0; 
   reg [7:0] user_input_mode4 = 8'b0;
   reg [7:0] user_input_mode5 = 8'b0;   



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
reg [2:0] store = 3'b0;           // 存储状态,000为未操作，001为存储a,010为存储b,100为输出结果 111（未修改）
reg [7:0] a = 8'b0;               // 运算数 a
reg [7:0] b = 8'b0;               // 运算数 b
reg mode_entered = 0;          // 0为未进入模式，1为已进入模式

reg [2:0] counter_a = 3'b000; 
reg [2:0] counter_b = 3'b000; 




//下面两行的计数器用来控制按下按钮的时间
localparam CLK_FREQ = 50000000; // 假设时钟频率为 50MHz
localparam DELAY_COUNT = CLK_FREQ / 2; // 0.5秒延迟的计数值

//下面四行的reg服务于task scan-display:
reg [24:0] counter = 0; // 计数器，足够容纳 25M 的值
reg delay_trigger = 0;  // 触发信号

c 

// 实例化6个子模块（都没有用）


//下面的两个function用于把十进制整数（四位）转成数码管输出信号
function [7:0] digit_to_seg1;  // 输出 8 位（包括 dp）
    input [3:0] digit;        // 输入 4 位数字（支持 0-9 和 A-F）
    begin
        case (digit)
            4'd0: digit_to_seg1 = 8'b1111_1100; // 显示 "0"
            4'd1: digit_to_seg1 = 8'b0110_0000; // 显示 "1"
            4'd2: digit_to_seg1 = 8'b1101_1010; // 显示 "2"
            4'd3: digit_to_seg1 = 8'b1111_0010; // 显示 "3"
            4'd4: digit_to_seg1 = 8'b0110_0110; // 显示 "4"
            4'd5: digit_to_seg1 = 8'b1011_0110; // 显示 "5"
            4'd6: digit_to_seg1 = 8'b1011_1110; // 显示 "6"
            4'd7: digit_to_seg1 = 8'b1110_0000; // 显示 "7"
            4'd8: digit_to_seg1 = 8'b1111_1110; // 显示 "8"
            4'd9: digit_to_seg1 = 8'b1111_0110; // 显示 "9"
            4'd10: digit_to_seg1 = 8'b1110_1110; // 显示 "A" -> abc_defg_
            4'd11: digit_to_seg1 = 8'b0011_1110; // 显示 "B" -> _bcdefg_
            4'd12: digit_to_seg1 = 8'b1001_1001; // 显示 "C" -> a_def___
            4'd13: digit_to_seg1 = 8'b0111_1010; // 显示 "D" -> _bc_defg_
            4'd14: digit_to_seg1 = 8'b1001_1110; // 显示 "E" -> a_defg__
            4'd15: digit_to_seg1 = 8'b1000_1110; // 显示 "F" -> a_defg___
            default: digit_to_seg1 = 8'b0000_0000; // 空白
        endcase
    end
endfunction

//这个function和上一个function的区别是没有10-15，不会出现十六进制的转换（比如10不会被转成A）
function [7:0] digit_to_seg2;  // 输出 8 位（包括 dp）
    input [3:0] digit;        // 输入 4 位数字（支持 0-9 和 A-F）
    begin
        case (digit)
            4'd0: digit_to_seg2 = 8'b1111_1100; // 显示 "0"
            4'd1: digit_to_seg2 = 8'b0110_0000; // 显示 "1"
            4'd2: digit_to_seg2 = 8'b1101_1010; // 显示 "2"
            4'd3: digit_to_seg2 = 8'b1111_0010; // 显示 "3"
            4'd4: digit_to_seg2 = 8'b0110_0110; // 显示 "4"
            4'd5: digit_to_seg2 = 8'b1011_0110; // 显示 "5"
            4'd6: digit_to_seg2 = 8'b1011_1110; // 显示 "6"
            4'd7: digit_to_seg2 = 8'b1110_0000; // 显示 "7"
            4'd8: digit_to_seg2 = 8'b1111_1110; // 显示 "8"
            4'd9: digit_to_seg2 = 8'b1111_0110; // 显示 "9"
            default: digit_to_seg2 = 8'b0000_0000; // 空白
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
    if(confirm&&delay_trigger) begin//注意判断条件有delay_trigger=1
        mode_entered <= 1;            
    end 
    if(exit&&delay_trigger) begin
        mode_entered <= 0;       
    end 
end


//按下data键进入学情查看，data_state变为1，再次按下退出，data_state变为0
always @(posedge clk) begin
    if(data&&delay_trigger) begin//注意判断条件有delay_trigger=1
       data_state <= ~data_state;           
    end 
end




//学情的数码管显示
//进入学情查看后的切换模式，查看相应的题目数量的正确率
always @(posedge clk) begin
    if(data_state) begin
    if (select  && delay_trigger) begin
        case (data_mode_state)//非真实选择
            5'b00001: data_mode_state <= 5'b00010;
            5'b00010: data_mode_state <= 5'b00100;
            5'b00100: data_mode_state <= 5'b01000;
            5'b01000: data_mode_state <= 5'b10000;
            5'b10000: data_mode_state <= 5'b00001;
        endcase
    end
   end
   



end












// 该模块用于运算类型切换，点击select按钮切换模式mode，切换顺序为：00001，00010，00100，01000，10000，00001，
//请把mode的五个值参数化

always @(posedge clk) begin
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

// 该模块用于二元运算的操作步骤切换，点击select按钮切换步骤store，切换顺序为：000，001，010，100，111
//000清零之前的运算，001提示输入a并时刻显示和存储a,010提示输入b并时刻显示和存储b,100提示用户输入答案并存储答案 ，111显示最终结果对错
//请把store的四个值参数化
always @(posedge clk) begin
    if(mode_entered&&delay_trigger&&~data_state)begin
    if (confirm) begin
        case (store)
            3'b000: begin
            store <=3'b001;
          
         end   
            3'b001: begin
                if(mode==5'b00001)begin
                store <=3'b100;

            end
            else begin
                store <=3'b010;
            end
            end

            3'b010: store <=3'b100;


            3'b100: begin
            if(mode==5'b00001)begin
               
                
            if (counter_a < 7) begin  
                user_input_mode1[counter_a] <= in; 
                counter_a <= counter_a + 1;

                      
            end 
            else  begin
              store <=3'b111;
              counter_a <= 3'b0;
           
         end

        end

        if(mode==5'b00010)begin
           if (counter_b < 3) begin  
                user_input_mode1[counter_b] <= in; 
                counter_b <= counter_b + 1;

                      
            end 
            else  begin
              store <=3'b111;
              counter_b <= 3'b0;
           
         end       

              
         end
             if(mode==5'b00100) begin
               user_input_mode3 <= in;
               store <=3'b111;
 
            end
              if(mode==5'b01000) begin
               user_input_mode4 <= in;
               store <=3'b111;
                
            end
              if(mode==5'b10000) begin
               user_input_mode5 <= in;
               store <=3'b111;
                
            end
            end

            3'b111: store <= 3'b110;

            3'b110: store <= 3'b000; 

    endcase
    end
    end
end










always @(posedge clk) begin
   if(data_state == 1)begin




   case(data_mode_state) 
    5'b00001:begin
        if(mode1_amount == mode1_correct_amount &&  mode1_amount != 0)begin
        seg1 <= 8'b0110_0000;         // 显示为"1"
        seg2 <= 8'b0000_0000;         //不显示
        seg3 <= digit_to_seg2(mode1_amount /10);      //题目数量的十位
        seg4 <= digit_to_seg2(mode1_amount % 10);     //题目数量的个位
        seg5 <= 8'b0000_0000;         //不显示
        seg6 <= 8'b0110_0000;          //正确率百位 1
        seg7 <= 8'b1111_1100;         //正确率十位 0
        seg8 <= 8'b1111_1100;         //正确率个位 0
    end

        else begin
              mode1_tens <= ((mode1_correct_amount * 100) / mode1_amount) / 10;  // 十位
              mode1_ones <= ((mode1_correct_amount * 100) / mode1_amount) % 10;  // 个位
             seg1 <= 8'b0110_0000;         // 显示为"1"
             seg2 <= 8'b0000_0000;         //不显示
             seg3 <= digit_to_seg2(mode1_amount /10);      //题目数量的十位
             seg4 <= digit_to_seg2(mode1_amount % 10);     //题目数量的个位
             seg5 <= 8'b0000_0000;         //不显示
             seg6 <= 8'b0000_0000;          //正确率百位 0
             seg7 <= digit_to_seg1(mode1_tens);
             seg8 <= digit_to_seg1(mode1_ones);
        end
        
 end  
    
    
    5'b00010:begin
    if(mode2_amount == mode2_correct_amount &&  mode2_amount != 0 )begin
        seg1 <= 8'b1101_1010; // 显示 "2"
        seg2 <= 8'b0000_0000;         //不显示
        seg3 <= digit_to_seg2(mode2_amount /10);      //题目数量的十位
        seg4 <= digit_to_seg2(mode2_amount % 10);     //题目数量的个位
        seg5 <= 8'b0000_0000;         //不显示
        seg6 <= 8'b0110_0000;         //正确率百位 1
        seg7 <= 8'b1111_1100;         //正确率十位 0
        seg8 <= 8'b1111_1100;         //正确率个位 0
    end

        else begin
             mode2_tens <= ((mode2_correct_amount * 100) / mode2_amount) / 10;  // 十位
             mode2_ones <= ((mode2_correct_amount * 100) / mode2_amount) % 10;  // 个位
             seg1 <= 8'b0110_0000;         // 显示为"1"
             seg2 <= 8'b0000_0000;         //不显示
             seg3 <= digit_to_seg2(mode2_amount /10);      //题目数量的十位
             seg4 <= digit_to_seg2(mode2_amount % 10);     //题目数量的个位
             seg5 <= 8'b0000_0000;         //不显示
             seg6 <= 8'b0000_0000;          //正确率百位 1
             seg7  <= digit_to_seg2(mode2_tens);
             seg8 <= digit_to_seg2 (mode2_ones);
        end
end


    5'b00100:begin
    if(mode3_amount == mode3_correct_amount && mode3_amount != 0)begin
        seg1 <= 8'b1111_0010; // 显示 "3"
        seg2 <= 8'b0000_0000;         //不显示
        seg3 <= digit_to_seg2(mode3_amount /10);      //题目数量的十位
        seg4 <= digit_to_seg2(mode3_amount % 10);     //题目数量的个位
        seg5 <= 8'b0000_0000;         //不显示
        seg6 <= 8'b0110_0000;         //正确率百位 1
        seg7 <= 8'b1111_1100;         //正确率十位 0
        seg8 <= 8'b1111_1100;         //正确率个位 0
    end

        else begin
             mode3_tens <= ((mode3_correct_amount * 100) / mode3_amount) / 10;  // 十位
             mode3_ones <= ((mode3_correct_amount * 100) / mode3_amount) % 10;  // 个位
             seg1 <= 8'b1111_0010; // 显示 "3"
             seg2 <= 8'b0000_0000;         //不显示
             seg3 <= digit_to_seg2(mode3_amount /10);      //题目数量的十位
             seg4 <= digit_to_seg2(mode3_amount % 10);     //题目数量的个位
             seg5 <= 8'b0000_0000;         //不显示
             seg6 <= 8'b0000_0000;          //正确率百位 0
             seg7  <= digit_to_seg2(mode3_tens);
             seg8 <= digit_to_seg2 (mode3_ones);
        end
  end  
    5'b01000:begin
  if(mode4_amount == mode4_correct_amount &&  mode4_amount != 0)begin
        seg1 <= 8'b0110_0110; // 显示 "4"
        seg2 <= 8'b0000_0000;         //不显示
        seg3 <= digit_to_seg2(mode4_amount /10);      //题目数量的十位
        seg4 <= digit_to_seg2(mode4_amount % 10);     //题目数量的个位
        seg5 <= 8'b0000_0000;         //不显示
        seg6 <= 8'b0110_0000;         //正确率百位 1
        seg7 <= 8'b1111_1100;         //正确率十位 0
        seg8 <= 8'b1111_1100;         //正确率个位 0
    end

        else begin
            mode4_tens <= ((mode4_correct_amount * 100) / mode4_amount) / 10;  // 十位
             mode4_ones <= ((mode4_correct_amount * 100) / mode4_amount) % 10;  // 个位
             seg1 <= 8'b0110_0110; // 显示 "4"
             seg2 <= 8'b0000_0000;         //不显示
             seg3 <= digit_to_seg2(mode4_amount /10);      //题目数量的十位
             seg4 <= digit_to_seg2(mode4_amount % 10);     //题目数量的个位
             seg5 <= 8'b0000_0000;         //不显示
             seg6 <= 8'b0000_0000;          //正确率百位 1
             seg7  <= digit_to_seg2(mode4_tens);
             seg8 <= digit_to_seg2 (mode4_ones);
        end
 end   
    5'b10000: begin
   if(mode5_amount == mode5_correct_amount &&  mode5_amount != 0 )begin
        seg1 <= 8'b1011_0110; // 显示 "5"
        seg2 <= 8'b0000_0000;         //不显示
        seg3 <= digit_to_seg2(mode5_amount /10);      //题目数量的十位
        seg4 <= digit_to_seg2(mode5_amount % 10);     //题目数量的个位
        seg5 <= 8'b0000_0000;         //不显示
        seg6 <= 8'b0110_0000;         //正确率百位 1
        seg7 <= 8'b1111_1100;         //正确率十位 0
        seg8 <= 8'b1111_1100;         //正确率个位 0
    end

        else begin
            mode5_tens <= ((mode5_correct_amount * 100) / mode5_amount) / 10;  // 十位
             mode5_ones <= ((mode5_correct_amount * 100) / mode5_amount) % 10;  // 个位
             seg1 <= 8'b1011_0110; // 显示 "5"
             seg2 <= 8'b0000_0000;         //不显示
             seg3 <= digit_to_seg2(mode5_amount /10);      //题目数量的十位
             seg4 <= digit_to_seg2(mode5_amount % 10);     //题目数量的个位
             seg5 <= 8'b0000_0000;         //不显示
             seg6 <= 8'b0000_0000;          //正确率百位 1
             seg7  <= digit_to_seg2(mode5_tens);
             seg8 <= digit_to_seg2 (mode5_ones);
        end   
end
endcase
display_scan1(seg1,seg2,seg3,seg4,seg5,seg6,seg7,seg8,anode,Seg1,Seg2);  
  end  
  else begin
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
       
      
         case (op)//进入模式的时候seg2亮起，显示此时的运算符（1，2，3，4）//疑问：对于第一种只有一种数运算符的类型怎么确定运算符
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
        a<=in;//存储a
    end
    3'b010: begin
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
        b<=in;
    end
    3'b100: begin//存储答案
        case (mode) //五种运算类型分别操作
            5'b00001: begin
            convert_binary_answer(a);//存储正确答案
            seg3 <= 8'b10001100;//显示r，提示输入用户结果(按顺序)

            end
            5'b00010: begin
                case (op)
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; 
            endcase
            signed_operation_answer(a,b,op);
            seg5 <= 8'b10001100;//显示r，提示输入用户结果(按顺序)
            end
            5'b00100: begin
                case (op)
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; 
            endcase
            seg5 <= 8'b10001100;//显示r，提示输入用户结果(按顺序)
            shift_operation_answer(a,b,op);
            end
            5'b01000: begin
                case (op)
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; 
            endcase
            seg5 <= 8'b10001100;//显示r，提示输入用户结果(按顺序)
            bitwise_operation_answer(a,b,op);
            end
            5'b10000: begin
                case (op)
                4'b0001: seg2 <= 8'b0110_0000; 
                4'b0010: seg2 <= 8'b1101_1010; 
                4'b0100: seg2 <= 8'b1111_0010; 
                4'b1000: seg2 <= 8'b0110_0110; 
                default: seg2 <= 8'b0000_0000; // 默认值以防未定义操作
            endcase
            seg5 <= 8'b10001100;//显示r，提示输入用户结果(按顺序)
            logic_operation_answer(a,b,op); 

        end
        endcase
        end
     3'b111:begin//比较答案判断对错,同时学情数据
            case (mode)
        5'b00001:begin
         if (user_input_mode1[0] == mode1_answer[0] &&user_input_mode1[1] == mode1_answer[1] && user_input_mode1[2] == mode1_answer[2] && user_input_mode1[3] == mode1_answer[3] && user_input_mode1[4] == mode1_answer[4] && user_input_mode1[5] == mode1_answer[5] && user_input_mode1[6] == mode1_answer[6] && user_input_mode1[7] == mode1_answer[7] ) begin
             answer_result <= 1'b1;
            mode1_amount <= mode1_amount + 1;
            mode1_correct_amount   <= mode1_correct_amount + 1;
          end
         else begin
          answer_result <= 1'b0;
          mode1_amount <= mode1_amount + 1;
           end
end     
        5'b00010:begin
            
        if (user_input_mode2[0]== mode2_answer[0] &&user_input_mode2[1]== mode2_answer[1] && user_input_mode2[2]== mode2_answer[2] && user_input_mode2[3]== mode2_answer[3] ) begin
            answer_result <= 1'b0;
            mode2_amount <= mode2_amount + 1;
            mode2_correct_amount   <= mode2_correct_amount + 1;
        end
           else begin
                answer_result <= 1'b1;
                mode2_amount <= mode2_amount + 1;
           end
     
        
        end  

        5'b00100:begin
          
            if(user_input_mode3 != mode3_answer )begin
                answer_result <= 1'b0;
                mode3_amount <= mode3_amount + 1;
               
            end
            else begin
            answer_result <= 1'b1;
            mode3_amount <= mode3_amount + 1;
            mode3_correct_amount   <= mode3_correct_amount + 1;
           end
    end  
         5'b01000:begin
            if(user_input_mode4 != mode4_answer)begin
               answer_result <= 1'b0;
               mode4_amount <= mode4_amount + 1;
            end
            else 
                 begin
                     answer_result <= 1'b1;
                      mode4_amount <= mode4_amount + 1;
                      mode4_correct_amount   <= mode4_correct_amount + 1;
            end
        end
         5'b10000:begin
            if(user_input_mode4 != mode4_answer)begin
                answer_result <= 1'b0;
                mode5_amount <= mode5_amount + 1;
            end
            else 
                 begin
                answer_result <= 1'b1;
                mode5_amount <= mode5_amount + 1;
               mode5_correct_amount   <= mode5_correct_amount + 1;
            end
        end
      endcase



        end
    endcase
        end
    endcase
    display_scan1(seg1,seg2,seg3,seg4,seg5,seg6,seg7,seg8,anode,Seg1,Seg2);
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
        mode2_answer[0] = 8'b00000001;
    end else begin
        mode2_answer[0] = 8'b00000000; 
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
        4'b0001: result = a <<< b;  // 算术左移
        4'b0010: result = a >>> b;  // 算术右移
        4'b0100: result = a << b;   // 逻辑左移
        4'b1000: result = a >> b;   // 逻辑右移
        default: result = 8'b0000_0000; // 默认值
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
            4'b0001: output_result = op_a & op_b;  // 与操作
            4'b0010: output_result = op_a | op_b;  // 或操作
            4'b0100: output_result = ~op_a;        // 非操作
            4'b1000: output_result = op_a ^ op_b;  // 异或操作
            default: output_result = 8'b0;         // 默认情况
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
            4'b0001: output_result = {8{(op_a != 0) && (op_b != 0)}}; // 逻辑与操作
            4'b0010: output_result = {8{(op_a != 0) || (op_b != 0)}}; // 逻辑或操作
            4'b0100: output_result = {8{!(op_a != 0)}};               // 逻辑非操作
            4'b1000: output_result = {8{(op_a != 0) ^ (op_b != 0)}}; // 逻辑异或操作
            default: output_result = 8'b0;                          // 默认情况
        endcase
           mode5_answer =   output_result;
    end
endtask

task display_scan1;
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
                    seg1 = 8'b1111_1111;  
                    seg2 = 8'b1111_1111;
                end 
            endcase
        end
    endtask




endmodule