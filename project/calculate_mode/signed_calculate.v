module signed_calculate(
    input [7:0] a,           // 输入的有符号补码数 a
    input [7:0] b,           // 输入的有符号补码数 b
    input op,                // 选择计算模式
    output reg [6:0] seg1,   // 数码管显示的百位（符号位）
    output reg [6:0] seg2,   // 数码管显示的十位
    output reg [6:0] seg3    // 数码管显示的个位
);

    reg signed [8:0] result;
    reg [7:0] abs_result;
    reg sign;                //sign是符号位

    always @(*) begin
        if(op==0)begin
            result=a+b;
        end else begin
            result=a-b;
        end

    sign=result[8];
    abs_result = is_negative ? -result[7:0] : result[7:0]; // 计算绝对值
    end

    // 数码管段码生成逻辑
    function [7:0] digit_to_seg;  // 输出 8 位（包括 dp）
        input [3:0] digit;        // 输入 4 位数字（支持 0-9 和 A-F）
        case (digit)
            4'd0: digit_to_seg = 8'b1111_1100; // 显示 "0" -> abcd_ef__
            4'd1: digit_to_seg = 8'b0110_0000; // 显示 "1" -> __bc____
            4'd2: digit_to_seg = 8'b1101_1010; // 显示 "2" -> ab_de_g_
            4'd3: digit_to_seg = 8'b1111_0010; // 显示 "3" -> abcd__g_
            4'd4: digit_to_seg = 8'b0110_0110; // 显示 "4" -> __b_c_fg_
            4'd5: digit_to_seg = 8'b1011_0110; // 显示 "5" -> a_cd_fg_
            4'd6: digit_to_seg = 8'b1011_1110; // 显示 "6" -> a_cdefg_
            4'd7: digit_to_seg = 8'b1110_0000; // 显示 "7" -> abc_____
            4'd8: digit_to_seg = 8'b1111_1110; // 显示 "8" -> abcdefg_
            4'd9: digit_to_seg = 8'b1111_0110; // 显示 "9" -> abcd_fg_
            default: digit_to_seg = 8'b0000_0000; // 空白
        endcase
    endfunction

    // 数码管显示逻辑
    always @(*) begin
        // 第一个数码管：显示符号
        if (sign) begin
            seg1 = 8'b0000_0010; // 显示 "-"
        end else begin
            seg1 = 8'b1111_1100; // 显示"0"
        end

        // 第二个数码管：显示十位
        seg2 = digit_to_seg(abs_result / 10);

        // 第三个数码管：显示个位
        seg3 = digit_to_seg(abs_result % 10);
    end
    
endmodule