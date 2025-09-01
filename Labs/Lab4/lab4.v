module lab4(
    input x,
    input y,
    input z,
    output sop,
    output pos
);
assign sop=(~x&y&~z)|(x&~y&~z)|(~x&~y&z)|(x&y&z);
assign pos=(x|~y|~z)&(~x|~y|z)&(~x|y|~z)&(x|y|z);
endmodule