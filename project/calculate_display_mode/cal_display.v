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
    reg [7:0] seg2, seg3, seg4;
    reg [7:0] seg6, seg7, seg8;

    // 当前显示的数码管索引
    reg [2:0] current_digit = 0;   
    reg [20:0] counter1 ; 

    // 按钮延时控制
    reg delay_trigger = 0;  
    reg is_confirm = 1'b0;

    // 数码管的显示码
    parameter Num0 = 8'b1111_1100; // "0"
    parameter Num1 = 8'b0110_0000; // "1"
    parameter Blank = 8'b0000_0000; // 空白
    
    // 数字转7段显示编码的函数
    function [7:0] digit_to_seg;
        input [3:0] digit; 
        begin
            case (digit)
                4'd0: digit_to_seg = Num0; // 显示 "0"
                4'd1: digit_to_seg = Num1; // 显示 "1"
                default: digit_to_seg = Blank; // 空白
            endcase
        end
    endfunction
    
    // 将输入数转化为显示信号（只需要一个 always 块来处理）
    always @(in1, in2) begin
        seg2 = digit_to_seg(in1[2]);
        seg3 = digit_to_seg(in1[1]);
        seg4 = digit_to_seg(in1[0]);
        
        seg6 = digit_to_seg(in2[2]);
        seg7 = digit_to_seg(in2[1]);
        seg8 = digit_to_seg(in2[0]);
    end
    
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
    
    // 按钮确认处理逻辑
    always @(posedge clk) begin
        if (delay_trigger && confirm) begin
            case(is_confirm)
                1'b0: is_confirm = 1'b1;
                1'b1: begin 
                    is_confirm = 1'b0;
                    store = S0;
                end
                default: is_confirm = 1'b0;
            endcase
        end
    end
    
    // 状态机
    parameter S0 = 2'b00;
    parameter S1 = 2'b01;
    parameter S2 = 2'b10;
    parameter S3 = 2'b11;
    
    reg [7:0] result;
    reg [1:0] store = S0;
    
    always @(posedge clk) begin
        if (is_confirm) begin
            case(store)
                S1: begin 
                    result <= result + in1 * in2[0];
                    leds <= result;
                end
                S2: begin
                    result <= result + in1 * in2[1];
                    leds <= result;
                end
                S3: begin
                    result <= result + in1 * in2[2];
                    leds <= result;
                end
                S0: begin
                    result <= 0;
                    leds <= result;
                end
                default: store <= store;
            endcase
        end
    end
    
    // 状态机定时器
    localparam MAX_COUNT = 300_000_000;
    reg [28:0] cnt;
    always @(posedge clk) begin
        if (is_confirm) begin
            if (cnt < MAX_COUNT - 1) begin
                cnt <= cnt + 1;
            end else begin
                cnt <= 0;  // 重置计数器 
                case(store)
                    S0: begin
                        store <= S1;
                        cnt <= MAX_COUNT - 10;
                    end
                    S1: begin
                        store <= S2;
                    end
                    S2: begin
                        store <= S3;
                    end
                    S3: begin
                    end
                    default: store <= S0;
                endcase
            end
        end
    end

    // 显示扫描任务
    reg [7:0] seg1_tmp, seg2_tmp;
        
    // 将显示信号传递给实际的输出
    always @(posedge clk) begin
        display_scan(seg2, seg3, seg4, seg6, seg7, seg8, current_digit, anode, seg1_tmp, seg2_tmp);
        Seg1 <= seg1_tmp;
        Seg2 <= seg2_tmp;
    end

    // 显示扫描的任务函数
    task display_scan;
        input [7:0] data2;
        input [7:0] data3;
        input [7:0] data4;
        input [7:0] data6;
        input [7:0] data7;
        input [7:0] data8;
        input [2:0] current_digit;   // 当前显示的数码管索引 (0-7)
        output reg [7:0] anode;       // 数码管使能信号（动态扫描）
        output reg [7:0] seg1;        // 第一组数码管的显示内容
        output reg [7:0] seg2;        // 第二组数码管的显示内容
    begin
        // 初始化使能信号，关闭所有数码管
        anode = 8'b0000_0000;         
        anode[current_digit] = 1;     // 使能当前数字所在的数码管
        
        // 根据当前数码管索引选择显示的数据
        case (current_digit)
            3'd1: seg1 = data2;    // 显示 data2
            3'd2: seg1 = data3;    // 显示 data3
            3'd3: seg1 = data4;    // 显示 data4
            3'd5: seg2 = data6;    // 显示 data6
            3'd6: seg2 = data7;    // 显示 data7
            3'd7: seg2 = data8;    // 显示 data8
            default: begin
                seg1 = 8'b1111_1111;   // 默认不显示内容
                seg2 = 8'b1111_1111;
            end
        endcase
    end
    endtask

endmodule
