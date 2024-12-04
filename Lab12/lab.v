module Lab(
    input clk,
    input rst,
    output led
);
    reg[13:0] count1, count2;

    always @(posedge clk or negedge rst) begin
        if(!rst)
            count1 <= 14'd0;
        else if(count1 == 14'd10000)
            count1 <= 14'd0;
        else
            count1 <= count1 + 1'b1;
    end

    always @(posedge clk or negedge rst) begin
        if(!rst)
            count2 <= 14'd0;
        else if(count1 == 14'd10000)  // count2 increments when count1 reaches 10000
            count2 <= count2 + 1'b1;
    end

    assign led = (count2 > 14'd5000);  // LED on when count2 reaches 10000

endmodule
