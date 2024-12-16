module top (
    input wire clk,                 // 时钟信号
    input wire reset,               // 复位信号
    input power_button,        // 电源按钮
    input confirm,                  // 进入退出模式的按钮
    input select,                   // 切换模式的按钮      
    input change,
    input exit,
    input data,
    input [7:0] dip_switch,
    input [7:0] in,                // 拨码开关的输入  
    output wire pwm_out, 
    output reg [7:0] Seg1,         // 前四个数码管
    output reg [7:0] Seg2,         // 后四个数码管
    output reg [7:0] led1,         // LED显示
    output reg [7:0] led2,         // LED显示
    output reg [7:0] anode        // 数码管使能信号（动态扫描）
);
reg power_state; //开关机状态
reg mode_entered=0;
reg [3:0] mode_sel=4'b0001;              // 模式选择信号
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
wire [7:0] seg41;    
wire [7:0] seg42;     
wire [7:0] seg43;             
wire [7:0] seg44;
wire [7:0] seg45; 
wire [7:0] seg46;     
wire [7:0] seg47;             
wire [7:0] seg48;
wire [7:0] leds11;
wire [7:0] leds21;
wire [7:0] leds31;
wire [7:0] leds32;
wire [7:0] leds41;
wire type_entered1;
wire type_entered2;
wire type_entered3;
wire type_entered4;
// Counter和触发器相关的信号
reg [31:0] counter;              // 用于按钮按下的计数
reg delay_trigger;               // 触发信号
localparam CLK_FREQ = 50000000; // 假设时钟频率为 50MHz
localparam DELAY_COUNT = CLK_FREQ / 2; // 0.5秒延迟的计数值

    localparam STATE_OFF           = 1'b0; 
    localparam STATE_STANDBY      = 1'b1;  

    reg current_state, next_state;
    localparam LONG_PRESS_TIME  = 3;             
    localparam LONG_PRESS_COUNT = CLK_FREQ * LONG_PRESS_TIME; 

    reg [28:0] press_counter;      
    reg button_prev, button_stable;  
    wire button_pressed;            
    wire button_released;          

    
    always @(posedge clk or posedge reset) begin
        if (~reset) begin
            button_prev <= 1'b0;
            button_stable <= 1'b0;
        end else begin
            button_prev <= power_button;
            button_stable <= button_prev;
        end
    end


    assign button_pressed = power_button & ~button_prev;
    assign button_released = ~power_button & button_prev;

    
    always @(posedge clk or posedge reset) begin
        if (~reset) begin
            press_counter <= 29'd0;
        end else if (power_button) begin
            if (press_counter < LONG_PRESS_COUNT) begin
                press_counter <= press_counter + 1'b1;
            end
        end else begin
            press_counter <= 29'd0;
        end
    end

   
    always @(*) begin
        next_state = current_state;
        case (current_state)
            STATE_OFF: begin
                if (button_pressed) begin
                    next_state = STATE_STANDBY;
                  
                end
            end

            STATE_STANDBY: begin
                if (button_pressed && press_counter < LONG_PRESS_COUNT) begin
                    next_state = STATE_STANDBY;
                     
                end
                else if (power_button && press_counter >= LONG_PRESS_COUNT) begin
                    next_state = STATE_OFF; 
                     
                end
            end

            default: next_state = STATE_OFF;  // 默认进入关机状态
        endcase
    end

    // 当前状态更新
    always @(posedge clk or posedge reset) begin
        if (~reset) begin
            current_state <= STATE_OFF;  // 初始化时设置为关机状态
        end else begin
            current_state <= next_state; // 更新当前状态
        end
    end

    
    always @(*) begin
        case (current_state)
            STATE_OFF: begin
                power_state = 1'b0;   
              
          end
            STATE_STANDBY: begin
                power_state = 1'b1;   
               
            end
            default: begin
                power_state = 1'b0;   
               
            end
        endcase
    end    

reg en=0;
reg [5:0] sel=6'b000000;
wire [1:0] correct;
parameter S1 = 6'b000001;
    parameter S2 = 6'b000010;
    parameter S3 = 6'b000100;
    parameter S4 = 6'b001000;
    parameter S5 = 6'b010000;
    parameter S6 = 6'b100000;
