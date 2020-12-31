module barrel_shifter_gate(in, shift, out);
input  [7:0] in;
input  [2:0] shift;
output [7:0] out;
wire t0, t1, t2, t3, t4, t5, t6, t7;
wire d0, d1, d2, d3, d4, d5, d6, d7;
/*Write your code here*/
mux mux01(.x(t7), .a(in[7]), .b(in[6]), .sel(shift[0]));
mux mux02(.x(t6), .a(in[6]), .b(in[5]), .sel(shift[0]));
mux mux03(.x(t5), .a(in[5]), .b(in[4]), .sel(shift[0]));
mux mux04(.x(t4), .a(in[4]), .b(in[3]), .sel(shift[0]));
mux mux05(.x(t3), .a(in[3]), .b(in[2]), .sel(shift[0]));
mux mux06(.x(t2), .a(in[2]), .b(in[1]), .sel(shift[0]));
mux mux07(.x(t1), .a(in[1]), .b(in[0]), .sel(shift[0]));
mux mux08(.x(t0), .a(in[0]), .b(0), .sel(shift[0]));

mux mux11(.x(d7), .a(t7), .b(t5), .sel(shift[1]));
mux mux12(.x(d6), .a(t6), .b(t4), .sel(shift[1]));
mux mux13(.x(d5), .a(t5), .b(t3), .sel(shift[1]));
mux mux14(.x(d4), .a(t4), .b(t2), .sel(shift[1]));
mux mux15(.x(d3), .a(t3), .b(t1), .sel(shift[1]));
mux mux16(.x(d2), .a(t2), .b(t0), .sel(shift[1]));
mux mux17(.x(d1), .a(t1), .b(0), .sel(shift[1]));
mux mux18(.x(d0), .a(t0), .b(0), .sel(shift[1]));

mux mux21(.x(out[7]), .a(d7), .b(d3), .sel(shift[2]));
mux mux22(.x(out[6]), .a(d6), .b(d2), .sel(shift[2]));
mux mux23(.x(out[5]), .a(d5), .b(d1), .sel(shift[2]));
mux mux24(.x(out[4]), .a(d4), .b(d0), .sel(shift[2]));
mux mux25(.x(out[3]), .a(d3), .b(0), .sel(shift[2]));
mux mux26(.x(out[2]), .a(d2), .b(0), .sel(shift[2]));
mux mux27(.x(out[1]), .a(d1), .b(0), .sel(shift[2]));
mux mux28(.x(out[0]), .a(d0), .b(0), .sel(shift[2]));



/*End of code*/
endmodule

module mux (x,a,b,sel);
input 	a,b,sel;
output 	x;
wire sel_i,w1,w2;

not #1 n0(sel_i,sel);
and #1 a1(w1,a,sel_i);
and #1 a2(w2,b,sel);
or  #1 o1(x,w1,w2);

	
endmodule
