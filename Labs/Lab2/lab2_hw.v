module lab2_hw(
    input x,
    input y,
    input z,
    output out
   );
    wire notx,noty,notz;
    wire out1,out2,out3;
    
    not nx(notx,x);
    not ny(noty,y);
    not nz(notz,z);
    
    and and1(out1,notx,noty,z);
    and and2(out2,notx,y,z);
    and and3(out3,x,noty);
    
    or u4(out,out1,out2,out3);
 
endmodule
