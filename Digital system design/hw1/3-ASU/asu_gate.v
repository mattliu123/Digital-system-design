module asu_gate (x, y, mode, carry, out);
input [7:0] x, y;
input mode;
output carry;
output [7:0] out;
wire [7:0] out1, out2;
wire c;
/*Write your code here*/
barrel_shifter_gate bs(.in(x), .shift(y[2:0]), .out(out1));
adder_gate add(.x(x), .y(y), .carry(c), .out(out2));
assign #2.5 out = mode?out2:out1;
assign #2.5 carry = mode?c:0;

/*End of code*/


endmodule