module shift_operation(
    input signed [7:0] a,    // 输入的 8 位有符号数（算术移位用）
    input [7:0] b,           // 输入的无符号数，表示移位的位数（范围 0~7）
    input [3:0] op,          // 选择模式
    output reg [7:0] result // 算术左移结果

);
    always @(*) begin
        case(op)
            4'b0001: result=a<<<b;
            4'b0010: result=a>>>b;
            4'b0100: result=a<<b;
            4'b1000: result=a>>b;
            default: result=8'b0000_0000;
        endcase
    end

endmodule