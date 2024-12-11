module multi_buzzer(
    input en,
    input clk,
    input [7:0] dip_switch,
    input [4:0] se,//不同的音效
    output reg pwm_out
);
    reg [31:0] counter = 0;       // 计数器
    reg [31:0] time_counter = 0;  // 音符持续时间计数器
    reg [31:0] TOGGLE_LIMIT;      // 动态切换周期阈值
    reg [3:0] duty_cycle=0;          // PWM 占空比，用于调节音量

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
    localparam [31:0] BLANK=32'd0;

    // 音符持续时间 (假设 50 MHz 时钟, 1秒 = 50,000,000 个时钟周期)
    localparam [31:0] NOTE_DURATION = 50_000_000 * 2 / 3;

    reg isfinish=0;
    always @(en) begin
        isfinish=en;
    end
    
    integer i;
    always @(dip_switch) begin
        for (i = 0; i<8; i++) begin
            duty_cycle=duty_cycle+dip_switch[i];
        end
    end

    parameter S1 =6'b000001;
    parameter S2 =6'b000010;
    parameter S3 =6'b000100;
    parameter S4 =6'b001000;
    parameter S5 =6'b010000;
    parameter S6 =6'b100000;

    reg[1:0] state=0;//默认是4个音，如果音比较少用空白补
    

    always @(posedge clk) begin
        if (isfinish) begin
            // se: 选择不同音效模式
            case (se)
                S1: begin
                    // 音效1：Do Re Mi Fa
                    case (state)
                        2'd0: TOGGLE_LIMIT <= TOGGLE_DO;   // Do
                        2'd1: TOGGLE_LIMIT <= TOGGLE_RE;   // Re
                        2'd2: TOGGLE_LIMIT <= TOGGLE_MI;   // Mi
                        2'd3: TOGGLE_LIMIT <= TOGGLE_FA;   // Fa
                        default: TOGGLE_LIMIT <= BLANK;    // 空白音
                    endcase
                end

                S2: begin
                    // 音效2：Mi Fa Sol La
                    case (state)
                        2'd0: TOGGLE_LIMIT <= TOGGLE_MI;   // Mi
                        2'd1: TOGGLE_LIMIT <= TOGGLE_FA;   // Fa
                        2'd2: TOGGLE_LIMIT <= TOGGLE_SOL;  // Sol
                        2'd3: TOGGLE_LIMIT <= TOGGLE_LA;   // La
                        default: TOGGLE_LIMIT <= BLANK;    // 空白音
                    endcase
                end

                S3: begin
                    // 音效3：Fa Sol La Si
                    case (state)
                        2'd0: TOGGLE_LIMIT <= TOGGLE_FA;   // Fa
                        2'd1: TOGGLE_LIMIT <= TOGGLE_SOL;  // Sol
                        2'd2: TOGGLE_LIMIT <= TOGGLE_LA;   // La
                        2'd3: TOGGLE_LIMIT <= TOGGLE_SI;   // Si
                        default: TOGGLE_LIMIT <= BLANK;    // 空白音
                    endcase
                end

                S4: begin
                    // 音效4：Do Mi Sol Do
                    case (state)
                        2'd0: TOGGLE_LIMIT <= TOGGLE_DO;   // Do
                        2'd1: TOGGLE_LIMIT <= TOGGLE_MI;   // Mi
                        2'd2: TOGGLE_LIMIT <= TOGGLE_SOL;  // Sol
                        2'd3: TOGGLE_LIMIT <= TOGGLE_DO;   // Do (再一次)
                        default: TOGGLE_LIMIT <= BLANK;    // 空白音
                    endcase
                end

                S5: begin
                    // 音效5：La Si Do Re
                    case (state)
                        2'd0: TOGGLE_LIMIT <= TOGGLE_LA;   // La
                        2'd1: TOGGLE_LIMIT <= TOGGLE_SI;   // Si
                        2'd2: TOGGLE_LIMIT <= TOGGLE_DO;   // Do
                        2'd3: TOGGLE_LIMIT <= TOGGLE_RE;   // Re
                        default: TOGGLE_LIMIT <= BLANK;    // 空白音
                    endcase
                end

                S6: begin
                    // 音效6：提示音（重复一个音符）
                    case (state)
                        2'd0: TOGGLE_LIMIT <= TOGGLE_MI;   // Mi（提示音）
                        default: TOGGLE_LIMIT <= BLANK;    // 空白音
                    endcase
                end

                default: TOGGLE_LIMIT <= BLANK;  // 默认状态：无音符
            endcase
        end
    end


    // PWM 生成逻辑，结合占空比控制
    always @(posedge clk) begin
        if (state != 3) begin // 仅在播放状态生成 PWM
            counter <= counter + 1;
            if (counter < (TOGGLE_LIMIT * duty_cycle / 8)) begin
                pwm_out <= 1; // 高电平部分
            end else if (counter >= TOGGLE_LIMIT) begin
                counter <= 0; // 重置计数器
            end else begin
                pwm_out <= 0; // 低电平部分
            end
        end else begin
            pwm_out <= 0; // 停止状态，PWM 输出为低电平
            isfinish<=0;
        end

        // 音符持续时间计数
        if (state != 3) begin
            time_counter <= time_counter + 1;
            if (time_counter >= NOTE_DURATION) begin
                time_counter <= 0;
                state <= state + 1; // 切换到下一个音符
                if (state == 2) begin
                    state <= 3; // 播放完音符后进入停止状态
                end
            end
        end
    end
endmodule