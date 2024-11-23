module Initialization (
    input wire clk,
    input wire reset,
    output reg init_clear                              


);
always @(posedge clk or posedge reset) begin
        if (~reset) begin
            init_clear <= 1'b1;
        end else begin
            init_clear <= 1'b0;
        end
    end


    
endmodule