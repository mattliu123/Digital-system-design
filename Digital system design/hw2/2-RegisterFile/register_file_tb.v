`timescale 1ns/10ps
`define CYCLE  10
`define HCYCLE  5

module register_file_tb;
    // port declaration for design-under-test
    reg Clk, WEN;
    reg  [2:0] RW, RX, RY;
    reg  [7:0] busW;
    wire [7:0] busX, busY;
    reg [7:0] out[9:0];
    integer num,err,i;
    wire w[9:0];
    wire [2:0] rw[9:0], rx[9:0], ry[9:0];
    reg [7:0] busW1;
    wire [7:0] ans1[9:0], ans2[9:0], in[9:0];
    reg outputready;
    // instantiate the design-under-test
    register_file rf(
        Clk  ,
        WEN  ,
        RW   ,
        busW ,
        RX   ,
        RY   ,
        busX ,
        busY
    );
    initial begin
       $fsdbDumpfile("rf.fsdb");
       $fsdbDumpvars;
    end

    initial begin
        Clk = 0;
        num = 0;
        err = 0;
        i = 0;
    end
    always #(`HCYCLE) begin
        Clk = ~Clk;
    end
    assign rw[0] = 3'd1;
    assign rw[1] = 3'd2;
    assign rw[2] = 3'd3;
    assign rw[3] = 3'd4;
    assign rw[4] = 3'd5;
    assign rw[5] = 3'd6;
    assign rw[6] = 3'd7;
    assign rw[7] = 3'd1;
    assign rw[8] = 3'd2;
    assign rw[9] = 3'd3;

    assign rx[0] = 3'd0;
    assign rx[1] = 3'd1;
    assign rx[2] = 3'd2;
    assign rx[3] = 3'd3;
    assign rx[4] = 3'd4;
    assign rx[5] = 3'd5;
    assign rx[6] = 3'd6;
    assign rx[7] = 3'd7;
    assign rx[8] = 3'd1;
    assign rx[9] = 3'd2;

    assign ry[0] = 3'd1;
    assign ry[1] = 3'd2;
    assign ry[2] = 3'd3;
    assign ry[3] = 3'd4;
    assign ry[4] = 3'd5;
    assign ry[5] = 3'd6;
    assign ry[6] = 3'd7;
    assign ry[7] = 3'd1;
    assign ry[8] = 3'd2;
    assign ry[9] = 3'd3;

    assign w[0] = 1'b1;
    assign w[1] = 1'b1;
    assign w[2] = 1'b1;
    assign w[3] = 1'b1;
    assign w[4] = 1'b1;
    assign w[5] = 1'b1;
    assign w[6] = 1'b1;
    assign w[7] = 1'b1;
    assign w[8] = 1'b0;
    assign w[9] = 1'b1;

    assign in[0] = 8'd8;
    assign in[1] = 8'd7;
    assign in[2] = 8'd6;
    assign in[3] = 8'd5;
    assign in[4] = 8'd4;
    assign in[5] = 8'd3;
    assign in[6] = 8'd2;
    assign in[7] = 8'd1;
    assign in[8] = 8'd0;
    assign in[9] = 8'd9;

    assign ans1[0] = 8'd0;
    assign ans1[1] = 8'd8;
    assign ans1[2] = 8'd7;
    assign ans1[3] = 8'd6;
    assign ans1[4] = 8'd5;
    assign ans1[5] = 8'd4;
    assign ans1[6] = 8'd3;
    assign ans1[7] = 8'd2;
    assign ans1[8] = 8'd1;
    assign ans1[9] = 8'd7;

    assign ans2[0] = 8'd8;
    assign ans2[1] = 8'd7;
    assign ans2[2] = 8'd6;
    assign ans2[3] = 8'd5;
    assign ans2[4] = 8'd4;
    assign ans2[5] = 8'd3;
    assign ans2[6] = 8'd2;
    assign ans2[7] = 8'd1;
    assign ans2[8] = 8'd7;
    assign ans2[9] = 8'd9;    

    always begin
        
        WEN = w[num];
        RW = rw[num];
        RX = rx[num];
        RY = ry[num];
        busW = in[num];
        #(`CYCLE)
        num = num + 1;
    
    end
    initial begin
        $display("Simulation start!");
    end
    // write your test pattern here
     
    always @(negedge Clk) begin
            if ((busX==ans1[i])&&(busY==ans2[i])) $display("Correct %d %d %d",i,busX,busY);
            else if(i>=2) begin 
                $display("Wrong %d %d %d",i,busX,busY);
                err = err+1;
            end
            if (i==9)begin
                $display("There are(is) %d err(s)!",err);
                $finish;
            end
            i = i+1;
    end
    
endmodule
