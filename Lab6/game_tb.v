module game_tb();
    reg [1:0]in1_tb;
    reg [1:0]in2_tb;
    wire o1_tb,o2_tb,o3_tb;
    
    game dut(
      .in1(in1_tb),  
      .in2(in2_tb),  
      .o1(o1_tb),
      .o2(o2_tb),
      .o3(o3_tb)
    );
initial begin
in1_tb = 2'b00; in2_tb = 2'b00; #10;
in1_tb = 2'b00; in2_tb = 2'b01; #10;
in1_tb = 2'b00; in2_tb = 2'b10; #10;
in1_tb = 2'b00; in2_tb = 2'b11; #10;
in1_tb = 2'b01; in2_tb = 2'b00; #10;
in1_tb = 2'b01; in2_tb = 2'b01; #10;
in1_tb = 2'b01; in2_tb = 2'b10; #10;
in1_tb = 2'b01; in2_tb = 2'b11; #10;
in1_tb = 2'b10; in2_tb = 2'b00; #10;
in1_tb = 2'b10; in2_tb = 2'b01; #10;
in1_tb = 2'b10; in2_tb = 2'b10; #10;
in1_tb = 2'b10; in2_tb = 2'b11; #10;
in1_tb = 2'b11; in2_tb = 2'b00; #10;
in1_tb = 2'b11; in2_tb = 2'b01; #10;
in1_tb = 2'b11; in2_tb = 2'b10; #10;
in1_tb = 2'b11; in2_tb = 2'b11; #10;
#10 $finish;
    end
endmodule