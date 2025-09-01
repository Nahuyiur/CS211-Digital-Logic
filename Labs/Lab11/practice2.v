module practice2(
input [4:0] x_in,
input  clk,
output reg y_out
    );
 reg [3:0] count; 
  
 always @(posedge clk) begin
   count <= count + x_in[0] + x_in[1] + x_in[2] + x_in[3] + x_in[4];
        end
    always @(posedge clk) begin
            if (count % 5 == 0)
                y_out <= 1'b1;  
            else
                y_out <= 1'b0;  
        end   
    
    
endmodule