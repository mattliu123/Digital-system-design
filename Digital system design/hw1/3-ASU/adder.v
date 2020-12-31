module adder(x, y, carry, out);
input [7:0] x, y;
output carry;
output [7:0] out;
wire [8:0] sum;
/*Write your code here*/
assign sum = x+y;
assign carry = sum[8];
assign out = sum[7:0];

/*End of code*/

endmodule