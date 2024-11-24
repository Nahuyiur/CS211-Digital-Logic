module Power_top (
    input wire clk,                 // 时钟信号
    input wire reset,               // 复位信号
    input wire power_button,        // 电源按钮
    input wire [3:0] mode_sel,      // 模式选择信号

    //计算模式所需要的
    input enable,                   // 进入退出模式的按钮
    input button_press,             // 切换逻辑运算的按钮      
    input [7:0] a,                  // 逻辑操作数a
    input [7:0] b,                  // 逻辑操作数b   
    input [3:0] shift_op,           // 移位操作选择
    input [1:0] signed_op,          // 有符号数操作选择
    input [3:0] bitwise_op,         // 位运算操作选择
    input [3:0] logic_op,           // 逻辑运算操作选择
    output [6:0] seg1,              // 八进制百位数码管显示
    output [6:0] seg2,              // 八进制十位数码管显示
    output [6:0] seg3,              // 八进制个位数码管显示
    output [6:0] seg4,              // 十进制百位数码管显示
    output [6:0] seg5,              // 十进制十位数码管显示
    output [6:0] seg6,              // 十进制个位数码管显示
    output [6:0] seg7,              // 十六进制高位数码管显示
    output [6:0] seg8,              // 十六进制低位数码管显示
    output [7:0] leds,              // LED显示
    
);


wire power_state; //电源模块的输出信号


Power power_control (
        .clk(clk),
        .reset(reset),
        .power_button(power_button),
        .power_state(power_state)   // 输出电源状态
    );
    


   generate
    if (power_state) begin
        case (mode_sel)
            4'b0001: begin // 计算模式（MODE_CALC）
                cal_top u_calc (
                .clk(clk),
                 .reset(reset),
                 .a(a),
                 .shift_op(shift_op),
                 .b(b),
                 .signed_op(signed_op),           
                 .bitwise_op(bitwise_op)   
                .logic_op(logic_op),
                .enable(enable),
                .seg1(seg1),
                .seg2(seg2),
                .seg3(seg3),
                .seg4(seg4),
                .seg5(seg5),
                .seg6(seg6),
                .seg7(seg7),
                .seg8(seg8),
                .leds(leds)

                );
            end
            4'b0010: begin // 学习模式（MODE_LEARN）
                learn_module u_learn (
                   
                );
            end
            4'b0100: begin // 竞赛模式（MODE_COMPETE）
                compete_module u_compete (
                  
                );
            end
            4'b1000: begin // 演示模式（MODE_DEMO）
                demo_module u_demo (
                  
                );
            end
            default: begin
                // 
            end
        endcase
    end 
endgenerate
endmodule