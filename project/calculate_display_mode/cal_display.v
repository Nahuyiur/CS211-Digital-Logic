module cal_display (
    input clk,               // 时钟输入
    input confirm,
    input exit,
    input [2:0] in1,         // 输入的第一个3位无符号数
    input [2:0] in2,         // 输入的第二个3位无符号数
    
    output reg [7:0] Seg2,
    output reg [7:0] Seg1,
    output reg [7:0] anode,
    output reg [7:0] leds // LED输出
);
    // 数码管的显示内容寄存器
    reg [7:0] seg1 = 8'b0;
    reg [7:0] seg2 = 8'b0;
    reg [7:0] seg3 = 8'b0;
    reg [7:0] seg4 = 8'b0;
    reg [7:0] seg5 = 8'b0;
    reg [7:0] seg6 = 8'b0;
    reg [7:0] seg7 = 8'b0;
    reg [7:0] seg8 = 8'b0;
    
    

    // 当前显示的数码管索引
    reg [2:0] current_digit = 0;   
    reg [20:0] counter1 ; 
    
       // 用于数码管扫描显示
     always @(posedge clk) begin
         counter1 <= counter1 + 1;
         if (counter1 == 10000) begin // 每 1 ms 触发一次 (100 MHz 时钟)
             counter1 <= 0;
             current_digit <= current_digit + 1; // 切换到下一个数码管
             if (current_digit == 7)
                 current_digit <= 0; // 循环激活数码管
         end
     end
        parameter S0 = 2'b00;
        parameter S1 = 2'b01;
        parameter S2 = 2'b10;
        parameter S3 = 2'b11;
    // 按钮延时控制

    reg [7:0] result;
    reg [1:0] store = S0;
    // 数码管的显示码
    parameter Num0 = 8'b1111_1100; // "0"
    parameter Num1 = 8'b0110_0000; // "1"
    parameter Blank = 8'b0000_0000; // 空白
    
    // 数字转7段显示编码的函数
    function [7:0] digit_to_seg;
            input digit; 
        begin
            case (digit)
                0: digit_to_seg = Num0; // 显示 "0"
                1: digit_to_seg = Num1; // 显示 "1"
                default: digit_to_seg = Blank; // 空白
            endcase
        end
    endfunction
    
    // 按钮按下时间控制
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
        localparam CLK_FREQ2 = 300000000; // 假设时钟频率为 50MHz
        localparam DELAY_COUNT2 = CLK_FREQ2 / 2; // 0.5秒延迟的计数值
        
        always @(posedge clk) begin
            if (counter2 < DELAY_COUNT2 - 1) begin
                counter2 <= counter2 + 1;
                delay_trigger2 <= 0;
            end else begin
                counter2 <= 0;
                delay_trigger2 <= 1; // 触发信号
            end
        end
    
    
    reg is_confirm = 0;
   

    always @(posedge clk) begin
        case(is_confirm)
            0:begin
                if(confirm&delay_trigger) begin
                    is_confirm<=1;
                end
                end
            1:begin
                if(delay_trigger2) begin
                case(store)
                S0: begin
                    is_confirm<=0; 
                    result<=8'b0;
                    leds <= result;
                    store <= S1;
                    end
                S1: begin
                    result <= result + in1 * in2[0];
                    leds <= result;
                    store <= S2;
                    end
                S2: begin
                    result <= result + in1 * in2[1];
                    leds <= result;
                    store <= S3;
                    end
                S3: begin
                    result <= result + in1 * in2[2];
                    leds <= result;               
                    store <= S0;
                    end
            endcase
                end
        end
    endcase
        end
   
        
    // 将显示信号传递给实际的输出
    always @(posedge clk) begin
        seg1 = 8'b00000000;
        seg2 = digit_to_seg(in1[2]);
        seg3 = digit_to_seg(in1[1]);
        seg4 = digit_to_seg(in1[0]);
        seg5 = 8'b00000000;
        seg6 = digit_to_seg(in2[2]);
        seg7 = digit_to_seg(in2[1]);
        seg8 = digit_to_seg(in2[0]);
        display_scan(seg1,seg2, seg3, seg4, seg5,seg6, seg7, seg8, anode, Seg1, Seg2);
    end

    // 显示扫描的任务函数
   task display_scan;
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
            endcase
        end
    endtask

endmodule
