module shift_operation(
    input signed [7:0] a,    // 输入的 8 位有符号数（算术移位用）
    input [2:0] b,           // 输入的无符号数，表示移位的位数（范围 0~7）
    input []op,
    output reg [7:0] result  // 算术左移结果
);
    always @(*) begin
        case(op)
            
        endcase
    end