module ALU ( out , mode , in_a , in_b  );

input mode;
input  [7:0] in_a , in_b;
output [8:0] out;
reg [8:0] out;

always@(*)begin
	case (mode)
		1'b1:
		begin
			out = {in_a[7], in_a} + {in_b[7], in_b};
		end
		1'b0:
		begin
			out = in_a+in_b;
		end
	
		default : out = 9'bx;
	endcase
end


endmodule
