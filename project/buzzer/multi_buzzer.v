module multi_buzzer(
    input en,
    input clk,
    input [7:0] dip_switch,
    input [5:0] se, // 不同的音效
    output reg pwm_out
);
    parameter S1 = 6'b000001;
    parameter S2 = 6'b000010;
    parameter S3 = 6'b000100;
    parameter S4 = 6'b001000;
    parameter S5 = 6'b010000;
    parameter S6 = 6'b100000;

    reg [31:0] counter = 0;       // 计数器
    reg [31:0] time_counter = 0;  // 音符持续时间计数器
    reg [31:0] TOGGLE_LIMIT;      // 动态切换周期阈值
    reg [3:0] duty_cycle = 0;     // PWM 占空比，用于调节音量
    reg [3:0] state = 0;          // 状态机状态

    // 音符频率表 (单位: Hz)
    localparam [31:0] DO_FREQ = 32'd261;   // Do
    localparam [31:0] RE_FREQ = 32'd294;   // Re
    localparam [31:0] MI_FREQ = 32'd330;   // Mi
    localparam [31:0] FA_FREQ = 32'd349;   // Fa
    localparam [31:0] SOL_FREQ = 32'd392;  // Sol
    localparam [31:0] LA_FREQ = 32'd440;   // La
    localparam [31:0] SI_FREQ = 32'd494;   // Si

    localparam [31:0] TOGGLE_DO = 50_000_000 / (2 * DO_FREQ);
    localparam [31:0] TOGGLE_RE = 50_000_000 / (2 * RE_FREQ);
    localparam [31:0] TOGGLE_MI = 50_000_000 / (2 * MI_FREQ);
    localparam [31:0] TOGGLE_FA = 50_000_000 / (2 * FA_FREQ);
    localparam [31:0] TOGGLE_SOL = 50_000_000 / (2 * SOL_FREQ);
    localparam [31:0] TOGGLE_LA = 50_000_000 / (2 * LA_FREQ);
    localparam [31:0] TOGGLE_SI = 50_000_000 / (2 * SI_FREQ);
    localparam [31:0] BLANK = 32'd0;

    // 音符持续时间 (假设 50 MHz 时钟, 1秒 = 50,000,000 个时钟周期)
    localparam [31:0] NOTE_DURATION = 50_000_000 * 2 / 3;

    integer i;

    always @(posedge clk) begin
        if (en) begin
            // 从 DIP 开关读取音量控制信号（占空比）
            duty_cycle = 0;
            for (i = 0; i < 8; i = i + 1) begin
                duty_cycle = duty_cycle + dip_switch[i]*(i+1);
            end

            // 根据音效模式和状态设置 TOGGLE_LIMIT
            case (se)
                S1: begin //胜利音效
                    case (state)
                        4'd0: TOGGLE_LIMIT <= TOGGLE_DO;   // Do
                        4'd1: TOGGLE_LIMIT <= TOGGLE_RE;   // Re
                        4'd2: TOGGLE_LIMIT <= TOGGLE_MI;   // Mi
                        default: TOGGLE_LIMIT <= BLANK;    // 空白音
                    endcase
                end
                S2: begin //失败音效
                    case (state)
                        4'd0: TOGGLE_LIMIT <= TOGGLE_MI;   // Mi
                        4'd1: TOGGLE_LIMIT <= TOGGLE_DO;   // Do
                        default: TOGGLE_LIMIT <= BLANK;    // 空白音
                    endcase
                end
                S3: begin //切换模式
                    case (state)
                        4'd0: TOGGLE_LIMIT <= TOGGLE_LA;   // La
                        4'd1: TOGGLE_LIMIT <= TOGGLE_FA;   // Fa
                        default: TOGGLE_LIMIT <= BLANK;    // 空白音
                    endcase
                end
                S4: begin   //结算音效
                    case (state)
                        4'd0: TOGGLE_LIMIT <= TOGGLE_DO;   // Do
                        4'd1: TOGGLE_LIMIT <= TOGGLE_MI;   // Mi
                        4'd2: TOGGLE_LIMIT <= TOGGLE_SOL;  // Sol
                        4'd3: TOGGLE_LIMIT <= TOGGLE_DO;   // Do (再一次)
                        default: TOGGLE_LIMIT <= BLANK;    // 空白音
                    endcase
                end
                S5: begin   
                    case (state)
                        4'd0: TOGGLE_LIMIT <= TOGGLE_SOL;  // Sol
                        4'd1: TOGGLE_LIMIT <= TOGGLE_MI;   // Mi
                        4'd2: TOGGLE_LIMIT <= TOGGLE_DO;   // Do
                        default: TOGGLE_LIMIT <= BLANK;    // 空白音
                    endcase
                end
                S6: begin   //提示音
                    case (state)
                        4'd0: TOGGLE_LIMIT <= TOGGLE_MI;   // Mi（提示音）
                        4'd1: TOGGLE_LIMIT <= TOGGLE_MI;
                        default: TOGGLE_LIMIT <= BLANK;    // 空白音
                    endcase
                end
                default: TOGGLE_LIMIT <= BLANK;  // 默认状态：无音符
            endcase

            // PWM 生成逻辑，结合占空比控制
            if (state != 4'd4) begin // 仅在播放状态生成 PWM
                counter <= counter + 1;
                if (counter < (TOGGLE_LIMIT * duty_cycle / 8/64)) begin
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
            if (state != 4'd4) begin // 在停止状态不计数
                time_counter <= time_counter + 1;
                if (time_counter >= NOTE_DURATION) begin
                    time_counter <= 0;
                    state <= state + 1; // 切换到下一个音符
                    if (state == 4'd3) begin
                        state <= 4'd0; // 播放完最后一个音符后进入停止状态
                    end
                end
            end
        end
    end
endmodule
