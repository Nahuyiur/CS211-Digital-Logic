module lab8 (
    input wire clk,
    input wire reset,
    input wire t,
    output reg q
);

    always @(posedge clk or posedge reset) begin
        if (~reset) begin
            q <= 1'b0;
        end else begin
            q <= t ? ~q : q;
        end
    end

endmodule