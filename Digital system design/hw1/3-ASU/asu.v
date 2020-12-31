module asu (x, y, mode, carry, out);
input [7:0] x, y;
input mode;
output carry;
output [7:0] out;
wire [7:0] out1, out2;
wire c;
/*Write your code here*/
barrel_shifter bs(.in(x), .shift(y[2:0]), .out(out1));
adder add(.x(x), .y(y), .carry(c), .out(out2));
assign out = mode?out2:out1;
assign carry = mode?c:0;
/*End of code*/


endmodule