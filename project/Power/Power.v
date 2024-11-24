module Power (
    input wire clk,                
    input wire reset,              
    input wire power_button,       
    output reg power_state      
  
);

  localparam STATE_OFF           = 1'b0; 
    localparam STATE_STANDBY      = 1'b1;  

    reg current_state, next_state;

    localparam CLK_FREQ         = 100_000_000;  
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


    

endmodule
