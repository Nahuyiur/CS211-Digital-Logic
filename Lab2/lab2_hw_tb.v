module lab2_hw_tb();

reg tb_x;
reg tb_y;
reg tb_z;

wire tb_out;

lab2_hw dut(
    .x(tb_x),
    .y(tb_y),
    .z(tb_z),
    .out(tb_out)
    );

initial begin
    tb_x=1'b0;tb_y=1'b0;tb_z=1'b0;
    #10 tb_x=1'b1;tb_y=1'b0;tb_z=1'b0;
    #20 tb_x=1'b1;tb_y=1'b1;tb_z=1'b0;
    #30 tb_x=1'b0;tb_y=1'b1;tb_z=1'b0;
    #40 tb_x=1'b0;tb_y=1'b1;tb_z=1'b1;
    #50 tb_x=1'b0;tb_y=1'b0;tb_z=1'b1;
    #60 tb_x=1'b1;tb_y=1'b0;tb_z=1'b1;
    #70 tb_x=1'b1;tb_y=1'b1;tb_z=1'b1;
end

endmodule