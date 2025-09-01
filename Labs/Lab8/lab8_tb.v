module lab8_tb;
    reg clk;
    reg T;
    reg reset;
    wire Q;

    // ʵ���� T ������ģ��
    T_flipflop_with_reset uut (
        .clk(clk),
        .T(T),
        .reset(reset),
        .Q(Q)
    );

    // ʱ���ź�����
    always #5 clk = ~clk;

    initial begin
        // ��ʼ���ź�
        clk = 0;
        T = 0;
        reset = 0;
        
        // ���Ը�λ����
        reset = 1;
        #10;
        reset = 0;

        // ���� T ����������
        T = 1;
        #10;
        T = 0;
        #10;
        T = 1;
        #10;
        
        $finish;
    end
endmodule
