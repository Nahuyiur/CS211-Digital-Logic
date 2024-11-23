module decoder2_tb();
    reg [3:0] sin;
    wire [15:0] sout;
    decoder2 u(.in(sin),.out(sout));
    initial 
    begin
        sin=4'b0000;
        repeat(15) #10 sin=sin+1;
        #10 $finish;
    end
endmodule
