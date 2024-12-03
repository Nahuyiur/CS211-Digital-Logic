module cal_display (
    input clk,               // ʱ������
    input confirm,
    input exit,
    input [2:0] in1,         // ����ĵ�һ��3λ�޷�����
    input [2:0] in2,         // ����ĵڶ���3λ�޷�����
    
    output reg [7:0] Seg2,
    output reg [7:0] Seg1,
    output reg [7:0] anode,
    output reg [7:0] leds // LED���
);
    // ����ܵ���ʾ���ݼĴ���
    reg [7:0] seg2, seg3, seg4;
    reg [7:0] seg6, seg7, seg8;

    // ��ǰ��ʾ�����������
    reg [2:0] current_digit = 0;   
    reg [20:0] counter1 ; 

    // ��ť��ʱ����
    reg delay_trigger = 0;  
    reg is_confirm = 1'b0;

    // ����ܵ���ʾ��
    parameter Num0 = 8'b1111_1100; // "0"
    parameter Num1 = 8'b0110_0000; // "1"
    parameter Blank = 8'b0000_0000; // �հ�
    
    // ����ת7����ʾ����ĺ���
    function [7:0] digit_to_seg;
        input [3:0] digit; 
        begin
            case (digit)
                4'd0: digit_to_seg = Num0; // ��ʾ "0"
                4'd1: digit_to_seg = Num1; // ��ʾ "1"
                default: digit_to_seg = Blank; // �հ�
            endcase
        end
    endfunction
    
    // ��������ת��Ϊ��ʾ�źţ�ֻ��Ҫһ�� always ��������
    always @(in1, in2) begin
        seg2 = digit_to_seg(in1[2]);
        seg3 = digit_to_seg(in1[1]);
        seg4 = digit_to_seg(in1[0]);
        
        seg6 = digit_to_seg(in2[2]);
        seg7 = digit_to_seg(in2[1]);
        seg8 = digit_to_seg(in2[0]);
    end
    
    // ��ť����ʱ�����
    reg [24:0] counter = 0; // ������
    reg delay_trigger = 0;  // �����ź�
    localparam CLK_FREQ = 50000000; // ����ʱ��Ƶ��Ϊ 50MHz
    localparam DELAY_COUNT = CLK_FREQ / 2; // 0.5���ӳٵļ���ֵ
    
    always @(posedge clk) begin
        if (counter < DELAY_COUNT - 1) begin
            counter <= counter + 1;
            delay_trigger <= 0;
        end else begin
            counter <= 0;
            delay_trigger <= 1; // �����ź�
        end
    end
    
    // ���������ɨ����ʾ
    always @(posedge clk) begin
        counter1 <= counter1 + 1;
        if (counter1 == 10000) begin // ÿ 1 ms ����һ�� (100 MHz ʱ��)
            counter1 <= 0;
            current_digit <= current_digit + 1; // �л�����һ�������
            if (current_digit == 7)
                current_digit <= 0; // ѭ�����������
        end
    end
    
    // ��ťȷ�ϴ����߼�
    always @(posedge clk) begin
        if (delay_trigger && confirm) begin
            case(is_confirm)
                1'b0: is_confirm = 1'b1;
                1'b1: begin 
                    is_confirm = 1'b0;
                    store = S0;
                end
                default: is_confirm = 1'b0;
            endcase
        end
    end
    
    // ״̬��
    parameter S0 = 2'b00;
    parameter S1 = 2'b01;
    parameter S2 = 2'b10;
    parameter S3 = 2'b11;
    
    reg [7:0] result;
    reg [1:0] store = S0;
    
    always @(posedge clk) begin
        if (is_confirm) begin
            case(store)
                S1: begin 
                    result <= result + in1 * in2[0];
                    leds <= result;
                end
                S2: begin
                    result <= result + in1 * in2[1];
                    leds <= result;
                end
                S3: begin
                    result <= result + in1 * in2[2];
                    leds <= result;
                end
                S0: begin
                    result <= 0;
                    leds <= result;
                end
                default: store <= store;
            endcase
        end
    end
    
    // ״̬����ʱ��
    localparam MAX_COUNT = 300_000_000;
    reg [28:0] cnt;
    always @(posedge clk) begin
        if (is_confirm) begin
            if (cnt < MAX_COUNT - 1) begin
                cnt <= cnt + 1;
            end else begin
                cnt <= 0;  // ���ü����� 
                case(store)
                    S0: begin
                        store <= S1;
                        cnt <= MAX_COUNT - 10;
                    end
                    S1: begin
                        store <= S2;
                    end
                    S2: begin
                        store <= S3;
                    end
                    S3: begin
                    end
                    default: store <= S0;
                endcase
            end
        end
    end

    // ��ʾɨ������
    reg [7:0] seg1_tmp, seg2_tmp;
        
    // ����ʾ�źŴ��ݸ�ʵ�ʵ����
    always @(posedge clk) begin
        display_scan(seg2, seg3, seg4, seg6, seg7, seg8, current_digit, anode, seg1_tmp, seg2_tmp);
        Seg1 <= seg1_tmp;
        Seg2 <= seg2_tmp;
    end

    // ��ʾɨ���������
    task display_scan;
        input [7:0] data2;
        input [7:0] data3;
        input [7:0] data4;
        input [7:0] data6;
        input [7:0] data7;
        input [7:0] data8;
        input [2:0] current_digit;   // ��ǰ��ʾ����������� (0-7)
        output reg [7:0] anode;       // �����ʹ���źţ���̬ɨ�裩
        output reg [7:0] seg1;        // ��һ������ܵ���ʾ����
        output reg [7:0] seg2;        // �ڶ�������ܵ���ʾ����
    begin
        // ��ʼ��ʹ���źţ��ر����������
        anode = 8'b0000_0000;         
        anode[current_digit] = 1;     // ʹ�ܵ�ǰ�������ڵ������
        
        // ���ݵ�ǰ���������ѡ����ʾ������
        case (current_digit)
            3'd1: seg1 = data2;    // ��ʾ data2
            3'd2: seg1 = data3;    // ��ʾ data3
            3'd3: seg1 = data4;    // ��ʾ data4
            3'd5: seg2 = data6;    // ��ʾ data6
            3'd6: seg2 = data7;    // ��ʾ data7
            3'd7: seg2 = data8;    // ��ʾ data8
            default: begin
                seg1 = 8'b1111_1111;   // Ĭ�ϲ���ʾ����
                seg2 = 8'b1111_1111;
            end
        endcase
    end
    endtask

endmodule
