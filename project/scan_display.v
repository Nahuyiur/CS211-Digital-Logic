module scan_display (
    input clk,                   // 输入时钟信号
    output reg [7:0] anode,      // 数码管使能信号（动态扫描）
    output reg [7:0] seg1,
    output reg [7:0] seg2         // 当前激活数码管的段信号
);

    reg [2:0] current_digit = 0; 
  reg [20:0] counter = 0;       

    // 每个数码管显示的内容 (静态定义)
    wire [7:0] data1 = 8'b1111_1100; 
    wire [7:0] data2 = 8'b0110_0000; 
    wire [7:0] data3 =8'b1101_1010; // 显示 "2"
    wire [7:0] data4 = 8'b1111_0010; // 显示 "3"
    wire [7:0] data5 =8'b0110_0110; // 显示 "4"
    wire [7:0] data6 = 8'b1011_0110; // 显示 "5"
    wire [7:0] data7 = 8'b1011_1110; // 显示 "6"
    wire [7:0] data8 = 8'b1110_0000; // 显示7

 
   always @(posedge clk) begin
            counter <= counter + 1;
            if (counter == 10000) begin // 每 1 ms 触发一次 (100 MHz 时钟)
                counter <= 0;
                current_digit <= current_digit + 1; // 切换到下一个数码管
                if (current_digit == 7)
                    current_digit <= 0; // 循环激活数码管
            end
        end

    
    
    always @(*) begin
     
       anode = 8'b0000_0000;             
           anode[current_digit] = 1;       
        
        case (current_digit)
            3'd0: seg1 = data1;
            3'd1: seg1 = data2; // 显示 "1"
            3'd2: seg1 = data3; // 显示 "2"
            3'd3: seg1 = data4; // 显示 "3"
            3'd4: seg2 = data5; // 显示 "4"
            3'd5: seg2 = data6; // 显示 "5"
            3'd6: seg2 = data7; // 显示 "6"
            3'd7: seg2 = data8; // 显示7
           default: begin
                           seg1 = 8'b1111_1111;      // 默认不显示内容
                           seg2 = 8'b1111_1111;
                       end // 默认不显示任何内容
        endcase
    end

endmodule
