`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/11 15:07:12
// Design Name: 
// Module Name: time
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

 
module answer (
    input [7:0] total_player,
    input enter,
    input wire [5:0] total, 
    input wire [2:0] mode,
    input clk,
    input reset,
    input confirm,
    input submit,
    input exit, 
    input change,
    input [7:0] in,
    input [1049:0] mode_question_flat,
    output reg [7:0] seg1,
    output reg [7:0] seg2,
    output reg [7:0] seg3,
    output reg [7:0] seg4,
    output reg [7:0] seg5,
    output reg [7:0] seg6,
    output reg [7:0] seg7,
    output reg [7:0] seg8,
    output reg [7:0] led1,
    output reg [7:0] led2,
    output reg mode_entered,
    output reg[5999:0] player_flat
    );
    reg [20:0] question [49:0];
    parameter is_enter = 4'b0100;
integer k;
// 鍦� `always` 鍧椾腑灏嗕簩缁存暟缁勫睍骞充负涓�缁存暟缁勶細
always @(posedge clk) begin
    // 灏嗕簩缁存暟缁勫睍骞充负涓�缁存暟缁�
    for (k = 0; k < 50; k = k + 1) begin
        question[k]=mode_question_flat[k * 21 +: 21];
    end
end
reg[29:0] player [3:0][49:0];

integer i, j;
    always @(posedge clk )  begin
            // 鐢ㄤ袱涓祵濂楃殑for寰幆灏嗕簩缁存暟缁勫睍寮�鎴愪竴涓�6000浣嶇殑淇″彿
            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 50; j = j + 1) begin
                    player_flat[(i * 50 + j) * 30 +: 30] = player[i][j]; // 灞曞紑骞舵嫾鎺�
                end
            end
        end


reg finish=0;
reg [4:0] total_time = 5'b11000;
reg [4:0] current_time = 5'b11000;
reg [5:0] current = 6'b000000;    //褰撳墠璧涢
reg [1:0] current_player = 2'b00;//褰撳墠閫夋墜

parameter Num0 = 8'b1111_1100; // "0"
parameter Num1 = 8'b0110_0000; // "1"
parameter Num2 = 8'b1101_1010; // "2"
parameter Num3 = 8'b1111_0010; // "3"
parameter Num4 = 8'b0110_0110; // "4"
parameter Num5 = 8'b1011_0110; // "5"
parameter Num6 = 8'b1011_1110; // "6"
parameter Num7 = 8'b1110_0000; // "7"
parameter Num8 = 8'b1111_1110; // "8"
parameter Num9 = 8'b1111_0110; // "9"
parameter NumA = 8'b1110_1110; // "A"
parameter Numa = 8'b0011_1110; // "A"
parameter NumB = 8'b0011_1110; // "B"
parameter NumC = 8'b1001_1001; // "C"
parameter NumD = 8'b0111_1010; // "D"
parameter NumE = 8'b1001_1110; // "E"
parameter NumF = 8'b1000_1110; // "F"
parameter Blank = 8'b0000_0000; // 绌虹櫧
parameter Minus= 8'b0000_0010;//"-"

function [7:0] digit_to_seg1;
    input [3:0] digit;  // 杈撳叆 4 浣嶆暟瀛楋紙鏀寔 0-9 鍜� A-F锛�
    begin
        case (digit)
            4'd0: digit_to_seg1 = Num0; // 鏄剧ず "0"
            4'd1: digit_to_seg1 = Num1; // 鏄剧ず "1"
            4'd2: digit_to_seg1 = Num2; // 鏄剧ず "2"
            4'd3: digit_to_seg1 = Num3; // 鏄剧ず "3"
            4'd4: digit_to_seg1 = Num4; // 鏄剧ず "4"
            4'd5: digit_to_seg1 = Num5; // 鏄剧ず "5"
            4'd6: digit_to_seg1 = Num6; // 鏄剧ず "6"
            4'd7: digit_to_seg1 = Num7; // 鏄剧ず "7"
            4'd8: digit_to_seg1 = Num8; // 鏄剧ず "8"
            4'd9: digit_to_seg1 = Num9; // 鏄剧ず "9"
            4'd10: digit_to_seg1 = NumA; // 鏄剧ず "A"
            4'd11: digit_to_seg1 = NumB; // 鏄剧ず "B"
            4'd12: digit_to_seg1 = NumC; // 鏄剧ず "C"
            4'd13: digit_to_seg1 = NumD; // 鏄剧ず "D"
            4'd14: digit_to_seg1 = NumE; // 鏄剧ず "E"
            4'd15: digit_to_seg1 = NumF; // 鏄剧ず "F"
            default: digit_to_seg1 = Blank; // 绌虹櫧
        endcase
    end
endfunction

reg [24:0] counter = 0; // 璁℃暟鍣�
reg delay_trigger = 0;  // 瑙﹀彂淇″彿
localparam CLK_FREQ = 50000000; // 鍋囪鏃堕挓棰戠巼涓� 50MHz
localparam DELAY_COUNT = CLK_FREQ / 2; // 0.5绉掑欢杩熺殑璁℃暟鍊�
    
always @(posedge clk) begin
    if (counter < DELAY_COUNT - 1) begin
        counter <= counter + 1;
        delay_trigger <= 0;
    end else begin
        counter <= 0;
        delay_trigger <= 1; // 瑙﹀彂淇″彿
    end
end
reg [28:0] counter2 = 0; // 璁℃暟鍣�
reg delay_trigger2 = 0;  // 瑙﹀彂淇″彿7
localparam DELAY_COUNT2 = CLK_FREQ*2; // 1绉掑欢杩熺殑璁℃暟鍊�
        
always @(posedge clk) begin
    if (counter2 < DELAY_COUNT2 - 1) begin
        counter2 <= counter2 + 1;
        delay_trigger2 <= 0;
    end else begin
        counter2 <= 0;
        delay_trigger2 <= 1; // 瑙﹀彂淇″彿
    end
end

reg [28:0] counter3 = 0; // 璁℃暟鍣�
reg delay_trigger3 = 0;  // 瑙﹀彂淇″彿7
localparam DELAY_COUNT3 = CLK_FREQ; // 1绉掑欢杩熺殑璁℃暟鍊�
        
always @(posedge clk) begin
    if (counter3 < DELAY_COUNT3 - 1) begin
        counter3 <= counter3 + 1;
        delay_trigger3 <= 0;
    end else begin
        counter3 <= 0;
        delay_trigger3 <= 1; // 瑙﹀彂淇″彿
    end
end

always @(posedge clk ) begin
    if(mode==3'b010&enter) begin
            if(current_player==total_player-1&current==total-1&submit&delay_trigger) begin
              mode_entered <=0;
            end
            if(confirm&delay_trigger) begin
              mode_entered <=1;
            end
    end
end

reg timelimit=0;
always @(posedge clk ) begin
    if(mode==3'b010&enter) begin
            if(confirm&delay_trigger&mode_entered) begin
              finish <=1;
              timelimit=0;
            end
            if(current_time==6'b0) begin
              finish <=1;
              timelimit=1;
            end
     
            if(submit&delay_trigger) begin
              finish <=0;
              
            end 
    end
end
reg [1:0] input_counter = 2'b00;
always @(posedge clk or negedge reset) begin
if(~reset) begin
 for (i = 0; i < 4; i = i + 1) begin
           for (j = 0; j < 50; j = j + 1) begin
               player[i][j] <= 30'b0;  // 娓呯┖姣忎釜 player 鏁扮粍鍏冪礌
           end
       end
end
else begin
    if(mode==3'b010&enter) begin
        if(confirm&delay_trigger) begin
            input_counter <= 2'b00;
        end
        case (question[current][20:18]) //浜旂杩愮畻绫诲瀷鍒嗗埆鎿嶄綔
           3'b001: begin
            case(input_counter)
            2'b00:begin
                 if (change&delay_trigger) begin
                            player[current_player][current][24:17]<=in;
                            input_counter <= input_counter + 1; // 璁℃暟鍔犱竴
                        end
            end
            2'b01:begin
                if (change&delay_trigger) begin
                            player[current_player][current][16:9]<=in;
                            input_counter <= input_counter + 1; // 璁℃暟鍔犱竴
                        end
            end
            2'b10:begin
                if(confirm&delay_trigger|current_time==6'b000000) begin
                            player[current_player][current][29:25]<=5'b10100-current_time;
                            player[current_player][current][8:1]=in;
                            convert_binary(question[current][15:8], question[current][17:16], player[current_player][current][24:1], player[current_player][current][0]);
                            if(timelimit) begin
                                player[current_player][current][0]=0;
                            end
                            input_counter <= 2'b00; // 閲嶇疆璁℃暟鍣�
                        end
            end
           endcase
                end
            3'b010: begin
                    case(input_counter)
            2'b00:begin
                 if (change&delay_trigger) begin
                            player[current_player][current][24:17]<=in;
                            input_counter <= input_counter + 1; // 璁℃暟鍔犱竴
                        end
            end
            2'b01:begin
                if (change&delay_trigger) begin
                            player[current_player][current][16:9]<=in;
                            input_counter <= input_counter + 1; // 璁℃暟鍔犱竴
                        end
            end
            2'b10:begin
                if(confirm&delay_trigger|current_time==6'b000000) begin
                    player[current_player][current][29:25]<=5'b10100-current_time;
                    player[current_player][current][8:1]=in;
                    signed_operation(question[current][15:8], question[current][7:0],question[current][17:16], player[current_player][current][24:1], player[current_player][current][0]);
                    if(timelimit) begin
                                player[current_player][current][0]=0;
                            end
                    input_counter <= 0; // 閲嶇疆璁℃暟鍣�
                end
            end
           endcase
                end
            3'b011: begin
                if(confirm&&delay_trigger|current_time==6'b000000) begin
                    player[current_player][current][29:25]=5'b10100-current_time;
                    player[current_player][current][24:17]=in;
                    shift_operation(question[current][15:8],question[current][7:0],question[current][17:16],in,player[current_player][current][0]);
                    if(timelimit) begin
                                player[current_player][current][0]=0;
                            end
                end
            end
            3'b100: begin
                if(confirm&&delay_trigger|current_time==6'b000000) begin
                    player[current_player][current][29:25]<=5'b10100-current_time;
                player[current_player][current][24:17]<=in;
            bitwise_operation(question[current][15:8],question[current][7:0],question[current][17:16],in,player[current_player][current][0]);
            if(timelimit) begin
                    player[current_player][current][0]=0;
            end
                end
            end
            3'b101: begin
                if(confirm&&delay_trigger|current_time==6'b000000) begin
                    player[current_player][current][29:25]<=5'b10100-current_time;
                player[current_player][current][24:17]<=in;
            logic_operation(question[current][15:8],question[current][7:0],question[current][17:16],in,player[current_player][current][0]);
            if(timelimit) begin
                player[current_player][current][0]=0;
            end
                end
    end
    endcase
    end
end
end

always @(posedge clk) begin
    if(mode==3'b010&enter) begin
    if(finish&submit&delay_trigger) begin
        if(current<total-1) begin
        current<=current+1;
        end
        else begin
        current<=6'b000000;
        end
end
    end
end

always @(posedge clk) begin
    if(mode==3'b010&enter) begin
    if(current==total-1&submit&delay_trigger&finish&mode_entered) begin
        if(current_player<total_player-1) begin
        current_player<=current_player+1;
        end
        else begin
        current_player<=current_player;
        end
end
    end
end

always @(posedge clk) begin
    if(mode==3'b010&enter&delay_trigger2&mode_entered) begin
    case(finish)
    0: begin
        if(current_time>5'b0) begin
        current_time<=current_time-1;
        end
        else begin
        current_time<=5'b11000;
        end
end
    1: begin
        current_time<=5'b11000;
end
endcase
    end
end

  always @(posedge clk) begin
    if(mode==3'b010&enter) begin
    if(mode_entered) begin
    if(current_time>5'b10100&~finish) begin
        if(current_time==5'b11000) begin
            seg3<=digit_to_seg1((current+1)/10);
            seg4<=digit_to_seg1((current+1)%10);
        end
        else begin
        if(delay_trigger3) begin
            if(seg3==Blank) begin
             seg3<=digit_to_seg1((current+1)/10);
            end
            else begin
            seg3<=Blank;
            end
            if(seg4==Blank) begin
             seg4<=digit_to_seg1((current+1)%10);
            end
            else begin
            seg4<=Blank;
            end
        end
        end
    end
    else begin
        if(question[current][20:18]==3'b001|question[current][20:18]==3'b010) begin
    seg3<=digit_to_seg1(input_counter+1);
    seg4<=digit_to_seg1(input_counter+1);
    end
    else begin
        seg3<=digit_to_seg1((current+1)/10);
        seg4<=digit_to_seg1((current+1)%10);
    end
    end
    if(current_time>5'b10100) begin
        seg7<=Blank;
        seg8<=Blank;
    end
    else begin
        seg7<=digit_to_seg1(current_time/10);
        seg8<=digit_to_seg1(current_time%10);
    end
    seg1<=digit_to_seg1(total/10);
    seg2<=digit_to_seg1(total%10);
    seg5<=digit_to_seg1(question[current][20:18]);
    seg6<=digit_to_seg1(question[current][17:16]+1);
    led1<=question[current][15:8];
    led2<=question[current][7:0];
    end
    else begin
        seg1=digit_to_seg1(2);
        seg2=Blank;
        seg3=Blank;
        seg4=Blank;
        seg5=Blank;
        seg6=Blank;
        seg7=Blank;
        seg8=Blank;
        led1=Blank;
        led2=Blank;
    end
  end
  end

task convert_binary;
    input [7:0] bin_value; // 杈撳叆鐨勪簩杩涘埗鍊�
    input [1:0] op;
    input [23:0] answer;
    output check;
    reg [23:0] result;
    reg [3:0] octal_hundreds_out; // 鍏繘鍒剁櫨浣嶈緭鍑�
    reg [3:0] octal_tens_out;     // 鍏繘鍒跺崄浣嶈緭鍑�
    reg [3:0] octal_ones_out;     // 鍏繘鍒朵釜浣嶈緭鍑�
    
    reg [3:0] decimal_hundreds_out; // 鍗佽繘鍒剁櫨浣嶈緭鍑�
    reg [3:0] decimal_tens_out;     // 鍗佽繘鍒跺崄浣嶈緭鍑�
    reg [3:0] decimal_ones_out;     // 鍗佽繘鍒朵釜浣嶈緭鍑�

    reg [3:0] hex_high_out;         // 鍗佸叚杩涘埗楂樹綅杈撳嚭
    reg [3:0] hex_low_out;          // 鍗佸叚杩涘埗浣庝綅杈撳嚭

    begin
    
     // 鍏繘鍒惰浆鎹㈤�昏緫
        octal_hundreds_out = bin_value / 64;
        octal_tens_out     = (bin_value / 8) % 8;
        octal_ones_out     = bin_value % 8;

        // 鍗佽繘鍒惰浆鎹㈤�昏緫
        decimal_hundreds_out = bin_value / 100;
        decimal_tens_out     = (bin_value / 10) % 10;
        decimal_ones_out     = bin_value % 10;

        // 鍗佸叚杩涘埗杞崲閫昏緫
        hex_high_out = bin_value[7:4];
        hex_low_out  = bin_value[3:0];

    case(op)
        2'b00: begin
            result[19:16]= octal_hundreds_out;
            result[11:8]=octal_tens_out;
            result[3:0]=octal_ones_out;
        end
        2'b01: begin
            result[19:16]= decimal_hundreds_out;
            result[11:8]=decimal_tens_out;
            result[3:0]=decimal_ones_out;
        end
        2'b10: begin
            result[11:8]=hex_high_out;
            result[3:0]=hex_low_out;
        end
        default: result = 24'b0; // 榛樿鍊�
    endcase
    check = (result==answer);
    end
endtask


task signed_operation;
    input [7:0] a;        // 杈撳叆鐨勪簩杩涘埗鍊�
    input [7:0] b;
    input [1:0] op;
    input [23:0] answer;
    output check;
    
    reg [23:0] r;
    reg signed [7:0] result;  // 淇敼涓� signed 绫诲瀷锛�8 浣嶅甫绗﹀彿鏁�
    reg [7:0] abs_result;     // 鐢� 8 浣嶆潵瀛樺偍缁濆鍊�
    reg sign;                 // sign 鏄鍙蜂綅
    reg [3:0] hundreds, tens, ones; // 4 浣嶄互澶勭悊鐧句綅銆佸崄浣嶃�佷釜浣�

    begin
        // 璁＄畻缁撴灉
        case(op)
            2'b00: begin
                result = a + b;  // 鍔犳硶
            end
            2'b01: begin
                result = a - b;  // 鍑忔硶
            end
            default: result = 8'b00000000;  // 榛樿鎯呭喌
        endcase

        sign = result[7];  // 鑾峰彇绗﹀彿浣�

        // 璁＄畻缁濆鍊硷紝璐熸暟鏃跺彇琛ョ爜
        if (sign == 1'b1) 
            abs_result = ~result + 1;  // 璐熸暟锛屽彇琛ョ爜
        else
            abs_result = result;      // 姝ｆ暟锛岀洿鎺ヨ祴鍊�

        // 璁＄畻鐧句綅銆佸崄浣嶃�佷釜浣�
        hundreds = abs_result / 100;        // 鐧句綅
        tens = (abs_result / 10) % 10;      // 鍗佷綅
        ones = abs_result % 10;             // 涓綅

        // 鎷兼帴鎴愭渶缁堢殑24浣嶆暟
        r[23] = sign;  // 绗﹀彿浣�
        r[19:16] = hundreds;  // 鐧句綅
        r[11:8] = tens;       // 鍗佷綅
        r[3:0] = ones;        // 涓綅

        // 姣旇緝璁＄畻缁撴灉涓庢湡鏈涚殑绛旀
        check = (r == answer);
    end
endtask

task shift_operation;
    input signed [7:0] a;    // 杈撳叆鐨� 8 浣嶆湁绗﹀彿鏁帮紙绠楁湳绉讳綅鐢級
    input [7:0] b;           // 杈撳叆鐨勬棤绗﹀彿鏁帮紝琛ㄧず绉讳綅鐨勪綅鏁帮紙鑼冨洿 0~7锛�
    input [1:0] op;          // 閫夋嫨妯″紡
    input [7:0] answer;
    output reg  check; 
    reg [7:0] result;
begin
    // 鏍规嵁鎿嶄綔浠ｇ爜杩涜鐩稿簲鐨勪綅绉绘搷浣�
    case(op)
        2'b00: result = a <<< b;  // 绠楁湳宸︾Щ
        2'b01: result = a >>> b;  // 绠楁湳鍙崇Щ
        2'b10: result = a << b;   // 閫昏緫宸︾Щ
        2'b11: result = a >> b;   // 閫昏緫鍙崇Щ
        default: result = 8'b00000000; // 榛樿鍊�
    endcase
    check = (result==answer);
end
 
endtask

task bitwise_operation;
    input [7:0] op_a;     // 浠诲姟杈撳叆a
    input [7:0] op_b;     // 浠诲姟杈撳叆b
    input [1:0] operation; // 鎿嶄綔鐮�
    input [7:0] answer;
    output reg  check; 
    reg [7:0] result;

    begin
        case (operation)
            2'b00: result = op_a & op_b;  // 涓庢搷浣�
            2'b01: result = op_a | op_b;  // 鎴栨搷浣�
            2'b10: result = ~op_a;         // 闈炴搷浣�
            2'b11: result = op_a ^ op_b;  // 寮傛垨鎿嶄綔
            default: result = 8'b0;          // 榛樿鎯呭喌
        endcase
        check = (result==answer);
    end
endtask

task logic_operation;
    input [7:0] op_a;       // 浠诲姟杈撳叆a
    input [7:0] op_b;       // 浠诲姟杈撳叆b
    input [1:0] operation;   // 鎿嶄綔鐮�
    input [7:0] answer;
    output reg  check; 
    reg [7:0] result;

    begin
        case (operation)
            2'b00: result = {8{(op_a != 0) && (op_b != 0)}}; // 閫昏緫涓庢搷浣�
            2'b01: result = {8{(op_a != 0) || (op_b != 0)}}; // 閫昏緫鎴栨搷浣�
            2'b10: result = {8{!(op_a != 0)}};               // 閫昏緫闈炴搷浣�
            2'b11: result = {8{(op_a != 0) ^ (op_b != 0)}}; // 閫昏緫寮傛垨鎿嶄綔
            default: result = 8'b0;                          // 榛樿鎯呭喌
        endcase
        check = (result==answer);
    end
endtask
endmodule
