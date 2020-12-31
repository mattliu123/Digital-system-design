//RTL (use continuous assignment)
module alu_assign(
    ctrl,
    x,
    y,
    carry,
    out  
);
    
    input  [3:0] ctrl;
    input  [7:0] x;
    input  [7:0] y;
    output       carry;
    output [7:0] out;
    wire carry2, carry3;
    wire [7:0] out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12, out13, out14, out15, out16, out17;
    
    assign {carry2,out2} = (ctrl==4'b0000)?({x[7],x}+{y[7],y}):9'bx;
    assign {carry3,out3} = (ctrl==4'b0001)?({x[7],x}-{y[7],y}):{carry2,out2};
    assign out4 = (ctrl==4'b0010)?x&y:out3;
    assign out5 = (ctrl==4'b0011)?x|y:out4;
    assign out6 = (ctrl==4'b0100)?~x:out5;
    assign out7 = (ctrl==4'b0101)?x^y:out6;
    assign out8 = (ctrl==4'b0110)?~(x|y):out7;
    assign out9 = (ctrl==4'b0111)?y<<x[2:0]:out8;
    assign out10 = (ctrl==4'b1000)?y>>x[2:0]:out9;
    assign out11 = (ctrl==4'b1001)?{x[7],x[7:1]}:out10;
    assign out12 = (ctrl==4'b1010)?{x[6:0],x[7]}:out11;
    assign out13 = (ctrl==4'b1011)?{x[0],x[7:1]}:out12;
    assign out14 = (ctrl==4'b1100)?((x==y)?1:0):out13;
    assign out15 = (ctrl==4'b1101)?0:out14;
    assign out16 = (ctrl==4'b1110)?0:out15;
    assign out17 = (ctrl==4'b1111)?0:out16;
    assign out = out17;
    assign carry = carry3;
endmodule
