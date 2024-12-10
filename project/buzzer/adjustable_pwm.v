module adjustable_pwm (
    input clk,                // 时钟输入 (假设为 50 MHz)
    input [7:0] dip_switch,   // DIP 开关输入，用于调节音量
    output reg pwm_out        // PWM 输出
);

    reg [31:0] counter = 0;        // 计数器
    reg [31:0] time_counter = 0;   // 音符持续时间计数器
    reg [31:0] TOGGLE_LIMIT;       // 动态切换周期阈值
    reg [3:0] duty_cycle;          // PWM 占空比，用于调节音量
    
    // 音符频率表 (单位: Hz)
    localparam [31:0] DO_FREQ = 32'd262; // Do (C4)
    localparam [31:0] RE_FREQ = 32'd294; // Re (D4)
    localparam [31:0] MI_FREQ = 32'd330; // Mi (E4)

    localparam [31:0] TOGGLE_DO = 50_000_000 / (2 * DO_FREQ);
    localparam [31:0] TOGGLE_RE = 50_000_000 / (2 * RE_FREQ);
    localparam [31:0] TOGGLE_MI = 50_000_000 / (2 * MI_FREQ);

    // 音符持续时间 (假设 50 MHz 时钟, 1秒 = 50,000,000 个时钟周期)
    localparam [31:0] NOTE_DURATION = 50_000_000 * 2 / 3;

    // 状态变量定义
    reg [2:0] state = 0; // 0: Do, 1: Re, 2: Mi, 3: Stop
    
    // 用于计算 DIP 开关打开的数量
    integer i;
    
    always @(posedge clk) begin
        // 从 DIP 开关读取音量控制信号（占空比）
        // 计算打开的 DIP 开关数量，结果存入 duty_cycle
        duty_cycle = 0;
        for (i = 0; i < 8; i = i + 1) begin
            duty_cycle = duty_cycle + dip_switch[i];
        end

        // 根据状态设置 TOGGLE_LIMIT
        case (state)
            3'd0: TOGGLE_LIMIT <= TOGGLE_DO; // Do
            3'd1: TOGGLE_LIMIT <= TOGGLE_RE; // Re
            3'd2: TOGGLE_LIMIT <= TOGGLE_MI; // Mi
            3'd3: TOGGLE_LIMIT <= 32'd0;     // 停止状态，无输出
        endcase

        // PWM 生成逻辑，结合占空比控制
        if (state != 3) begin // 仅在播放状态生成 PWM
            counter <= counter + 1;
            if (counter < (TOGGLE_LIMIT * duty_cycle / 8)) begin   //理论上应该是8
                pwm_out <= 1; // 高电平部分
            end else if (counter >= TOGGLE_LIMIT) begin
                counter <= 0; // 重置计数器
            end else begin
                pwm_out <= 0; // 低电平部分
            end
        end else begin
            pwm_out <= 0; // 停止状态，PWM 输出为低电平
        end

        // 音符持续时间计数
        if (state != 3) begin // 在停止状态不计数
            time_counter <= time_counter + 1;
            if (time_counter >= NOTE_DURATION) begin
                time_counter <= 0;
                state <= state + 1; // 切换到下一个音符
                if (state == 2) begin
                    state <= 3; // 播放完 "Mi" 后进入停止状态// 得改回3
                end
            end
        end
    end
endmodule
