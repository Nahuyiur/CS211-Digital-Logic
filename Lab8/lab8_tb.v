module lab8_tb;
    reg clk;
    reg T;
    reg reset;
    wire Q;

    // 实例化 T 触发器模块
    T_flipflop_with_reset uut (
        .clk(clk),
        .T(T),
        .reset(reset),
        .Q(Q)
    );

    // 时钟信号生成
    always #5 clk = ~clk;

    initial begin
        // 初始化信号
        clk = 0;
        T = 0;
        reset = 0;
        
        // 测试复位功能
        reset = 1;
        #10;
        reset = 0;

        // 测试 T 触发器功能
        T = 1;
        #10;
        T = 0;
        #10;
        T = 1;
        #10;
        
        $finish;
    end
endmodule
