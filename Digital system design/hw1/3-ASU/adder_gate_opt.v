module adder_gate(x, y, carry, out);
input [7:0] x, y;
output carry;
output [7:0] out;
wire c1, c2, c3, c4, c5, c6, c7;
wire t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17, t18, t19, t20;
wire [7:0] p, g;
/*Write your code here*/
xor #1 x0(p[0], x[0], y[0]);
xor #1 x1(p[1], x[1], y[1]);
xor #1 x2(p[2], x[2], y[2]);
xor #1 x3(p[3], x[3], y[3]);
xor #1 x4(p[4], x[4], y[4]);
xor #1 x5(p[5], x[5], y[5]);
xor #1 x6(p[6], x[6], y[6]);
xor #1 x7(p[7], x[7], y[7]);

and #1 b0(g[0], x[0], y[0]);
and #1 b1(g[1], x[1], y[1]);
and #1 b2(g[2], x[2], y[2]);
and #1 b3(g[3], x[3], y[3]);
and #1 b4(g[4], x[4], y[4]);
and #1 b5(g[5], x[5], y[5]);
and #1 b6(g[6], x[6], y[6]);
and #1 b7(g[7], x[7], y[7]);

and #1 aa1(t0, p[1], g[0]);
and #1 aa2(t1, p[2], g[1]);
and #1 aa3(t2, p[2], p[1], g[0]);
and #1 aa4(t3, p[3], g[2]);
and #1 aa5(t4, p[3], p[2], g[1]);
and #1 aa6(t5, p[3], p[2], p[1], g[0]);
and #1 aa7(t6, p[4], g[3]);
and #1 aa8(t7, p[4], p[3], g[2]);
and #1 aa9(t8, p[4], p[3], p[2], g[1]);
and #1 aa10(t9, p[4], p[3], p[2], p[1], g[0]);
and #1 aa11(t10, p[5], g[4]);
and #1 aa12(t11, p[5], p[4], g[3]);
and #1 aa13(t12, p[5], p[4], p[3], g[2]);
and #1 aa14(t13, p[5], p[4], p[3], p[2], g[1]);
and #1 aa15(t14, p[5], p[4], p[3], p[2], p[1], g[0]);
and #1 aa16(t15, p[6], g[5]);
and #1 aa17(t16, p[6], p[5], g[4]);
and #1 aa18(t17, p[6], p[5], p[4], g[3]);
and #1 aa19(t18, p[6], p[5], p[4], p[3], g[2]);
and #1 aa20(t19, p[6], p[5], p[4], p[3], p[2], g[1]);
and #1 aa21(t20, p[6], p[5], p[4], p[3], p[2], p[1], g[0]);

or #1 or1(c1, g[0], 0);
or #1 or2(c2, g[1], t0);
or #1 or3(c3, g[2], t1, t2);
or #1 or4(c4, g[3], t3, t4, t5);
or #1 or5(c5, g[4], t6, t7, t8, t9);
or #1 or6(c6, g[5], t10, t11, t12, t13, t14);
or #1 or7(c7, g[6], t15, t16, t17, t18, t19, t20);




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