always @(posedge clk) begin
    if(confirm) begin
        en=1;
        sel=S3;
    end
    if(select) begin
        en=1;
        sel=S5;
    end
    if(~confirm&~select) begin
        if(correct==2'b10) begin
        en=1;
        sel=S1;
    end
        if(correct==2'b01) begin
        en=1;
        sel=S2;
    end
        if(correct==2'b00) begin
        en=0;
        sel=S2;
    end
    end

end

buzzer buzzer(
    .en(en),
    .se(sel),
    .clk(clk),
    .dip_switch(dip_switch),
    .pwm_out(pwm_out)
);
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
    .leds(leds11),
    .type_entered(type_entered1)
);

study_top study (
    .enter(mode_sel),
    .clk(clk),                // 时钟信号
    .reset(reset),            // 复位信号
    .confirm(confirm),        // 确定操作的按钮
    .exit(exit),              // 退出按钮, 假设我们先不使用它
    .select(select),          // 切换按钮   
    .in(in),   
    .data(change),               // 拨码开关的输入   
    .seg1(seg21),
    .seg2(seg22),
    .seg3(seg23),
    .seg4(seg24),
    .seg5(seg25),
    .seg6(seg26),
    .seg7(seg27),
    .seg8(seg28),
    .led(leds21),
    .mode_entered(type_entered2),
    .correct(correct)
);

competition_top competition (
    .enter(mode_sel),
    .clk(clk),                // 时钟信号
    .reset(reset),            // 复位信号
    .confirm(confirm),        // 确定操作的按钮
    .change(change),
    .exit(exit),              // 退出按钮, 假设我们先不使用它
    .select(select),          // 切换按钮   
    .in(in),   
    .seg1(seg31),
    .seg2(seg32),
    .seg3(seg33),
    .seg4(seg34),
    .seg5(seg35),
    .seg6(seg36),
    .seg7(seg37),
    .seg8(seg38),
    .led1(leds31),
    .led2(leds32),
    .mode_entered(type_entered3)
);


display display (
    .enter(mode_sel),
    .clk(clk),                // 时钟信号
    .reset(reset),            // 复位信号
    .confirm(confirm),        // 确定操作的按钮
    .exit(exit),              // 退出按钮, 假设我们先不使用它
    .in1(in[6:4]),  
    .in2(in[2:0]),   
    .seg1(seg41),
    .seg2(seg42),
    .seg3(seg43),
    .seg4(seg44),
    .seg5(seg45),
    .seg6(seg46),
    .seg7(seg47),
    .seg8(seg48),
    .leds(leds41),
    .type_entered(type_entered4)
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
    if(~type_entered1&&~type_entered2&&~type_entered3&&~type_entered4) begin
    if (confirm && delay_trigger) begin
        mode_entered <= 1;            
    end 
    if (exit && delay_trigger) begin
        mode_entered <= 0;       
    end 
    end
end

parameter mode1 = 4'B0001;
parameter mode2 = 4'b0010;
parameter mode3 = 4'b0100;
parameter mode4 = 4'b1000;

parameter Blank=8'b0000_0000;
always @(posedge clk) begin
    // 切换模式
    if (!mode_entered && delay_trigger&current_state==STATE_STANDBY) begin
        if (select) begin
            case (mode_sel)
                mode1: mode_sel <= mode2;
                mode2: mode_sel <= mode3;
                mode3: mode_sel <= mode4;
                mode4: mode_sel <= mode1;
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
            led1 <= leds11;
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
            led1 <= leds21;
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
            led1 <= leds31;
            led2 <= leds32;
        end
        mode4: begin
            seg1 <= seg41;  
            seg2 <= seg42;  
            seg3 <= seg43; 
            seg4 <= seg44;  
            seg5 <= seg45;  
            seg6 <= seg46;  
            seg7 <= seg47;  
            seg8 <= seg48;     
            led1 <= leds41;
        end
        default: begin
            seg1 <= Blank; // 默认输出
            seg2 <= Blank; // 默认输出
        end
    endcase
    end
    else begin
        led1 <= power_state;
        if(current_state==STATE_STANDBY) begin
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
        mode4: begin
            seg1=Num4;
        end
        default: begin
            seg1 <= Blank;      
        end
    endcase
        end
        else begin
            seg1 <= Blank;
            seg2 <= Blank;
            seg3 <= Blank;
            seg4 <= Blank;
            seg5 <= Blank;
            seg6 <= Blank;
            seg7 <= Blank;
            seg8 <= Blank;
        end
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
                    s1 = Blank;      // 默认不显示内容
                    s2 = Blank;
                end // 默认不显示任何内容
            endcase
        end
    endtask
endmodule
