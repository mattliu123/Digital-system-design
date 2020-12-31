//continuous assignment tb
`timescale 1ns/10ps
`define CYCLE   10
`define HCYCLE  5

module alu_assign_tb;
    reg  [3:0] ctrl;
    reg  [7:0] x;
    reg  [7:0] y;
    wire       carry;
    wire [7:0] out;
    
    alu_assign alu_assign(
        ctrl     ,
        x        ,
        y        ,
        carry    ,
        out  
    );

   initial begin
       $fsdbDumpfile("alu_assign.fsdb");
       $fsdbDumpvars;
   end

    initial begin
        ctrl = 4'b1101;
        x    = 8'd0;
        y    = 8'd0;
        
        #(`CYCLE);
        // 0100 boolean not
        ctrl = 4'b0100;
        
        #(`HCYCLE);
        if( out == 8'b1111_1111 ) $display( "PASS --- 0100 boolean not" );
        else $display( "FAIL --- 0100 boolean not" );
            
        #(`CYCLE);
        // 0000 add
        ctrl = 4'b0000;
        x = 8'b10010110;
        y = 8'b00101101;
        #(`HCYCLE);
        if(( out == 8'b1100_0011 )&&(carry==1)) $display( "PASS --- 0000 add" );
        else $display( "FAIL --- 0000 add" );

        // 0001 sub
        ctrl = 4'b0001;
        x = 8'b00000000;
        y = 8'b00000001;
        #(`HCYCLE);
        if(( out == 8'b1111_1111 )&&(carry==1)) $display( "PASS --- 0001 sub" );
        else $display( "FAIL --- 0001 sub" );

        // 0010 and
        ctrl = 4'b0010;
        x = 8'b10010110;
        y = 8'b00101101;
        #(`HCYCLE);
        if( out == 8'b00000100 ) $display( "PASS --- 0010 and" );
        else $display( "FAIL --- 0010 and" );

        // 0011 or
        ctrl = 4'b0011;
        x = 8'b10010110;
        y = 8'b00101101;
        #(`HCYCLE);
        if( out == 8'b10111111 ) $display( "PASS --- 0011 or" );
        else $display( "FAIL --- 0011 or" );

        // 0101 xor
        ctrl = 4'b0101;
        x = 8'b10010110;
        y = 8'b00101101;
        #(`HCYCLE);
        if( out == 8'b10111011 ) $display( "PASS --- 0101 xor" );
        else $display( "FAIL --- 0101 xor" );

        // 0110 nor
        ctrl = 4'b0110;
        x = 8'b10010110;
        y = 8'b00101101;
        #(`HCYCLE);
        if( out == 8'b01000000 ) $display( "PASS --- 0110 nor" );
        else $display( "FAIL --- 0110 nor" );

        // 0111 sll
        ctrl = 4'b0111;
        x = 8'b10010011;
        y = 8'b00101101;
        #(`HCYCLE);
        if( out == 8'b01101000 ) $display( "PASS --- 0111 sll" );
        else $display( "FAIL --- 0111 sll" );

        // 1000 srl
        ctrl = 4'b1000;
        x = 8'b10010011;
        y = 8'b00101101;
        #(`HCYCLE);
        if( out == 8'b00000101 ) $display( "PASS --- 1000 srl" );
        else $display( "FAIL --- 1000 srl" );
        
        // 1001 sra
        ctrl = 4'b1001;
        x = 8'b10010110;
        y = 8'b00101101;
        #(`HCYCLE);
        if( out == 8'b11001011 ) $display( "PASS --- 1001 sra" );
        else $display( "FAIL --- 1001 sra" );

        // 1010 rotate_l
        ctrl = 4'b1010;
        x = 8'b10010110;
        y = 8'b00101101;
        #(`HCYCLE);
        if( out == 8'b00101101 ) $display( "PASS --- 1010 rotate_l" );
        else $display( "FAIL --- 1010 rotate_l" );

        // 1011 rotate_r
        ctrl = 4'b1011;
        x = 8'b10010110;
        y = 8'b00101101;
        #(`HCYCLE);
        if( out == 8'b01001011 ) $display( "PASS --- 1011 rotate_r" );
        else $display( "FAIL --- 1011 rotate_r" );
        
        // 1100 eq
        ctrl = 4'b1100;
        x = 8'b10010110;
        y = 8'b00101101;
        #(`HCYCLE);
        if( out == 8'b00000000 ) $display( "PASS --- 1100 eq" );
        else $display( "FAIL --- 1100 eq" );

        // 0101 xor
        ctrl = 4'b1101;
        x = 8'b10010110;
        y = 8'b00101101;
        #(`HCYCLE);
        $display( "Don't care" );

        // finish tb
        #(`CYCLE) $finish;
    end

endmodule
