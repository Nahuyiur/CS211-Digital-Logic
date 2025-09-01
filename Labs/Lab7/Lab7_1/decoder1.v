module decoder1(
    input [3:0] in,
    output [15:0] out
);
    wire [7:0]out1,out2;
    decoder3_8 u0(in[3],in[2],in[1],in[0],out1);
    decoder3_8 u1(in[3],in[2],in[1],(~in[0]),out2);
    assign out={out2,out1};
endmodule