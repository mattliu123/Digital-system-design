module register_file(
    Clk  ,
    WEN  ,
    RW   ,
    busW ,
    RX   ,
    RY   ,
    busX ,
    busY
);
input        Clk, WEN;
input  [2:0] RW, RX, RY;
input  [7:0] busW;
output reg [7:0] busX, busY;
integer i;
// write your design here, you can delcare your own wires and regs. 
// The code below is just an eaxmple template
reg [7:0] r0_w, r1_w, r2_w, r3_w, r4_w, r5_w, r6_w, r7_w;
reg [7:0] r0_r, r1_r, r2_r, r3_r, r4_r, r5_r, r6_r, r7_r;
reg [7:0] r_w [7:0];
reg [7:0] r_r [7:0];
always@(*) begin
	
	for (i = 1; i <= 7; i = i+1) begin
		r_r[i] <= r_w[i];
	end
	r_w[0] = 8'b00000000;
	r_r[0] = 8'b00000000;
	busX = r_r[RX];
	busY = r_r[RY];

end

always@(posedge Clk) begin
	if (WEN==1) begin
		r_w[RW] <= busW;
	end
	else begin
		r_w[RW] <= r_r[RW];
	end
end	

endmodule
