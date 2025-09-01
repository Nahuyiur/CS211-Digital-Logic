module lab5(
    input [1:0] in1,
    input [1:0] in2,
    output reg o1, 
    output reg o2,
    output reg o3
);

always @(in1,in2) begin
    case({in1,in2})
   4'b0001,4'b0110,4'b1000:
   {o1,o2,o3} = 3'b100;
   4'b0100,4'b1001,4'b0010:
       {o1,o2,o3} = 3'b010;
   4'b0000,4'b0101,4'b1010:
       {o1,o2,o3} = 3'b001;
     default:
       {o1,o2,o3} = 3'b000;
  endcase
end
endmodule