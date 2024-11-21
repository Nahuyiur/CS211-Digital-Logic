module lab4_tb();
    reg x_tb;
    reg y_tb;
    reg z_tb;
    wire sop_tb;
    wire pos_tb;

    lab4 dut(
        .x(x_tb),
        .y(y_tb),
        .z(z_tb),
        .sop(sop_tb),
        .pos(pos_tb)
    );   
    initial begin
    {x_tb,y_tb,z_tb}=3'b0;
    repeat(7) begin
        #100 {x_tb,y_tb,z_tb}={x_tb,y_tb,z_tb}+1;
    end
    #100 $finish();
 end
 endmodule