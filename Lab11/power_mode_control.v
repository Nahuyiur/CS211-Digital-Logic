module power_mode_control (
    input wire clk,                
    input wire reset,              
    input wire power_button,       
    input wire [1:0] mode_select, // 模式选择输入 (2位表示四个模式)
    output reg power_state,       // 电源状态，0:关机，1:开机
    output reg [1:0] current_mode 
);

    localparam STATE_OFF          = 1'b0; 
    localparam STATE_STANDBY      = 1'b1;  

  
    localparam STATE_CALC          = 2'b00;  // 计算模式
    localparam STATE_LEARN         = 2'b01;  // 学习模式
    localparam STATE_COMPETITION   = 2'b10;  // 竞赛模式
    localparam STATE_DEMO          = 2'b11;  // 演示模式

    reg current_state, next_state;

    localparam CLK_FREQ         = 100_000_000;  
    localparam LONG_PRESS_TIME  = 3;             
    localparam LONG_PRESS_COUNT = CLK_FREQ * LONG_PRESS_TIME; 

    reg [28:0] press_counter;      // 按钮按下计时器
    reg button_prev, button_stable;  // 按钮的前一个状态，按钮稳定状态
    wire button_pressed;            // 按钮按下脉冲信号
    wire button_released;           // 按钮释放脉冲信号

    // 按钮状态检测（脉冲信号）
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

    // 按钮按下计时器（检测长按情况）
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
                  
                    case (mode_select)
                        2'b00: next_state = STATE_CALC;        
                        2'b01: next_state = STATE_LEARN;      
                        2'b10: next_state = STATE_COMPETITION; 
                        2'b11: next_state = STATE_DEMO;       
                        default: next_state = STATE_STANDBY;   
                    endcase
                end
                else if (power_button && press_counter >= LONG_PRESS_COUNT) begin
                    next_state = STATE_OFF;  // 长按关机
                end
            end

            STATE_CALC, STATE_LEARN, STATE_COMPETITION, STATE_DEMO: begin
                if (button_pressed && press_counter < LONG_PRESS_COUNT) begin
                    next_state = STATE_STANDBY; // 按钮短按返回待机状态
                end
                else if (power_button && press_counter >= LONG_PRESS_COUNT) begin
                    next_state = STATE_OFF;  // 长按关机
                end
            end

            default: next_state = STATE_OFF;  // 默认进入关机状态
        endcase
    end

  
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
                current_mode = STATE_OFF;
            end
            STATE_STANDBY: begin
                power_state = 1'b1;  
                current_mode = STATE_STANDBY;
            end
            STATE_CALC: begin
                power_state = 1'b1;   
                current_mode = STATE_CALC;
            end
            STATE_LEARN: begin
                power_state = 1'b1;  
                current_mode = STATE_LEARN;
            end
            STATE_COMPETITION: begin
                power_state = 1'b1;   
                current_mode = STATE_COMPETITION;
            end
            STATE_DEMO: begin
                power_state = 1'b1;   
                current_mode = STATE_DEMO;
            end
            default: begin
                power_state = 1'b0;  
                current_mode = STATE_OFF;
            end
        endcase
    end

endmodule
