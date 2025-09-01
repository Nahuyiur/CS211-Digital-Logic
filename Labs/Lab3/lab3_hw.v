module lab3_hw(
    input x,
    input y,
    input z,
    output o1,
    output o2,
    output o3
);
    assign o1=(~x&~y&~z)|(~x&y&z)|(x&~y&~z)|(x&~y&z)|(x&y&z);
    assign o2=(~y&~z)|(x&z)|(y&z);
    assign o3=(x|y|~z)&(~y|z);
    
endmodule