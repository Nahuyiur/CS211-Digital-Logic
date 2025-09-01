module bcd_valid_check_tb();
    reg [3:0] in_tb;
    wire valid_p1_tb,valid_p2_tb;
    
    bcd_valid_check_p1 dut1(
        .bcd_din(in_tb),
        .bcd_valid(valid_p1_tb)
    );
    bcd_valid_check_p2 dut2(
        .bcd_din(in_tb),
        .bcd_valid(valid_p2_tb)
    );
    initial $monitor("%d %d %d",in_tb, valid_p1_tb, valid_p2_tb);
    initial begin 
        for (in_tb = 4'b0000; in_tb <= 4'b1111; in_tb = in_tb + 1) begin
              #10; 
        end
    end
    initial begin
        #160 $finish;
    end    
endmodule