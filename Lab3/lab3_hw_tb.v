module lab3_hw_tb();
reg tb_x;
reg tb_y;
reg tb_z;

wire tb_o1;
wire tb_o2;
wire tb_o3;

lab3_hw dut(
    .x(tb_x),
    .y(tb_y),
    .z(tb_z),
    .o1(tb_o1),
    .o2(tb_o2),
    .o3(tb_o3)
);
initial begin
    #10 tb_x=1'b0;tb_y=1'b0;tb_z=1'b0;
    #10 tb_x=1'b1;tb_y=1'b0;tb_z=1'b0;
    #20 tb_x=1'b1;tb_y=1'b1;tb_z=1'b0;
    #30 tb_x=1'b0;tb_y=1'b1;tb_z=1'b0;
    #40 tb_x=1'b0;tb_y=1'b1;tb_z=1'b1;
    #50 tb_x=1'b0;tb_y=1'b0;tb_z=1'b1;
    #60 tb_x=1'b1;tb_y=1'b0;tb_z=1'b1;
    #70 tb_x=1'b1;tb_y=1'b1;tb_z=1'b1;
end
initial #80 $finish;
endmodule