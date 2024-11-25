`timescale 1ns / 1ps

module cal_top(
    input clk,                      // 时钟信号
    input reset,                    // 复位信号
    input confirm,                   // 进入退出模式的按钮
    input store,                    // 存储数字的按钮
    input button_press,             // 切换逻辑运算的按钮   
    input [7:0] in,                 // 拨码开关的输入   
    output reg [7:0]s1,             // 数码管1
    output reg [7:0]s2,             // 数码管2
    output reg [7:0]s3,              
    output reg [7:0]s4,
    output reg [7:0]s5,
    output reg [7:0]s6,
    output reg [7:0]s7, 
    output reg [7:0]s8,             //数码管8        
    output reg [7:0] leds              // LED显示
);
wire [7:0] seg11;//进制转换的8个数码管
wire [7:0] seg12;
wire [7:0] seg13;
wire [7:0] seg14;
wire [7:0] seg15;
wire [7:0] seg16;
wire [7:0] seg17;
wire [7:0] seg18;

wire [7:0] seg21;//符号加减的三个数码管
wire [7:0] seg22;
wire [7:0] seg23;

wire [7:0] result3;//移位运算的输出
wire [7:0] result4;//位运算的输出
wire [7:0] result5;//逻辑运算的输出
 reg [3:0] op;                    // 运算操作选择，若有两种运算则有0001，0010两种模式；若有四种运算则为0001，0010，0100，1000四种模式；
 reg [1:0] store_input = 2'b00;  // 记录此时存储的操作 00为未存储，01为已存储a,10为已存储b,11不合法
 reg [7:0] a;                    // 运算数a
 reg [7:0] b;                    //运算数b  （进制转换没有） 
 reg [4:0] current_state = 5'b00001; // 当前状态，初始化为STATE_BINARY_CONVERTER
 reg [4:0] next_state;   // 下一个状态
 reg mode_entered = 0;            // 0为未进入模式，1为已确认进入模式

 // 计算类型定义
 localparam STATE_BINARY_CONVERTER = 5'b00001,
           STATE_SIGNED_CALCULATE = 5'b00010,
           STATE_SHIFT_OPERATION = 5'b00100,
           STATE_BITWISE_OPERATION = 5'b01000,
           STATE_LOGIC_OPERATION = 5'b10000;

 always @(posedge clk or posedge reset) begin
     if (reset) begin
         current_state <= STATE_BINARY_CONVERTER; // 初始模式为进制转换
         mode_entered <= 0;                       // 初始默认未进入模式
     end 
     else if (button_press && !mode_entered) begin
         current_state <= next_state;               // 若未进入模式，则可以切换模式
         mode_entered <= 1;                         // 同时记录进入模式
     end 
     else if (!mode_entered && confirm) begin
         mode_entered <= 1;                         // 若未进入模式，按下enable键进入模式
     end
     else if (mode_entered && confirm) begin
         mode_entered <= 0;                          // 若已进入模式，则按下enable键退出模式
         store_input <= 2'b00;
     end
 end

 // 确定下一个状态
 always @(*) begin
     case (current_state)
         STATE_BINARY_CONVERTER: next_state = STATE_SIGNED_CALCULATE;
         STATE_SIGNED_CALCULATE: next_state = STATE_SHIFT_OPERATION;
         STATE_SHIFT_OPERATION: next_state = STATE_BITWISE_OPERATION;
         STATE_BITWISE_OPERATION: next_state = STATE_LOGIC_OPERATION;
         STATE_LOGIC_OPERATION: next_state = STATE_BINARY_CONVERTER;
         default: next_state = STATE_BINARY_CONVERTER;
     endcase
 end

 // 状态机逻辑
 always @(posedge clk or posedge reset) begin//每个模式选择运算符
     if (reset) begin
         op <= 4'b0001; // 初始化op
     end else begin
         case (current_state)
         STATE_BINARY_CONVERTER: begin
                 case (op)
                     4'b0001: begin
                         if (button_press) op <= 4'b0010;
                         else op <= 4'b0001;
                     end
                     4'b0010: begin
                         if (button_press) op <= 4'b0001;
                         else op <= 4'b0010;
                     end
                     default: op <= 4'b0001;
                 endcase
             end
             STATE_SIGNED_CALCULATE: begin
                case (op)
                     4'b0001: begin
                         if (button_press) op <= 4'b0010;
                         else op <= 4'b0001;
                     end
                     4'b0010: begin
                         if (button_press) op <= 4'b0100;
                         else op <= 4'b0010;
                     end
                     4'b0100: begin
                         if (button_press) op <= 4'b1000;
                         else op <= 4'b0100;
                     end
                     4'b1000: begin
                         if (button_press) op <= 4'b0001;
                         else op <= 4'b1000;
                     end
                     default: op <= 4'b0001;
                 endcase
             end
             STATE_SHIFT_OPERATION: begin
                 case (op)
                     4'b0001: begin
                         if (button_press) op <= 4'b0010;
                         else op <= 4'b0001;
                     end
                     4'b0010: begin
                         if (button_press) op <= 4'b0100;
                         else op <= 4'b0010;
                     end
                     4'b0100: begin
                         if (button_press) op <= 4'b1000;
                         else op <= 4'b0100;
                     end
                     4'b1000: begin
                         if (button_press) op <= 4'b0001;
                         else op <= 4'b1000;
                     end
                     default: op <= 4'b0001;
                 endcase
             end
             STATE_BITWISE_OPERATION: begin
                 case (op)
                     4'b0001: begin
                         if (button_press) op <= 4'b0010;
                         else op <= 4'b0001;
                     end
                     4'b0010: begin
                         if (button_press) op <= 4'b0100;
                         else op <= 4'b0010;
                     end
                     4'b0100: begin
                         if (button_press) op <= 4'b1000;
                         else op <= 4'b0100;
                     end
                     4'b1000: begin
                         if (button_press) op <= 4'b0001;
                         else op <= 4'b1000;
                     end
                     default: op <= 4'b0001;
                 endcase
             end
             STATE_LOGIC_OPERATION: begin
                 case (op)
                     4'b0001: begin
                         if (button_press) op <= 4'b0010;
                         else op <= 4'b0001;
                     end
                     4'b0010: begin
                         if (button_press) op <= 4'b0100;
                         else op <= 4'b0010;
                     end
                     4'b0100: begin
                         if (button_press) op <= 4'b1000;
                         else op <= 4'b0100;
                     end
                     4'b1000: begin
                         if (button_press) op <= 4'b0001;
                         else op <= 4'b1000;
                     end
                     default: op <= 4'b0001;
                 endcase
             end
         endcase
     end
 end

  always @(*) begin//把当前模式的计算结果赋值给输出端
     case(store_input) 
        2'b10: begin
            case(current_state)
        STATE_BINARY_CONVERTER: begin
        s1<=seg11; 
        s2<=seg12; 
        s3<=seg13; 
        s4<=seg14; 
        s5<=seg15; 
        s6<=seg16; 
        s7<=seg17; 
        s8<=seg18; 
        end
         STATE_SIGNED_CALCULATE: begin
        s1<=seg21; 
        s2<=seg22; 
        s3<=seg23; 
    
        end
             
        STATE_SHIFT_OPERATION: begin
            leds<=result3;
     end
          
            STATE_BITWISE_OPERATION: begin
            leds<=result4;
             end
            STATE_LOGIC_OPERATION: begin
            leds<=result5;
             end
         endcase
     end
     default: begin
        leds <= in;
     end
  endcase
 end

     always @(posedge clk or posedge reset) begin//存储当前模式a,b的值
     if (reset) begin
         store_input <= 2'b00;
     end else if (mode_entered && store) begin
         case (current_state)

STATE_BINARY_CONVERTER: begin
         case (store_input)
             2'b00: begin
                 a <= in;
                 store_input <= 2'b10;
             end
             default:begin
                store_input <= 2'b00;
             end
        endcase
        end
         STATE_SIGNED_CALCULATE: begin
         case (store_input)
             2'b00: begin
                 a <= in;
                 store_input <= 2'b01;//此时已存储a, store_input变成01
             end
             2'b01: begin
                 b <= in;
                 store_input <= 2'b10;//此时已存储b, store_input变成01
             end
             default:begin
                store_input <= 2'b00;
             end
        endcase
        end
             
        STATE_SHIFT_OPERATION: begin
            case (store_input)
             2'b00: begin
                 a <= in;
                 store_input <= 2'b01;
             end
             2'b01: begin
                 b <= in;
                 store_input <= 2'b10;
             end
             default:begin
                store_input <= 2'b00;
             end
endcase
     end
          
            STATE_BITWISE_OPERATION: begin
                 case (store_input)
             2'b00: begin
                 a <= in;
                 store_input <= 2'b01;
             end
             2'b01: begin
                 b <= in;
                 store_input <= 2'b10;
             end
             2'b10: begin
                assign leds = result4;
                store_input <= 2'b00;
             end
             default:begin
                store_input <= 2'b00;
             end
endcase
             end
            STATE_LOGIC_OPERATION: begin
                 case (store_input)
             2'b00: begin
                 a <= in;
                 store_input <= 2'b01;
             end
             2'b01: begin
                 b <= in;
                 store_input <= 2'b10;
             end

             default:begin
                store_input <= 2'b00;
             end
endcase
             end
         endcase
     end
 end
    binary_converter u_binary_converter (
        .binary(a),
        .seg1(seg11),
        .seg2(seg12),
        .seg3(seg13),
        .seg4(seg14),
        .seg5(seg15),
        .seg6(seg16),
        .seg7(seg17),
        .seg8(seg18)
    );
    signed_calculate u_signed_calculate(
        .a(a),
        .b(b),
        .op(op),
        .seg1(seg21),
        .seg2(seg22),
        .seg3(seg23)
    );

    shift_operation u_shift_operation(
        .a(a),
        .b(b),
        .op(op),
        .result(result3)
    );

    bitwise u_bitwise(
        .a(a),
        .b(b),
        .op(op),
        .result(result4)
    );
   
    logic_operation u_logic_operation(
        .a(a),
        .b(b),
        .op(op),
        .leds1(leds1),
        .leds2(leds2),
        .result(result5)
    );


   
endmodule