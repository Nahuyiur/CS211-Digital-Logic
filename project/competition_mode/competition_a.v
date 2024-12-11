module  competition_a(
    input clk,
    input reset,
    input confirm,
    input select,
    input exit, 
    input [7:0] in,
    


    output reg[7:0] Seg1,        
    output reg[7:0] Seg2,        
    output reg[7:0] anode , 
  
);

reg [3:0] op = 4'b0001; 

reg total = 1'b0;    //赛题总数


reg[22:0] mode_question [49:0]; // 模式1:前5位是模式，两位表示进制选择(00 b 01 o 10 h)，后八位输入的数据，最后八位全是零
                                //  模式2：前5位是模式，两位表示运算符选择（00 +  11 -），后十六位是ab
                                //  模式3：前5位是模式，两位表示运算选择（00，01，10，11 分别对应1234），后十六位是ab
                                //  模式4：前5位是模式，两位表示运算选择（00，01，10，11 分别对应1234），后十六位是ab
                                // 模式 5：前5位是模式，两位表示运算选择（00，01，10，11 分别对应1234），后十六位是ab 



reg [2:0] store = 3'b0; 
reg [2:0] current_digit = 0; 
reg [20:0] counter1 = 0; 
reg mode_entered = 0;
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
    if(confirm&&delay_trigger) begin//注意判断条件有delay_trigger=1
        mode_entered <= 1;            
    end 
    if(exit&&delay_trigger) begin
        mode_entered <= 0;       
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

// 该模块用于二元运算的操作步骤切换，点击select按钮切换步骤store，切换顺序为：000，001，010，100，111
//000清零之前的运算，001提示输入a并时刻显示和存储a,010提示输入b并时刻显示和存储b
//请把store的四个值参数化
always @(posedge clk) begin
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

always @(posedge clk) begin
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
                 mode_question[total][22:18] <= 5'b00001;
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
                 mode_question[total][22:18] <= 5'b00010;
                 mode_question[total][15:8]  <= in;
                 total <= total + 1'b1;

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
                 mode_question[total][22:18] <= 5'b00100;
                 mode_question[total][15:8]  <= in;
            
                 total <= total + 1'b1;

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
                 mode_question[total][22:18] <= 5'b01000;
                 mode_question[total][15:8]  <= in;
           
                 total <= total + 1'b1;

            end

            5'b00001:begin
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
                 mode_question[total][22:18] <= 5'b10000;
                 mode_question[total][15:8]  <= in;
           
                 total <= total + 1'b1;

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
                
            end

            5'b00001:begin
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
                 mode_question[total][7:0]  <= in;
               

            end
        endcase
        
      
    end

      





    
    endcase
end
endcase
display_scan1(seg1,seg2,seg3,seg4,seg5,seg6,seg7,seg8,anode,Seg1,Seg2);

end






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