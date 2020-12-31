module simple_calculator(
    Clk,
    WEN,
    RW,
    RX,
    RY,
    DataIn,
    Sel,
    Ctrl,
    busY,
    Carry
);

    input        Clk;
    input        WEN;
    input  [2:0] RW, RX, RY;
    input  [7:0] DataIn;
    input        Sel;
    input  [3:0] Ctrl;
    output [7:0] busY;
    output       Carry;

// declaration of wire/reg
    wire [7:0] busX1,busX2,busW1;
    wire [7:0] busW;
// submodule instantiation
  alu_always alu(
    .ctrl(Ctrl),
    .x(busX2),
    .y(busY),
    .carry(Carry),
    .out(busW)
    );
  register_file rf(
    .Clk(Clk),
    .WEN(WEN),
    .RW(RW),
    .busW(busW),
    .RX(RX),
    .RY(RY),
    .busX(busX1),
    .busY(busY)
    );
  assign busX2 = (~Sel)?DataIn:busX1;
  /*always@(posedge Clk) begin
    busW <= busW1;

    end*/
endmodule
module alu_always(
    ctrl,
    x,
    y,
    carry,
    out 
);
    
    input  [3:0] ctrl;
    input  [7:0] x;
    input  [7:0] y;
    output reg       carry;
    output reg [7:0] out;
    always @(*) begin
        carry = 1'bx;
        case(ctrl)
            4'b0000: {carry,out} = {x[7],x}+{y[7],y};
            4'b0001: {carry,out} = {x[7],x}-{y[7],y};
            4'b0010: out = x&y;
            4'b0011: out = x|y;
            4'b0100: out = ~x;
            4'b0101: out = x^y;
            4'b0110: out = ~(x|y);
            4'b0111: out = y<<x[2:0];
            4'b1000: out = y>>x[2:0];
            4'b1001: out = {x[7],x[7:1]};
            4'b1010: out = {x[6:0],x[7]};
            4'b1011: out = {x[0],x[7:1]};
            4'b1100: out = (x==y)?1:0;
            default: out = 0;
        endcase
    end

endmodule
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
//reg [7:0] r0_w, r1_w, r2_w, r3_w, r4_w, r5_w, r6_w, r7_w;
//reg [7:0] r0_r, r1_r, r2_r, r3_r, r4_r, r5_r, r6_r, r7_r;
reg [7:0] r_w [7:0];
reg [7:0] r_r [7:0];
    
always@(*) begin
    for (i = 0; i <= 7; i = i+1) begin
        r_r[i] = r_w[i];
    end
    r_w[0] = 0;
    r_r[0] = 0;
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
