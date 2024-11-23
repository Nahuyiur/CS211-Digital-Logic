module binary_converter (
    input [7:0] binary,       // 输入的 8 位二进制数
    output [6:0] seg1,        // 八进制百位数码管显示
    output [6:0] seg2,        // 八进制十位数码管显示
    output [6:0] seg3,        // 八进制个位数码管显示
    output [6:0] seg4,        // 十进制百位数码管显示
    output [6:0] seg5,        // 十进制十位数码管显示
    output [6:0] seg6,        // 十进制个位数码管显示
    output [6:0] seg7,        // 十六进制高位数码管显示
    output [6:0] seg8         // 十六进制低位数码管显示
    output [7:0] leds,        // 对应的led灯显示
);

    // 八进制转换结果寄存器
    reg [3:0] octal_hundreds; // 八进制百位
    reg [3:0] octal_tens;     // 八进制十位
    reg [3:0] octal_ones;     // 八进制个位

    // 十进制转换结果寄存器
    reg [3:0] decimal_hundreds; // 十进制百位
    reg [3:0] decimal_tens;     // 十进制十位
    reg [3:0] decimal_ones;     // 十进制个位

    // 十六进制转换结果寄存器
    reg [3:0] hex_high;        // 十六进制高位
    reg [3:0] hex_low;         // 十六进制低位

    
    always @(*) begin
        // 八进制转换逻辑
        octal_hundreds = binary / 64;        // 八进制百位
        octal_tens     = (binary / 8) % 8;   // 八进制十位
        octal_ones     = binary % 8;         // 八进制个位

        // 十进制转换逻辑
        decimal_hundreds = binary / 100;        // 十进制百位
        decimal_tens     = (binary / 10) % 10;  // 十进制十位
        decimal_ones     = binary % 10;         // 十进制个位

        // 十六进制转换逻辑
        hex_high = binary[7:4];  // 十六进制高 4 位
        hex_low  = binary[3:0];  // 十六进制低 4 位
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
            4'd10: digit_to_seg = 8'b1110_1110; // 显示 "A" -> abc_efg_
            4'd11: digit_to_seg = 8'b0011_1110; // 显示 "B" -> __cdefg_
            4'd12: digit_to_seg = 8'b1001_1100; // 显示 "C" -> a__def__
            4'd13: digit_to_seg = 8'b0111_1010; // 显示 "D" -> __bcde_g
            4'd14: digit_to_seg = 8'b1001_1110; // 显示 "E" -> a__defg_
            4'd15: digit_to_seg = 8'b1000_1110; // 显示 "F" -> a___efg_
            default: digit_to_seg = 8'b0000_0000; // 空白
        endcase
    endfunction

    // 八进制数码管输出
    assign seg1 = digit_to_seg(octal_hundreds); // 八进制百位
    assign seg2 = digit_to_seg(octal_tens);     // 八进制十位
    assign seg3 = digit_to_seg(octal_ones);     // 八进制个位

    // 十进制数码管输出
    assign seg4 = digit_to_seg(decimal_hundreds); // 十进制百位
    assign seg5 = digit_to_seg(decimal_tens);     // 十进制十位
    assign seg6 = digit_to_seg(decimal_ones);     // 十进制个位

    // 十六进制数码管输出
    assign seg7 = digit_to_seg(hex_high);         // 十六进制高位
    assign seg8 = digit_to_seg(hex_low);          // 十六进制低位

    // LED 输出：直接映射输入的每一位
    assign leds = binary;
endmodule