module practice3(
    input clk,
    input rst,
    input x_in,
    output reg [2:0] state
);
    reg [2:0] next_state;

    always @(posedge clk)begin
        if(!rst)begin
            state<=3'b001;
        end else begin
            state<=next_state;
        end
    end

    always @(*)begin
        if(x_in)begin
            case(state)
                3'b001:next_state=3'b010;
                3'b010:next_state=3'b100;
                3'b100:next_state=3'b001;
                default:
                next_state=3'b001;
            endcase
        end else begin
            next_state=<=state;
        end
    end
endmodule