module display (
    input [3:0] enter,
    input clk,               // 时钟输入
    input reset,  
    input confirm,
    input exit,
    input [2:0] in1,         // 输入的第一个3位无符号数
    input [2:0] in2,         // 输入的第二个3位无符号数
    output reg type_entered,
    output reg [7:0] seg1,
    output reg [7:0] seg2,
    output reg [7:0] seg3,
    output reg [7:0] seg4,
    output reg [7:0] seg5,
    output reg [7:0] seg6,
    output reg [7:0] seg7,
    output reg [7:0] seg8,
    output reg [7:0] leds // LED输出
);

    // 当前显示的数码管索引
    reg [2:0] current_digit = 0;   
    reg [20:0] counter1 ; 
    
    // 用于数码管扫描显示
    localparam SCAN_DELAY = 10000;
     always @(posedge clk) begin
         counter1 <= counter1 + 1;
         if (counter1 == SCAN_DELAY) begin // 每 1 ms 触发一次 (100 MHz 时钟)
             counter1 <= 0;
             current_digit <= current_digit + 1; // 切换到下一个数码管
             if (current_digit == 7)
                 current_digit <= 0; // 循环激活数码管
         end
     end

    //参数化表示4个计算演示的显示阶段
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

    always @(posedge clk) begin
        if(enter==4'b1000) begin
        if (exit) begin
            type_entered=0;
        end 
        if (confirm&&delay_trigger) begin
            type_entered=1;
        end
        end
    end
    
    
    reg is_confirm = 0;//是否确定计算结果

    always @(posedge clk) begin
        if(enter==4'b1000) begin
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
                    result <= result + in1 * in2[1]*2;
                    leds <= result;
                    store <= S3;
                    end
                S3: begin
                    result <= result + in1 * in2[2]*4;
                    leds <= result;               
                    store <= S0;
                    end
            endcase
                end
        end
        endcase
        end
        if(~type_entered) begin
            leds<=8'b0;
        end
        end
   
        
    // 将显示信号传递给实际的输出
    always @(posedge clk) begin
        if(enter==4'b1000) begin
        if(type_entered==1) begin
        seg1 = Blank;
        seg2 = digit_to_seg(in1[2]);
        seg3 = digit_to_seg(in1[1]);
        seg4 = digit_to_seg(in1[0]);
        seg5 = Blank;
        seg6 = digit_to_seg(in2[2]);
        seg7 = digit_to_seg(in2[1]);
        seg8 = digit_to_seg(in2[0]);
        end
        else begin
        seg2 =  Blank;
        seg3 =  Blank;
        seg4 =  Blank;
        seg5 =  Blank;
        seg6 =  Blank;
        seg7 =  Blank;
        seg8 =  Blank;
        end
        end
    end

endmodule
