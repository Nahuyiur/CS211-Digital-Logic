module game(
    input wire [1:0] p1,  
    input wire [1:0] p2, 
    output wire o1,       
    output wire o2,   
    output wire o3,   
    output wire tub_sel1,
    output wire tub_sel2,
    output wire [7:0] tub_control1,
    output wire [7:0] tub_control2
);
    comparator comp_inst (
        .p1(p1),
        .p2(p2),
        .o1(o1),
        .o2(o2),
        .o3(o3)
    );
    
    display_decoder1 dec1_inst (
        .p1(p1),
        .tub_control1(tub_control1)
    );
    
    display_decoder2 dec2_inst (
        .p2(p2),
        .tub_control2(tub_control2)
    );
    
    assign tub_sel1 = 1'b1;
    assign tub_sel2 = 1'b1;
    
endmodule
