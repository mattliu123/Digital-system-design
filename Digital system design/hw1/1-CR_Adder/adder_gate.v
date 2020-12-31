module adder_gate(x, y, carry, out);
input [7:0] x, y;
output carry;
output [7:0] out;
wire c1, c2, c3, c4, c5, c6, c7;
/*Write your code here*/
full_adder full_adder0(.a(x[0]), .b(y[0]), .cin(0), .sum(out[0]), .cout(c1));
full_adder full_adder1(.a(x[1]), .b(y[1]), .cin(c1), .sum(out[1]), .cout(c2));
full_adder full_adder2(.a(x[2]), .b(y[2]), .cin(c2), .sum(out[2]), .cout(c3));
full_adder full_adder3(.a(x[3]), .b(y[3]), .cin(c3), .sum(out[3]), .cout(c4));
full_adder full_adder4(.a(x[4]), .b(y[4]), .cin(c4), .sum(out[4]), .cout(c5));
full_adder full_adder5(.a(x[5]), .b(y[5]), .cin(c5), .sum(out[5]), .cout(c6));
full_adder full_adder6(.a(x[6]), .b(y[6]), .cin(c6), .sum(out[6]), .cout(c7));
full_adder full_adder7(.a(x[7]), .b(y[7]), .cin(c7), .sum(out[7]), .cout(carry));

/*End of code*/

endmodule

module full_adder(a, b, cin, sum, cout);
	input a, b, cin;
	output sum;
	output cout;
	wire x1, x2, x3;
	xor #1 xora(x1, a, b);
	and #1 anda(x2, x1, cin);
	and #1 andb(x3, a, b);
	xor #1 xorb(sum, x1, cin);
	or #1 ora(cout, x2, x3);
endmodule