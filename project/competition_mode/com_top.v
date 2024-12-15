module competition_top (
    input wire clk,                 // 时钟信号
    input wire reset,               // 复位信号
    input wire power_button,        // 电源按钮
    input confirm,                  // 进入退出模式的按钮
    input select,                   // 切换模式的按钮      
    input change,
    input exit,
    input [7:0] in,                // 拨码开关的输入   
    output reg [7:0] Seg1,         // 前四个数码管
    output reg [7:0] Seg2,         // 后四个数码管
    output reg [7:0] led1,         // LED显示
    output reg [7:0] led2,
    output reg [7:0] anode         // 数码管使能信号（动态扫描）
);
reg mode_entered;
wire [7:0] total_player;
wire [1049:0] mode_question_flat;
wire [5999:0] player_flat;
wire [63:0] score_flat;
wire [5:0] total_question;
reg [2:0] mode_sel=3'b001;              // 模式选择信号
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
wire [7:0] seg21;    
wire [7:0] seg22;     
wire [7:0] seg23;             
wire [7:0] seg24;
wire [7:0] seg25; 
wire [7:0] seg26;     
wire [7:0] seg27;             
wire [7:0] seg28;
wire [7:0] seg31;    
wire [7:0] seg32;     
wire [7:0] seg33;             
wire [7:0] seg34;
wire [7:0] seg35; 
wire [7:0] seg36;     
wire [7:0] seg37;             
wire [7:0] seg38;
wire [7:0] led21;
wire [7:0] led22;
wire [7:0] led31;
wire [7:0] led32;
wire type_entered1;
wire type_entered2;
wire type_entered3;
// Counter和触发器相关的信号
reg [31:0] counter;              // 用于按钮按下的计数
reg delay_trigger;               // 触发信号
localparam CLK_FREQ = 50000000; // 假设时钟频率为 50MHz
localparam DELAY_COUNT = CLK_FREQ / 2; // 0.5秒延迟的计数值

// 实例化 cal_top

set set (
    .mode_sel(mode_sel),
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
    .mode_entered(type_entered1),
    .mode_question_flat(mode_question_flat),
    .total(total_question),
    .total_player(total_player)
);

answer answer (
    .total_player(total_player),
    .total(total_question),
    .mode_question_flat(mode_question_flat),
    .mode(mode_sel),
    .clk(clk),                // 时钟信号
    .reset(reset),            // 复位信号
    .confirm(confirm),        // 确定操作的按钮
    .change(change),
    .exit(exit),              // 退出按钮, 假设我们先不使用它
    .submit(select),          // 切换按钮   
    .in(in),                  // 拨码开关的输入   
    .seg1(seg21),
    .seg2(seg22),
    .seg3(seg23),
    .seg4(seg24),
    .seg5(seg25),
    .seg6(seg26),
    .seg7(seg27),
    .seg8(seg28),
    .led1(led21),
    .led2(led22),
    .mode_entered(type_entered2),
    .player_flat(player_flat)
);

review review (
    .select_answer(change),
    .mode_question_flat(mode_question_flat),
    .player_flat(player_flat),
    .mode_sel(mode_sel),
    .clk(clk),                // 时钟信号
    .reset(reset),            // 复位信号
    .confirm(confirm),        // 确定操作的按钮
    .exit(exit),              // 退出按钮, 假设我们先不使用它
    .select(select),          // 切换按钮   
    .in(in),                  // 拨码开关的输入   
    .seg1(seg31),
    .seg2(seg32),
    .seg3(seg33),
    .seg4(seg34),
    .seg5(seg35),
    .seg6(seg36),
    .seg7(seg37),
    .seg8(seg38),
    .led1(led31),
    .led2(led32),
    .type_entered(type_entered3)
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
    if(~type_entered1&&~type_entered2&&~type_entered3) begin
    if (confirm && delay_trigger) begin
        mode_entered <= 1;            
    end 
    if (exit && delay_trigger) begin
        mode_entered <= 0;       
    end 
    end
end

parameter mode1 = 3'b001;
parameter mode2 = 3'b010;
parameter mode3 = 3'b100;


always @(posedge clk) begin
    // 切换模式
    if (~mode_entered && delay_trigger) begin
        if (select) begin
            case (mode_sel)
                mode1: mode_sel <= mode2;
                mode2: mode_sel <= mode3;
                mode3: mode_sel <= mode1;
            endcase
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
always @(posedge clk) begin

    
    if(mode_entered) begin
    case (mode_sel)
        mode1: begin
            seg1 <= seg11;  
            seg2 <= seg12;  
            seg3 <= seg13; 
            seg4 <= seg14;  
            seg5 <= seg15;  
            seg6 <= seg16;  
            seg7 <= seg17;  
            seg8 <= seg18;        
        end
        mode2: begin
            // 处理mode2的情况
            seg1 <= seg21;  
            seg2 <= seg22;  
            seg3 <= seg23; 
            seg4 <= seg24;  
            seg5 <= seg25;  
            seg6 <= seg26;  
            seg7 <= seg27;  
            seg8 <= seg28;    
            led1 <= led21;
            led2 <= led22;
        end
        mode3: begin
    
            seg1 <= seg31;  
            seg2 <= seg32;  
            seg3 <= seg33; 
            seg4 <= seg34;  
            seg5 <= seg35;  
            seg6 <= seg36;  
            seg7 <= seg37;  
            seg8 <= seg38;    
            led1 <= led31;
            led2 <= led32;
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
            seg1=Num1;         
        end
        mode2: begin
            seg1=Num2;
        end
        mode3: begin
            seg1=Num3;
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
