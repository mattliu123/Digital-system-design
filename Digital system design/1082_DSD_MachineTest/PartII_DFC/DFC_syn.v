/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : N-2017.09-SP2
// Date      : Thu Jun  4 16:09:00 2020
/////////////////////////////////////////////////////////////


module ALU_0_DW01_add_0 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(SUM[8]), .S(SUM[7]) );
  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2XL U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_0_DW01_add_1 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(carry[8]), .S(SUM[7])
         );
  XOR3X1 U1_8 ( .A(A[8]), .B(B[8]), .C(carry[8]), .Y(SUM[8]) );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2XL U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_0 ( out, mode, in_a, in_b );
  output [8:0] out;
  input [7:0] in_a;
  input [7:0] in_b;
  input mode;
  wire   N3, N4, N5, N6, N7, N8, N9, N10, N11, N12, N13, N14, N15, N16, N17,
         N18, N19, N20, n1;

  ALU_0_DW01_add_0 add_16 ( .A({1'b0, in_a}), .B({1'b0, in_b}), .CI(1'b0), 
        .SUM({N20, N19, N18, N17, N16, N15, N14, N13, N12}) );
  ALU_0_DW01_add_1 add_12 ( .A({in_a[7], in_a}), .B({in_b[7], in_b}), .CI(1'b0), .SUM({N11, N10, N9, N8, N7, N6, N5, N4, N3}) );
  AO22X1 U3 ( .A0(N20), .A1(n1), .B0(mode), .B1(N11), .Y(out[8]) );
  AO22X1 U4 ( .A0(N19), .A1(n1), .B0(N10), .B1(mode), .Y(out[7]) );
  AO22X1 U5 ( .A0(N9), .A1(mode), .B0(N18), .B1(n1), .Y(out[6]) );
  AO22X1 U6 ( .A0(N3), .A1(mode), .B0(N12), .B1(n1), .Y(out[0]) );
  AO22X1 U7 ( .A0(N4), .A1(mode), .B0(N13), .B1(n1), .Y(out[1]) );
  AO22X1 U8 ( .A0(N5), .A1(mode), .B0(N14), .B1(n1), .Y(out[2]) );
  AO22X1 U9 ( .A0(N6), .A1(mode), .B0(N15), .B1(n1), .Y(out[3]) );
  AO22X1 U10 ( .A0(N7), .A1(mode), .B0(N16), .B1(n1), .Y(out[4]) );
  AO22X1 U11 ( .A0(N8), .A1(mode), .B0(N17), .B1(n1), .Y(out[5]) );
  INVX3 U12 ( .A(mode), .Y(n1) );
endmodule


module ALU_3_DW01_add_0 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(SUM[8]), .S(SUM[7]) );
  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2XL U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_3_DW01_add_1 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(carry[8]), .S(SUM[7])
         );
  XOR3X1 U1_8 ( .A(A[8]), .B(B[8]), .C(carry[8]), .Y(SUM[8]) );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2XL U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_3 ( out, mode, in_a, in_b );
  output [8:0] out;
  input [7:0] in_a;
  input [7:0] in_b;
  input mode;
  wire   N3, N4, N5, N6, N7, N8, N9, N10, N11, N12, N13, N14, N15, N16, N17,
         N18, N19, N20, n1;

  ALU_3_DW01_add_0 add_16 ( .A({1'b0, in_a}), .B({1'b0, in_b}), .CI(1'b0), 
        .SUM({N20, N19, N18, N17, N16, N15, N14, N13, N12}) );
  ALU_3_DW01_add_1 add_12 ( .A({in_a[7], in_a}), .B({in_b[7], in_b}), .CI(1'b0), .SUM({N11, N10, N9, N8, N7, N6, N5, N4, N3}) );
  AO22X1 U3 ( .A0(N20), .A1(n1), .B0(mode), .B1(N11), .Y(out[8]) );
  AO22X1 U4 ( .A0(N19), .A1(n1), .B0(N10), .B1(mode), .Y(out[7]) );
  AO22X1 U5 ( .A0(N9), .A1(mode), .B0(N18), .B1(n1), .Y(out[6]) );
  AO22X1 U6 ( .A0(N3), .A1(mode), .B0(N12), .B1(n1), .Y(out[0]) );
  AO22X1 U7 ( .A0(N4), .A1(mode), .B0(N13), .B1(n1), .Y(out[1]) );
  AO22X1 U8 ( .A0(N5), .A1(mode), .B0(N14), .B1(n1), .Y(out[2]) );
  AO22X1 U9 ( .A0(N6), .A1(mode), .B0(N15), .B1(n1), .Y(out[3]) );
  AO22X1 U10 ( .A0(N7), .A1(mode), .B0(N16), .B1(n1), .Y(out[4]) );
  AO22X1 U11 ( .A0(N8), .A1(mode), .B0(N17), .B1(n1), .Y(out[5]) );
  INVX3 U12 ( .A(mode), .Y(n1) );
endmodule


module ALU_2_DW01_add_0 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(SUM[8]), .S(SUM[7]) );
  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2XL U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_2_DW01_add_1 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(carry[8]), .S(SUM[7])
         );
  XOR3X1 U1_8 ( .A(A[8]), .B(B[8]), .C(carry[8]), .Y(SUM[8]) );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2XL U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_2 ( out, mode, in_a, in_b );
  output [8:0] out;
  input [7:0] in_a;
  input [7:0] in_b;
  input mode;
  wire   N3, N4, N5, N6, N7, N8, N9, N10, N11, N12, N13, N14, N15, N16, N17,
         N18, N19, N20, n1;

  ALU_2_DW01_add_0 add_16 ( .A({1'b0, in_a}), .B({1'b0, in_b}), .CI(1'b0), 
        .SUM({N20, N19, N18, N17, N16, N15, N14, N13, N12}) );
  ALU_2_DW01_add_1 add_12 ( .A({in_a[7], in_a}), .B({in_b[7], in_b}), .CI(1'b0), .SUM({N11, N10, N9, N8, N7, N6, N5, N4, N3}) );
  AO22X1 U3 ( .A0(N20), .A1(n1), .B0(mode), .B1(N11), .Y(out[8]) );
  AO22X1 U4 ( .A0(N19), .A1(n1), .B0(N10), .B1(mode), .Y(out[7]) );
  AO22X1 U5 ( .A0(N9), .A1(mode), .B0(N18), .B1(n1), .Y(out[6]) );
  AO22X1 U6 ( .A0(N3), .A1(mode), .B0(N12), .B1(n1), .Y(out[0]) );
  AO22X1 U7 ( .A0(N4), .A1(mode), .B0(N13), .B1(n1), .Y(out[1]) );
  AO22X1 U8 ( .A0(N5), .A1(mode), .B0(N14), .B1(n1), .Y(out[2]) );
  AO22X1 U9 ( .A0(N6), .A1(mode), .B0(N15), .B1(n1), .Y(out[3]) );
  AO22X1 U10 ( .A0(N7), .A1(mode), .B0(N16), .B1(n1), .Y(out[4]) );
  AO22X1 U11 ( .A0(N8), .A1(mode), .B0(N17), .B1(n1), .Y(out[5]) );
  INVX3 U12 ( .A(mode), .Y(n1) );
endmodule


module ALU_1_DW01_add_0 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(SUM[8]), .S(SUM[7]) );
  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2X1 U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_1_DW01_add_1 ( A, B, CI, SUM, CO );
  input [8:0] A;
  input [8:0] B;
  output [8:0] SUM;
  input CI;
  output CO;
  wire   n1;
  wire   [8:1] carry;

  XOR3X1 U1_8 ( .A(A[8]), .B(B[8]), .C(carry[8]), .Y(SUM[8]) );
  ADDFXL U1_6 ( .A(A[6]), .B(B[6]), .CI(carry[6]), .CO(carry[7]), .S(SUM[6])
         );
  ADDFXL U1_5 ( .A(A[5]), .B(B[5]), .CI(carry[5]), .CO(carry[6]), .S(SUM[5])
         );
  ADDFXL U1_4 ( .A(A[4]), .B(B[4]), .CI(carry[4]), .CO(carry[5]), .S(SUM[4])
         );
  ADDFXL U1_3 ( .A(A[3]), .B(B[3]), .CI(carry[3]), .CO(carry[4]), .S(SUM[3])
         );
  ADDFXL U1_2 ( .A(A[2]), .B(B[2]), .CI(carry[2]), .CO(carry[3]), .S(SUM[2])
         );
  ADDFXL U1_7 ( .A(A[7]), .B(B[7]), .CI(carry[7]), .CO(carry[8]), .S(SUM[7])
         );
  ADDFXL U1_1 ( .A(A[1]), .B(B[1]), .CI(n1), .CO(carry[2]), .S(SUM[1]) );
  AND2X2 U1 ( .A(B[0]), .B(A[0]), .Y(n1) );
  XOR2X1 U2 ( .A(B[0]), .B(A[0]), .Y(SUM[0]) );
endmodule


module ALU_1 ( out, mode, in_a, in_b );
  output [8:0] out;
  input [7:0] in_a;
  input [7:0] in_b;
  input mode;
  wire   N3, N4, N5, N6, N7, N8, N9, N10, N11, N12, N13, N14, N15, N16, N17,
         N18, N19, N20, n1;

  ALU_1_DW01_add_0 add_16 ( .A({1'b0, in_a}), .B({1'b0, in_b}), .CI(1'b0), 
        .SUM({N20, N19, N18, N17, N16, N15, N14, N13, N12}) );
  ALU_1_DW01_add_1 add_12 ( .A({in_a[7], in_a}), .B({in_b[7], in_b}), .CI(1'b0), .SUM({N11, N10, N9, N8, N7, N6, N5, N4, N3}) );
  AO22X1 U3 ( .A0(N9), .A1(mode), .B0(N18), .B1(n1), .Y(out[6]) );
  AO22X1 U4 ( .A0(N19), .A1(n1), .B0(N10), .B1(mode), .Y(out[7]) );
  AO22X1 U5 ( .A0(N20), .A1(n1), .B0(mode), .B1(N11), .Y(out[8]) );
  AO22X1 U6 ( .A0(N3), .A1(mode), .B0(N12), .B1(n1), .Y(out[0]) );
  AO22X1 U7 ( .A0(N4), .A1(mode), .B0(N13), .B1(n1), .Y(out[1]) );
  AO22X1 U8 ( .A0(N5), .A1(mode), .B0(N14), .B1(n1), .Y(out[2]) );
  AO22X1 U9 ( .A0(N6), .A1(mode), .B0(N15), .B1(n1), .Y(out[3]) );
  AO22X1 U10 ( .A0(N8), .A1(mode), .B0(N17), .B1(n1), .Y(out[5]) );
  AO22X1 U11 ( .A0(N7), .A1(mode), .B0(N16), .B1(n1), .Y(out[4]) );
  INVX3 U12 ( .A(mode), .Y(n1) );
endmodule


module DFC ( clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy
 );
  input [7:0] datain;
  input [1:0] cmd;
  output [8:0] dataout;
  input clk, reset, cmd_valid;
  output output_valid, busy;
  wire   n183, n184, n185, n186, n187, n188, n189, n190, n191,
         \data_buf[0][7] , \data_buf[0][6] , \data_buf[0][5] ,
         \data_buf[0][4] , \data_buf[0][3] , \data_buf[0][2] ,
         \data_buf[0][1] , \data_buf[0][0] , \data_buf[1][7] ,
         \data_buf[1][6] , \data_buf[1][5] , \data_buf[1][4] ,
         \data_buf[1][3] , \data_buf[1][2] , \data_buf[1][1] ,
         \data_buf[1][0] , \data_buf[2][7] , \data_buf[2][6] ,
         \data_buf[2][5] , \data_buf[2][4] , \data_buf[2][3] ,
         \data_buf[2][2] , \data_buf[2][1] , \data_buf[2][0] ,
         \data_buf[3][7] , \data_buf[3][6] , \data_buf[3][5] ,
         \data_buf[3][4] , \data_buf[3][3] , \data_buf[3][2] ,
         \data_buf[3][1] , \data_buf[3][0] , \data_buf[4][7] ,
         \data_buf[4][6] , \data_buf[4][5] , \data_buf[4][4] ,
         \data_buf[4][3] , \data_buf[4][2] , \data_buf[4][1] ,
         \data_buf[4][0] , \data_buf[5][7] , \data_buf[5][6] ,
         \data_buf[5][5] , \data_buf[5][4] , \data_buf[5][3] ,
         \data_buf[5][2] , \data_buf[5][1] , \data_buf[5][0] ,
         \data_buf[6][7] , \data_buf[6][6] , \data_buf[6][5] ,
         \data_buf[6][4] , \data_buf[6][3] , \data_buf[6][2] ,
         \data_buf[6][1] , \data_buf[6][0] , \data_buf[7][7] ,
         \data_buf[7][6] , \data_buf[7][5] , \data_buf[7][4] ,
         \data_buf[7][3] , \data_buf[7][2] , \data_buf[7][1] ,
         \data_buf[7][0] , \state[0] , n5, n6, n7, n12, n14, n23, n24, n25,
         n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39,
         n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52, n53,
         n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64, n65, n66, n67,
         n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81,
         n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92, n93, n94, n95,
         n96, n97, n98, n99, n100, n101, n102, n103, n104, n105, n106, n107,
         n108, n109, n110, n111, n112, n113, n114, n115, n116, n117, n118,
         n119, n120, n121, n122, n123, n124, n125, n126, n127, n128, n129,
         n130, n131, n132, n133, n134, n135, n136, n137, n138, n149, n150,
         n151, n152, n153, n154, n155, n156, n157, n158, n159, n160, n161,
         n162, n163, n164, n165, n166, n167, n168, n169, n170, n171, n172,
         n173, n174, n175, n176, n177, n178, n179, n180, n181, n182;
  wire   [8:0] out0;
  wire   [8:0] out1;
  wire   [8:0] out2;
  wire   [8:0] out3;
  wire   [1:0] nxt_state;
  wire   [2:0] count;

  ALU_0 A0 ( .out(out0), .mode(1'b1), .in_a({\data_buf[0][7] , 
        \data_buf[0][6] , \data_buf[0][5] , \data_buf[0][4] , \data_buf[0][3] , 
        \data_buf[0][2] , \data_buf[0][1] , \data_buf[0][0] }), .in_b({
        \data_buf[4][7] , \data_buf[4][6] , \data_buf[4][5] , \data_buf[4][4] , 
        \data_buf[4][3] , \data_buf[4][2] , \data_buf[4][1] , \data_buf[4][0] }) );
  ALU_3 A1 ( .out(out1), .mode(1'b1), .in_a({\data_buf[1][7] , 
        \data_buf[1][6] , \data_buf[1][5] , \data_buf[1][4] , \data_buf[1][3] , 
        \data_buf[1][2] , \data_buf[1][1] , \data_buf[1][0] }), .in_b({
        \data_buf[5][7] , \data_buf[5][6] , \data_buf[5][5] , \data_buf[5][4] , 
        \data_buf[5][3] , \data_buf[5][2] , \data_buf[5][1] , \data_buf[5][0] }) );
  ALU_2 A2 ( .out(out2), .mode(1'b1), .in_a({\data_buf[2][7] , 
        \data_buf[2][6] , \data_buf[2][5] , \data_buf[2][4] , \data_buf[2][3] , 
        \data_buf[2][2] , \data_buf[2][1] , \data_buf[2][0] }), .in_b({
        \data_buf[6][7] , \data_buf[6][6] , \data_buf[6][5] , \data_buf[6][4] , 
        \data_buf[6][3] , \data_buf[6][2] , \data_buf[6][1] , \data_buf[6][0] }) );
  ALU_1 A3 ( .out(out3), .mode(1'b1), .in_a({\data_buf[3][7] , 
        \data_buf[3][6] , \data_buf[3][5] , \data_buf[3][4] , \data_buf[3][3] , 
        \data_buf[3][2] , \data_buf[3][1] , \data_buf[3][0] }), .in_b({
        \data_buf[7][7] , \data_buf[7][6] , \data_buf[7][5] , \data_buf[7][4] , 
        \data_buf[7][3] , \data_buf[7][2] , \data_buf[7][1] , \data_buf[7][0] }) );
  DFFRX1 \count_reg[2]  ( .D(n136), .CK(clk), .RN(n163), .Q(count[2]), .QN(n7)
         );
  DFFRX1 \count_reg[1]  ( .D(n135), .CK(clk), .RN(n162), .Q(count[1]), .QN(n12) );
  DFFRX1 \data_buf_reg[3][2]  ( .D(n97), .CK(clk), .RN(n165), .Q(
        \data_buf[3][2] ) );
  DFFRX1 \data_buf_reg[3][3]  ( .D(n98), .CK(clk), .RN(n163), .Q(
        \data_buf[3][3] ) );
  DFFRX1 \data_buf_reg[3][4]  ( .D(n99), .CK(clk), .RN(n162), .Q(
        \data_buf[3][4] ) );
  DFFRX1 \data_buf_reg[3][5]  ( .D(n100), .CK(clk), .RN(n164), .Q(
        \data_buf[3][5] ) );
  DFFRX1 \data_buf_reg[3][6]  ( .D(n101), .CK(clk), .RN(n165), .Q(
        \data_buf[3][6] ) );
  DFFRX1 \data_buf_reg[1][3]  ( .D(n82), .CK(clk), .RN(n165), .Q(
        \data_buf[1][3] ) );
  DFFRX1 \data_buf_reg[1][4]  ( .D(n83), .CK(clk), .RN(n165), .Q(
        \data_buf[1][4] ) );
  DFFRX1 \data_buf_reg[1][5]  ( .D(n84), .CK(clk), .RN(n165), .Q(
        \data_buf[1][5] ) );
  DFFRX1 \data_buf_reg[1][6]  ( .D(n85), .CK(clk), .RN(n165), .Q(
        \data_buf[1][6] ) );
  DFFRX1 \data_buf_reg[2][3]  ( .D(n90), .CK(clk), .RN(n164), .Q(
        \data_buf[2][3] ) );
  DFFRX1 \data_buf_reg[2][4]  ( .D(n91), .CK(clk), .RN(n164), .Q(
        \data_buf[2][4] ) );
  DFFRX1 \data_buf_reg[2][5]  ( .D(n92), .CK(clk), .RN(n164), .Q(
        \data_buf[2][5] ) );
  DFFRX1 \data_buf_reg[2][6]  ( .D(n93), .CK(clk), .RN(n164), .Q(
        \data_buf[2][6] ) );
  DFFRX1 \data_buf_reg[0][6]  ( .D(n71), .CK(clk), .RN(n163), .Q(
        \data_buf[0][6] ) );
  DFFRX1 \data_buf_reg[0][5]  ( .D(n72), .CK(clk), .RN(n163), .Q(
        \data_buf[0][5] ) );
  DFFRX1 \data_buf_reg[0][4]  ( .D(n73), .CK(clk), .RN(n163), .Q(
        \data_buf[0][4] ) );
  DFFRX1 \data_buf_reg[0][3]  ( .D(n74), .CK(clk), .RN(n163), .Q(
        \data_buf[0][3] ) );
  DFFRX1 \count_reg[0]  ( .D(n137), .CK(clk), .RN(n166), .Q(count[0]), .QN(n14) );
  DFFRX1 \state_reg[0]  ( .D(nxt_state[0]), .CK(clk), .RN(n166), .Q(\state[0] ), .QN(n6) );
  DFFRX1 \data_buf_reg[3][7]  ( .D(n102), .CK(clk), .RN(n163), .Q(
        \data_buf[3][7] ) );
  DFFRX1 \data_buf_reg[1][7]  ( .D(n86), .CK(clk), .RN(n165), .Q(
        \data_buf[1][7] ) );
  DFFRX1 \data_buf_reg[2][7]  ( .D(n94), .CK(clk), .RN(n164), .Q(
        \data_buf[2][7] ) );
  DFFRX1 \data_buf_reg[0][7]  ( .D(n78), .CK(clk), .RN(n162), .Q(
        \data_buf[0][7] ) );
  DFFRX1 \data_buf_reg[3][1]  ( .D(n96), .CK(clk), .RN(n162), .Q(
        \data_buf[3][1] ) );
  DFFRX1 \data_buf_reg[1][1]  ( .D(n80), .CK(clk), .RN(n165), .Q(
        \data_buf[1][1] ) );
  DFFRX1 \data_buf_reg[1][2]  ( .D(n81), .CK(clk), .RN(n165), .Q(
        \data_buf[1][2] ) );
  DFFRX1 \data_buf_reg[2][1]  ( .D(n88), .CK(clk), .RN(n164), .Q(
        \data_buf[2][1] ) );
  DFFRX1 \data_buf_reg[2][2]  ( .D(n89), .CK(clk), .RN(n164), .Q(
        \data_buf[2][2] ) );
  DFFRX1 \data_buf_reg[0][2]  ( .D(n75), .CK(clk), .RN(n162), .Q(
        \data_buf[0][2] ) );
  DFFRX1 \data_buf_reg[0][1]  ( .D(n76), .CK(clk), .RN(n162), .Q(
        \data_buf[0][1] ) );
  DFFRX1 \data_buf_reg[7][2]  ( .D(n129), .CK(clk), .RN(n165), .Q(
        \data_buf[7][2] ) );
  DFFRX1 \data_buf_reg[7][3]  ( .D(n130), .CK(clk), .RN(n164), .Q(
        \data_buf[7][3] ) );
  DFFRX1 \data_buf_reg[7][4]  ( .D(n131), .CK(clk), .RN(n164), .Q(
        \data_buf[7][4] ) );
  DFFRX1 \data_buf_reg[7][5]  ( .D(n132), .CK(clk), .RN(n165), .Q(
        \data_buf[7][5] ) );
  DFFRX1 \data_buf_reg[7][6]  ( .D(n133), .CK(clk), .RN(n163), .Q(
        \data_buf[7][6] ) );
  DFFRX1 \data_buf_reg[5][3]  ( .D(n114), .CK(clk), .RN(n165), .Q(
        \data_buf[5][3] ) );
  DFFRX1 \data_buf_reg[5][4]  ( .D(n115), .CK(clk), .RN(n164), .Q(
        \data_buf[5][4] ) );
  DFFRX1 \data_buf_reg[5][5]  ( .D(n116), .CK(clk), .RN(n164), .Q(
        \data_buf[5][5] ) );
  DFFRX1 \data_buf_reg[5][6]  ( .D(n117), .CK(clk), .RN(n164), .Q(
        \data_buf[5][6] ) );
  DFFRX1 \data_buf_reg[6][3]  ( .D(n122), .CK(clk), .RN(n163), .Q(
        \data_buf[6][3] ) );
  DFFRX1 \data_buf_reg[6][4]  ( .D(n123), .CK(clk), .RN(n163), .Q(
        \data_buf[6][4] ) );
  DFFRX1 \data_buf_reg[6][5]  ( .D(n124), .CK(clk), .RN(n163), .Q(
        \data_buf[6][5] ) );
  DFFRX1 \data_buf_reg[6][6]  ( .D(n125), .CK(clk), .RN(n163), .Q(
        \data_buf[6][6] ) );
  DFFRX1 \data_buf_reg[4][3]  ( .D(n106), .CK(clk), .RN(n162), .Q(
        \data_buf[4][3] ) );
  DFFRX1 \data_buf_reg[4][4]  ( .D(n107), .CK(clk), .RN(n162), .Q(
        \data_buf[4][4] ) );
  DFFRX1 \data_buf_reg[4][5]  ( .D(n108), .CK(clk), .RN(n162), .Q(
        \data_buf[4][5] ) );
  DFFRX1 \data_buf_reg[4][6]  ( .D(n109), .CK(clk), .RN(n162), .Q(
        \data_buf[4][6] ) );
  DFFRX1 \data_buf_reg[7][7]  ( .D(n134), .CK(clk), .RN(n165), .Q(
        \data_buf[7][7] ) );
  DFFRX1 \data_buf_reg[5][7]  ( .D(n118), .CK(clk), .RN(n164), .Q(
        \data_buf[5][7] ) );
  DFFRX1 \data_buf_reg[6][7]  ( .D(n126), .CK(clk), .RN(n163), .Q(
        \data_buf[6][7] ) );
  DFFRX1 \data_buf_reg[4][7]  ( .D(n110), .CK(clk), .RN(n162), .Q(
        \data_buf[4][7] ) );
  DFFRX1 \data_buf_reg[7][0]  ( .D(n127), .CK(clk), .RN(n163), .Q(
        \data_buf[7][0] ) );
  DFFRX1 \data_buf_reg[5][0]  ( .D(n111), .CK(clk), .RN(n165), .Q(
        \data_buf[5][0] ) );
  DFFRX1 \data_buf_reg[6][0]  ( .D(n119), .CK(clk), .RN(n163), .Q(
        \data_buf[6][0] ) );
  DFFRX1 \data_buf_reg[4][0]  ( .D(n103), .CK(clk), .RN(n162), .Q(
        \data_buf[4][0] ) );
  DFFRX1 \data_buf_reg[7][1]  ( .D(n128), .CK(clk), .RN(n162), .Q(
        \data_buf[7][1] ) );
  DFFRX1 \data_buf_reg[5][1]  ( .D(n112), .CK(clk), .RN(n165), .Q(
        \data_buf[5][1] ) );
  DFFRX1 \data_buf_reg[5][2]  ( .D(n113), .CK(clk), .RN(n165), .Q(
        \data_buf[5][2] ) );
  DFFRX1 \data_buf_reg[6][1]  ( .D(n120), .CK(clk), .RN(n163), .Q(
        \data_buf[6][1] ) );
  DFFRX1 \data_buf_reg[6][2]  ( .D(n121), .CK(clk), .RN(n163), .Q(
        \data_buf[6][2] ) );
  DFFRX1 \data_buf_reg[4][1]  ( .D(n104), .CK(clk), .RN(n162), .Q(
        \data_buf[4][1] ) );
  DFFRX1 \data_buf_reg[4][2]  ( .D(n105), .CK(clk), .RN(n162), .Q(
        \data_buf[4][2] ) );
  DFFRX1 \data_buf_reg[3][0]  ( .D(n95), .CK(clk), .RN(n162), .Q(
        \data_buf[3][0] ) );
  DFFRX1 \data_buf_reg[1][0]  ( .D(n79), .CK(clk), .RN(n165), .Q(
        \data_buf[1][0] ) );
  DFFRX1 \data_buf_reg[2][0]  ( .D(n87), .CK(clk), .RN(n164), .Q(
        \data_buf[2][0] ) );
  DFFRX1 \data_buf_reg[0][0]  ( .D(n77), .CK(clk), .RN(n162), .Q(
        \data_buf[0][0] ) );
  DFFRX2 \state_reg[1]  ( .D(nxt_state[1]), .CK(clk), .RN(n164), .Q(n182), 
        .QN(n5) );
  CLKINVX1 U149 ( .A(n182), .Y(n138) );
  INVX16 U150 ( .A(n138), .Y(output_valid) );
  OR2X1 U151 ( .A(n54), .B(n5), .Y(n184) );
  INVX12 U152 ( .A(n184), .Y(dataout[7]) );
  OR2X1 U153 ( .A(n56), .B(n5), .Y(n185) );
  INVX12 U154 ( .A(n185), .Y(dataout[6]) );
  AOI2BB2XL U155 ( .B0(out3[6]), .B1(n149), .A0N(n161), .A1N(n57), .Y(n56) );
  OR2X1 U156 ( .A(n58), .B(n5), .Y(n186) );
  INVX12 U157 ( .A(n186), .Y(dataout[5]) );
  AOI2BB2XL U158 ( .B0(out3[5]), .B1(n149), .A0N(n161), .A1N(n59), .Y(n58) );
  OR2X1 U159 ( .A(n60), .B(n5), .Y(n187) );
  INVX12 U160 ( .A(n187), .Y(dataout[4]) );
  AOI2BB2XL U161 ( .B0(out3[4]), .B1(n149), .A0N(n161), .A1N(n61), .Y(n60) );
  OR2X1 U162 ( .A(n62), .B(n5), .Y(n188) );
  INVX12 U163 ( .A(n188), .Y(dataout[3]) );
  AOI2BB2XL U164 ( .B0(out3[3]), .B1(n149), .A0N(n161), .A1N(n63), .Y(n62) );
  OR2X1 U165 ( .A(n64), .B(n5), .Y(n189) );
  INVX12 U166 ( .A(n189), .Y(dataout[2]) );
  AOI2BB2XL U167 ( .B0(out3[2]), .B1(n149), .A0N(n161), .A1N(n65), .Y(n64) );
  OR2X1 U168 ( .A(n66), .B(n5), .Y(n190) );
  INVX12 U169 ( .A(n190), .Y(dataout[1]) );
  AOI2BB2XL U170 ( .B0(out3[1]), .B1(n149), .A0N(n161), .A1N(n67), .Y(n66) );
  INVX12 U171 ( .A(n28), .Y(busy) );
  OR2X1 U172 ( .A(n68), .B(n5), .Y(n191) );
  INVX12 U173 ( .A(n191), .Y(dataout[0]) );
  AOI2BB2XL U174 ( .B0(out3[0]), .B1(n149), .A0N(n161), .A1N(n69), .Y(n68) );
  NOR2X1 U175 ( .A(n5), .B(\state[0] ), .Y(n70) );
  NOR2X1 U176 ( .A(n12), .B(count[0]), .Y(n35) );
  NOR2X1 U177 ( .A(n14), .B(count[1]), .Y(n33) );
  NOR2X1 U178 ( .A(count[0]), .B(count[1]), .Y(n30) );
  NOR2X1 U179 ( .A(n181), .B(n7), .Y(n39) );
  NOR2X1 U180 ( .A(output_valid), .B(n6), .Y(n37) );
  BUFX12 U181 ( .A(n183), .Y(dataout[8]) );
  NOR2X1 U182 ( .A(n48), .B(n5), .Y(n183) );
  CLKINVX1 U183 ( .A(n25), .Y(n175) );
  CLKBUFX3 U184 ( .A(n166), .Y(n162) );
  CLKBUFX3 U185 ( .A(n166), .Y(n163) );
  CLKBUFX3 U186 ( .A(n166), .Y(n164) );
  CLKBUFX3 U187 ( .A(n166), .Y(n165) );
  NOR2X1 U188 ( .A(n176), .B(n161), .Y(n25) );
  CLKINVX1 U189 ( .A(n70), .Y(n180) );
  CLKINVX1 U190 ( .A(n35), .Y(n179) );
  CLKINVX1 U191 ( .A(n33), .Y(n177) );
  CLKINVX1 U192 ( .A(n47), .Y(n176) );
  CLKINVX1 U193 ( .A(n30), .Y(n178) );
  CLKBUFX3 U194 ( .A(n49), .Y(n149) );
  OAI32X1 U195 ( .A0(n178), .A1(n161), .A2(n70), .B0(n180), .B1(n175), .Y(n49)
         );
  CLKBUFX3 U196 ( .A(n51), .Y(n150) );
  OAI22XL U197 ( .A0(n70), .A1(n177), .B0(n180), .B1(n179), .Y(n51) );
  CLKBUFX3 U198 ( .A(n52), .Y(n151) );
  OAI22XL U199 ( .A0(n70), .A1(n176), .B0(n180), .B1(n178), .Y(n52) );
  CLKBUFX3 U200 ( .A(n53), .Y(n152) );
  OAI22XL U201 ( .A0(n70), .A1(n179), .B0(n180), .B1(n177), .Y(n53) );
  NOR2X1 U202 ( .A(n181), .B(n161), .Y(n31) );
  CLKINVX1 U203 ( .A(n37), .Y(n181) );
  CLKBUFX3 U204 ( .A(n29), .Y(n160) );
  NAND2X1 U205 ( .A(n30), .B(n31), .Y(n29) );
  CLKBUFX3 U206 ( .A(n38), .Y(n156) );
  NAND2X1 U207 ( .A(n39), .B(n30), .Y(n38) );
  CLKBUFX3 U208 ( .A(n41), .Y(n154) );
  NAND2X1 U209 ( .A(n39), .B(n35), .Y(n41) );
  CLKBUFX3 U210 ( .A(n40), .Y(n155) );
  NAND2X1 U211 ( .A(n39), .B(n33), .Y(n40) );
  CLKBUFX3 U212 ( .A(n34), .Y(n158) );
  NAND2X1 U213 ( .A(n35), .B(n31), .Y(n34) );
  CLKBUFX3 U214 ( .A(n32), .Y(n159) );
  NAND2X1 U215 ( .A(n33), .B(n31), .Y(n32) );
  CLKBUFX3 U216 ( .A(n36), .Y(n157) );
  NAND2X1 U217 ( .A(n25), .B(n37), .Y(n36) );
  CLKBUFX3 U218 ( .A(n42), .Y(n153) );
  NAND2X1 U219 ( .A(n27), .B(n37), .Y(n42) );
  AOI222XL U220 ( .A0(out2[6]), .A1(n150), .B0(out0[6]), .B1(n151), .C0(
        out1[6]), .C1(n152), .Y(n57) );
  AOI2BB2X1 U221 ( .B0(out3[7]), .B1(n149), .A0N(n161), .A1N(n55), .Y(n54) );
  AOI222XL U222 ( .A0(out2[7]), .A1(n150), .B0(out0[7]), .B1(n151), .C0(
        out1[7]), .C1(n152), .Y(n55) );
  AOI2BB2X1 U223 ( .B0(out3[8]), .B1(n149), .A0N(n161), .A1N(n50), .Y(n48) );
  AOI222XL U224 ( .A0(out2[8]), .A1(n150), .B0(out0[8]), .B1(n151), .C0(
        out1[8]), .C1(n152), .Y(n50) );
  AOI222XL U225 ( .A0(out2[0]), .A1(n150), .B0(out0[0]), .B1(n151), .C0(
        out1[0]), .C1(n152), .Y(n69) );
  AOI222XL U226 ( .A0(out2[1]), .A1(n150), .B0(out0[1]), .B1(n151), .C0(
        out1[1]), .C1(n152), .Y(n67) );
  AOI222XL U227 ( .A0(out2[2]), .A1(n150), .B0(out0[2]), .B1(n151), .C0(
        out1[2]), .C1(n152), .Y(n65) );
  AOI222XL U228 ( .A0(out2[3]), .A1(n150), .B0(out0[3]), .B1(n151), .C0(
        out1[3]), .C1(n152), .Y(n63) );
  AOI222XL U229 ( .A0(out2[5]), .A1(n150), .B0(out0[5]), .B1(n151), .C0(
        out1[5]), .C1(n152), .Y(n59) );
  AOI222XL U230 ( .A0(out2[4]), .A1(n150), .B0(out0[4]), .B1(n151), .C0(
        out1[4]), .C1(n152), .Y(n61) );
  NOR2X1 U231 ( .A(n12), .B(n14), .Y(n47) );
  CLKBUFX3 U232 ( .A(count[2]), .Y(n161) );
  NOR2X1 U233 ( .A(output_valid), .B(\state[0] ), .Y(n28) );
  INVX3 U234 ( .A(datain[7]), .Y(n167) );
  INVX3 U235 ( .A(datain[6]), .Y(n168) );
  INVX3 U236 ( .A(datain[5]), .Y(n169) );
  INVX3 U237 ( .A(datain[4]), .Y(n170) );
  INVX3 U238 ( .A(datain[3]), .Y(n171) );
  INVX3 U239 ( .A(datain[2]), .Y(n172) );
  INVX3 U240 ( .A(datain[1]), .Y(n173) );
  INVX3 U241 ( .A(datain[0]), .Y(n174) );
  OAI221XL U242 ( .A0(n23), .A1(n24), .B0(n25), .B1(n180), .C0(n26), .Y(
        nxt_state[1]) );
  XNOR2X1 U243 ( .A(cmd[0]), .B(cmd[1]), .Y(n23) );
  OAI221XL U244 ( .A0(cmd[0]), .A1(n24), .B0(n27), .B1(n181), .C0(n26), .Y(
        nxt_state[0]) );
  OAI2BB2XL U245 ( .B0(n167), .B1(n156), .A0N(\data_buf[4][7] ), .A1N(n156), 
        .Y(n110) );
  OAI2BB2XL U246 ( .B0(n168), .B1(n156), .A0N(\data_buf[4][6] ), .A1N(n156), 
        .Y(n109) );
  OAI2BB2XL U247 ( .B0(n169), .B1(n156), .A0N(\data_buf[4][5] ), .A1N(n156), 
        .Y(n108) );
  OAI2BB2XL U248 ( .B0(n170), .B1(n156), .A0N(\data_buf[4][4] ), .A1N(n156), 
        .Y(n107) );
  OAI2BB2XL U249 ( .B0(n171), .B1(n156), .A0N(\data_buf[4][3] ), .A1N(n156), 
        .Y(n106) );
  OAI2BB2XL U250 ( .B0(n172), .B1(n156), .A0N(\data_buf[4][2] ), .A1N(n156), 
        .Y(n105) );
  OAI2BB2XL U251 ( .B0(n173), .B1(n156), .A0N(\data_buf[4][1] ), .A1N(n156), 
        .Y(n104) );
  OAI2BB2XL U252 ( .B0(n174), .B1(n156), .A0N(\data_buf[4][0] ), .A1N(n156), 
        .Y(n103) );
  OAI2BB2XL U253 ( .B0(n167), .B1(n154), .A0N(\data_buf[6][7] ), .A1N(n154), 
        .Y(n126) );
  OAI2BB2XL U254 ( .B0(n168), .B1(n154), .A0N(\data_buf[6][6] ), .A1N(n154), 
        .Y(n125) );
  OAI2BB2XL U255 ( .B0(n169), .B1(n154), .A0N(\data_buf[6][5] ), .A1N(n154), 
        .Y(n124) );
  OAI2BB2XL U256 ( .B0(n170), .B1(n154), .A0N(\data_buf[6][4] ), .A1N(n154), 
        .Y(n123) );
  OAI2BB2XL U257 ( .B0(n171), .B1(n154), .A0N(\data_buf[6][3] ), .A1N(n154), 
        .Y(n122) );
  OAI2BB2XL U258 ( .B0(n172), .B1(n154), .A0N(\data_buf[6][2] ), .A1N(n154), 
        .Y(n121) );
  OAI2BB2XL U259 ( .B0(n173), .B1(n154), .A0N(\data_buf[6][1] ), .A1N(n154), 
        .Y(n120) );
  OAI2BB2XL U260 ( .B0(n174), .B1(n154), .A0N(\data_buf[6][0] ), .A1N(n154), 
        .Y(n119) );
  OAI2BB2XL U261 ( .B0(n167), .B1(n158), .A0N(\data_buf[2][7] ), .A1N(n158), 
        .Y(n94) );
  OAI2BB2XL U262 ( .B0(n168), .B1(n158), .A0N(\data_buf[2][6] ), .A1N(n158), 
        .Y(n93) );
  OAI2BB2XL U263 ( .B0(n169), .B1(n158), .A0N(\data_buf[2][5] ), .A1N(n158), 
        .Y(n92) );
  OAI2BB2XL U264 ( .B0(n170), .B1(n158), .A0N(\data_buf[2][4] ), .A1N(n158), 
        .Y(n91) );
  OAI2BB2XL U265 ( .B0(n171), .B1(n158), .A0N(\data_buf[2][3] ), .A1N(n158), 
        .Y(n90) );
  OAI2BB2XL U266 ( .B0(n172), .B1(n158), .A0N(\data_buf[2][2] ), .A1N(n158), 
        .Y(n89) );
  OAI2BB2XL U267 ( .B0(n173), .B1(n158), .A0N(\data_buf[2][1] ), .A1N(n158), 
        .Y(n88) );
  OAI2BB2XL U268 ( .B0(n174), .B1(n158), .A0N(\data_buf[2][0] ), .A1N(n158), 
        .Y(n87) );
  OAI2BB2XL U269 ( .B0(n167), .B1(n155), .A0N(\data_buf[5][7] ), .A1N(n155), 
        .Y(n118) );
  OAI2BB2XL U270 ( .B0(n168), .B1(n155), .A0N(\data_buf[5][6] ), .A1N(n155), 
        .Y(n117) );
  OAI2BB2XL U271 ( .B0(n169), .B1(n155), .A0N(\data_buf[5][5] ), .A1N(n155), 
        .Y(n116) );
  OAI2BB2XL U272 ( .B0(n170), .B1(n155), .A0N(\data_buf[5][4] ), .A1N(n155), 
        .Y(n115) );
  OAI2BB2XL U273 ( .B0(n171), .B1(n155), .A0N(\data_buf[5][3] ), .A1N(n155), 
        .Y(n114) );
  OAI2BB2XL U274 ( .B0(n172), .B1(n155), .A0N(\data_buf[5][2] ), .A1N(n155), 
        .Y(n113) );
  OAI2BB2XL U275 ( .B0(n173), .B1(n155), .A0N(\data_buf[5][1] ), .A1N(n155), 
        .Y(n112) );
  OAI2BB2XL U276 ( .B0(n174), .B1(n155), .A0N(\data_buf[5][0] ), .A1N(n155), 
        .Y(n111) );
  OAI2BB2XL U277 ( .B0(n167), .B1(n159), .A0N(\data_buf[1][7] ), .A1N(n159), 
        .Y(n86) );
  OAI2BB2XL U278 ( .B0(n168), .B1(n159), .A0N(\data_buf[1][6] ), .A1N(n159), 
        .Y(n85) );
  OAI2BB2XL U279 ( .B0(n169), .B1(n159), .A0N(\data_buf[1][5] ), .A1N(n159), 
        .Y(n84) );
  OAI2BB2XL U280 ( .B0(n170), .B1(n159), .A0N(\data_buf[1][4] ), .A1N(n159), 
        .Y(n83) );
  OAI2BB2XL U281 ( .B0(n171), .B1(n159), .A0N(\data_buf[1][3] ), .A1N(n159), 
        .Y(n82) );
  OAI2BB2XL U282 ( .B0(n172), .B1(n159), .A0N(\data_buf[1][2] ), .A1N(n159), 
        .Y(n81) );
  OAI2BB2XL U283 ( .B0(n173), .B1(n159), .A0N(\data_buf[1][1] ), .A1N(n159), 
        .Y(n80) );
  OAI2BB2XL U284 ( .B0(n174), .B1(n159), .A0N(\data_buf[1][0] ), .A1N(n159), 
        .Y(n79) );
  OAI2BB2XL U285 ( .B0(n167), .B1(n157), .A0N(\data_buf[3][7] ), .A1N(n157), 
        .Y(n102) );
  OAI2BB2XL U286 ( .B0(n168), .B1(n157), .A0N(\data_buf[3][6] ), .A1N(n157), 
        .Y(n101) );
  OAI2BB2XL U287 ( .B0(n169), .B1(n157), .A0N(\data_buf[3][5] ), .A1N(n157), 
        .Y(n100) );
  OAI2BB2XL U288 ( .B0(n170), .B1(n157), .A0N(\data_buf[3][4] ), .A1N(n157), 
        .Y(n99) );
  OAI2BB2XL U289 ( .B0(n171), .B1(n157), .A0N(\data_buf[3][3] ), .A1N(n157), 
        .Y(n98) );
  OAI2BB2XL U290 ( .B0(n172), .B1(n157), .A0N(\data_buf[3][2] ), .A1N(n157), 
        .Y(n97) );
  OAI2BB2XL U291 ( .B0(n173), .B1(n157), .A0N(\data_buf[3][1] ), .A1N(n157), 
        .Y(n96) );
  OAI2BB2XL U292 ( .B0(n174), .B1(n157), .A0N(\data_buf[3][0] ), .A1N(n157), 
        .Y(n95) );
  OAI2BB2XL U293 ( .B0(n167), .B1(n153), .A0N(\data_buf[7][7] ), .A1N(n153), 
        .Y(n134) );
  OAI2BB2XL U294 ( .B0(n168), .B1(n153), .A0N(\data_buf[7][6] ), .A1N(n153), 
        .Y(n133) );
  OAI2BB2XL U295 ( .B0(n169), .B1(n153), .A0N(\data_buf[7][5] ), .A1N(n153), 
        .Y(n132) );
  OAI2BB2XL U296 ( .B0(n170), .B1(n153), .A0N(\data_buf[7][4] ), .A1N(n153), 
        .Y(n131) );
  OAI2BB2XL U297 ( .B0(n171), .B1(n153), .A0N(\data_buf[7][3] ), .A1N(n153), 
        .Y(n130) );
  OAI2BB2XL U298 ( .B0(n172), .B1(n153), .A0N(\data_buf[7][2] ), .A1N(n153), 
        .Y(n129) );
  OAI2BB2XL U299 ( .B0(n173), .B1(n153), .A0N(\data_buf[7][1] ), .A1N(n153), 
        .Y(n128) );
  OAI2BB2XL U300 ( .B0(n174), .B1(n153), .A0N(\data_buf[7][0] ), .A1N(n153), 
        .Y(n127) );
  OAI2BB2XL U301 ( .B0(n160), .B1(n167), .A0N(\data_buf[0][7] ), .A1N(n160), 
        .Y(n78) );
  OAI2BB2XL U302 ( .B0(n160), .B1(n174), .A0N(\data_buf[0][0] ), .A1N(n160), 
        .Y(n77) );
  OAI2BB2XL U303 ( .B0(n160), .B1(n173), .A0N(\data_buf[0][1] ), .A1N(n160), 
        .Y(n76) );
  OAI2BB2XL U304 ( .B0(n160), .B1(n172), .A0N(\data_buf[0][2] ), .A1N(n160), 
        .Y(n75) );
  OAI2BB2XL U305 ( .B0(n160), .B1(n171), .A0N(\data_buf[0][3] ), .A1N(n160), 
        .Y(n74) );
  OAI2BB2XL U306 ( .B0(n160), .B1(n170), .A0N(\data_buf[0][4] ), .A1N(n160), 
        .Y(n73) );
  OAI2BB2XL U307 ( .B0(n160), .B1(n169), .A0N(\data_buf[0][5] ), .A1N(n160), 
        .Y(n72) );
  OAI2BB2XL U308 ( .B0(n160), .B1(n168), .A0N(\data_buf[0][6] ), .A1N(n160), 
        .Y(n71) );
  NAND2X1 U309 ( .A(cmd_valid), .B(n28), .Y(n24) );
  OAI21X1 U310 ( .A0(n5), .A1(n175), .B0(n43), .Y(n45) );
  NAND2X1 U311 ( .A(n6), .B(n5), .Y(n43) );
  OAI22XL U312 ( .A0(n14), .A1(n43), .B0(count[0]), .B1(n45), .Y(n137) );
  OAI22XL U313 ( .A0(n175), .A1(n45), .B0(n46), .B1(n7), .Y(n136) );
  AND2X2 U314 ( .A(n43), .B(n47), .Y(n46) );
  OAI21XL U315 ( .A0(n12), .A1(n43), .B0(n44), .Y(n135) );
  AO21X1 U316 ( .A0(n179), .A1(n177), .B0(n45), .Y(n44) );
  NOR2X1 U317 ( .A(n7), .B(n176), .Y(n27) );
  NAND3BX1 U318 ( .AN(n5), .B(n175), .C(\state[0] ), .Y(n26) );
  CLKINVX1 U319 ( .A(reset), .Y(n166) );
endmodule

