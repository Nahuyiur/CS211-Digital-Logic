module Power_top (
    input wire clk,                 // 时钟信号
    input wire reset,               // 复位信号
    input wire power_button,        // 电源按钮
    input confirm,                  // 进入退出模式的按钮
    input select,                   // 切换模式的按钮      
    input exit,
    input [7:0] in,                // 拨码开关的输入   
    output reg [7:0] Seg1,         // 前四个数码管
    output reg [7:0] Seg2,         // 后四个数码管
    output reg [7:0] leds,         // LED显示
    output reg [7:0] anode         // 数码管使能信号（动态扫描）
);

reg mode_entered=0;
reg [4:0] mode_sel=5'b00001;              // 模式选择信号
wire power_state;                // 电源模块的输出信号
reg [7:0] seg1= 8'b0;    
reg [7:0] seg2= 8'b0;     
reg [7:0] seg3= 8'b0;             
reg [7:0] seg4= 8'b0;
reg [7:0] seg5= 8'b0; 
reg [7:0] seg6= 8'b0;     
reg [7:0] seg7= 8'b0;             
reg [7:0] seg8= 8'b0;
wire [7:0] seg11;    
wire [7:0] seg12;     
wire [7:0] seg13;             
wire [7:0] seg14;
wire [7:0] seg15; 
wire [7:0] seg16;     
wire [7:0] seg17;             
wire [7:0] seg18;
wire [7:0] leds1;
wire type_entered;
// Counter和触发器相关的信号
reg [31:0] counter;              // 用于按钮按下的计数
reg delay_trigger;               // 触发信号
localparam CLK_FREQ = 50000000; // 假设时钟频率为 50MHz
localparam DELAY_COUNT = CLK_FREQ / 2; // 0.5秒延迟的计数值

// 实例化 cal_top
cal_top cal (
    .enter(mode_sel),
    .clk(clk),                // 时钟信号
    .reset(reset),            // 复位信号
    .confirm(confirm),        // 确定操作的按钮
    .exit(exit),              // 退出按钮, 假设我们先不使用它
    .select(select),          // 切换按钮   
    .in(in),                  // 拨码开关的输入   
    .seg1(seg11),
    .seg2(seg12),
    .seg3(seg13),
    .seg4(seg14),
    .seg5(seg15),
    .seg6(seg16),
    .seg7(seg17),
    .seg8(seg18),
    .leds(leds1),
    .type_entered(type_entered)
);

reg [2:0] current_digit = 0; 
reg [20:0] counter1 = 0;   
always @(posedge clk) begin//这个always服务于task：scan-display
        counter1 <= counter1 + 1;
        if (counter1 == 10000) begin // 每 1 ms 触发一次 (100 MHz 时钟)
            counter1 <= 0;
            current_digit <= current_digit + 1; // 切换到下一个数码管
            if (current_digit == 7)
                current_digit <= 0; // 循环激活数码管
        end
    end

always @(posedge clk) begin
    // 设置按钮按下的计数和触发：
    if (counter < DELAY_COUNT - 1) begin
        counter <= counter + 1;
        delay_trigger <= 0;
    end else begin
        counter <= 0;
        delay_trigger <= 1; // 触发信号
    end
end


always @(posedge clk) begin
    if(~type_entered) begin
    if (confirm && delay_trigger) begin
        mode_entered <= 1;            
    end 
    if (exit && delay_trigger) begin
        mode_entered <= 0;       
    end 
    end
end

parameter mode1 = 5'b00001;
parameter mode2 = 5'b00010;
parameter mode3 = 5'b00100;
parameter mode4 = 5'b01000;
parameter mode5 = 5'b10000;

always @(posedge clk) begin
    // 切换模式
    if (!mode_entered && delay_trigger) begin
        if (select) begin
            case (mode_sel)
                mode1: mode_sel <= mode2;
                mode2: mode_sel <= mode3;
                mode3: mode_sel <= mode4;
                mode4: mode_sel <= mode5;
                mode5: mode_sel <= mode1;
            endcase
        end
    end
end


parameter Num0 = 8'b1111_1100; // "0"
parameter Num1 = 8'b0110_0000; // "1"
parameter Num2 = 8'b1101_1010; // "2"
parameter Num3 = 8'b1111_0010; // "3"
parameter Num4 = 8'b0110_0110; // "4"

always @(posedge clk) begin
    if(mode_entered) begin
    case (mode_sel)
        mode1: begin
            // 当模式为00001时，使用cal模块的输出
            seg1 <= seg11;  
            seg2 <= seg12;  
            seg3 <= seg13; 
            seg4 <= seg14;  
            seg5 <= seg15;  
            seg6 <= seg16;  
            seg7 <= seg17;  
            seg8 <= seg18;     
            leds <= leds1;
        end
        mode2: begin
            // 处理mode2的情况
            seg1 <= 8'b1111_1111; // 示例输出
        end
        mode3: begin
            // 处理mode3的情况
            seg1 <= 8'b1111_1111; // 示例输出
        end
        mode4: begin
            // 处理mode4的情况
            seg1 <= 8'b1111_1111; // 示例输出
        end
        mode5: begin
            // 处理mode5的情况
            seg1 <= 8'b1111_1111; // 示例输出
        end
        default: begin
            seg1 <= 8'b0000_0000; // 默认输出
            seg2 <= 8'b0000_0000; // 默认输出
        end
    endcase
    end
    else begin
        case (mode_sel)
        mode1: begin
            seg1=Num0;         
        end
        mode2: begin
            seg1=Num1;
        end
        mode3: begin
            seg1=Num2;
        end
        mode4: begin
            seg1=Num3;
        end
        mode5: begin
            seg1=Num4;
        end
        default: begin
            seg1 <= 8'b0000_0000;      
        end
    endcase
    end
    display_scan(seg1,seg2,seg3,seg4,seg5,seg6,seg7,seg8,anode,Seg1,Seg2);
end

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
    output reg [7:0] s1;
    output reg [7:0] s2;    
        begin
            anode = 8'b00000000;             
            anode[current_digit] = 1;       
            
            case (current_digit)
                3'd0: s1 = data1;
                3'd1: s1 = data2; 
                3'd2: s1 = data3; 
                3'd3: s1 = data4; 
                3'd4: s2 = data5; 
                3'd5: s2 = data6; 
                3'd6: s2 = data7; 
                3'd7: s2 = data8;
                default: begin
                    s1 = 8'b1111_1111;      // 默认不显示内容
                    s2 = 8'b1111_1111;
                end // 默认不显示任何内容
            endcase
        end
    endtask
endmodule
