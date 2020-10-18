// Top module of your design, you cannot modify this module!!
module RISCV_Pipeline(
	// control interface
	clk, 
	rst_n,
    //----------I cache interface-------		
	ICACHE_ren,
	ICACHE_wen,
	ICACHE_addr,
	ICACHE_wdata,
	ICACHE_stall,
	ICACHE_rdata,
    //----------D cache interface-------
	DCACHE_ren,
	DCACHE_wen,
	DCACHE_addr,
	DCACHE_wdata,
	DCACHE_stall,
	DCACHE_rdata
);
	input			clk, rst_n;
	//----------I cache interface-------		
	output          ICACHE_ren;     //read_enable
	output          ICACHE_wen;		//write_enable
	output [29:0]   ICACHE_addr;	//address
	output [31:0]   ICACHE_wdata;	//write_in_cache
	input           ICACHE_stall;	//cache_finish?  0 : 1
	input  [31:0]   ICACHE_rdata;	//read_data_from_cache
	//----------D cache interface-------
	output          DCACHE_ren;
	output          DCACHE_wen;
	output [29:0]   DCACHE_addr;
	output [31:0]   DCACHE_wdata;
	input           DCACHE_stall;
	input  [31:0]   DCACHE_rdata;
	//==== wire/reg definition ================================
    // wire stall because of ICACHE or DCACHE
    wire stall;
    // IF
    wire hazard_stall, flush;
    wire [31:0] pc_next, IF_pc, IF_pc_add4, instr;
    // ID
    wire jalr, branch_or_jal, ID_RegWrite, ID_MemWrite, ID_MemRead, bubble, ID_ALUSrc;
    wire [1:0] ID_MemReg;
    wire [31:0] ID_pc, ID_pc_add4, pc_add_imm, rs_add_imm, read_data1, read_data2, ID_imm;
    wire [3:0] ALU_Control;
    // EX
    wire EX_MemRead, EX_RegWrite, EX_MemWrite, EX_ALUSrc;
    wire [1:0] EX_MemReg;
    wire [31:0] EX_read_data1, EX_imm, EX_pc_add4, result, EX_read_data2, EX_write_data;
    wire [4:0] EX_write_addr, rs, rt;
    wire [3:0] EX_ALU_Control;
    // MEM
    wire MEM_RegWrite;
    wire [1:0] MEM_MemReg;
    wire [31:0] MEM_pc_add4, MEM_result;
    wire [4:0] MEM_rd;
    // WB
    wire WB_reg_write;
    wire [1:0] WB_MemReg;
    wire [31:0] WB_write_data, WB_pc_add4, WB_read_data, WB_result;
    wire [4:0] WB_write_addr;
    wire [31:0] pc_2or4;
    //==== combinational circuit ==============================
    stage_IF stage0(.pc_2or4(pc_2or4),.pc_add4(IF_pc_add4), .pc_add_imm(pc_add_imm), .rs_add_imm(rs_add_imm), .jalr(jalr), .branch_or_jal(branch_or_jal), .pc_next(pc_next));
    pipeline_pc pipeline0(.clk(clk), .rst_n(rst_n), .stall(stall), .hazard_stall(hazard_stall), .pc_next(pc_next), .pc(IF_pc), .pc_add4(IF_pc_add4));
    assign ICACHE_ren = 1'b1;
    assign ICACHE_wen = 1'b0;
    assign ICACHE_addr = IF_pc[31:2];
    assign ICACHE_wdata = 32'b0;
    assign stall = (ICACHE_stall | DCACHE_stall);
    pipeline_IF_ID pipeline1(.pc_2or4(pc_2or4),.clk(clk), .rst_n(rst_n), .stall(stall), .hazard_stall(hazard_stall), .flush(flush), .I_instr(ICACHE_rdata),
                             .instr(instr), .pc(IF_pc), .pc_out(ID_pc), .pc_add4(IF_pc_add4), .pc_add4_out(ID_pc_add4));    
    stage_ID stage1(.clk(clk), .rst_n(rst_n), .pc(ID_pc), .instr(instr), .EX_MemRead(EX_MemRead), .EX_write_addr(EX_write_addr), .WB_reg_write(WB_reg_write), .bubble(bubble), .WB_write_data(WB_write_data), 
                    .WB_write_addr(WB_write_addr), .hazard_stall(hazard_stall), .flush(flush), .pc_add_imm(pc_add_imm), .rs_add_imm(rs_add_imm), .jalr(jalr), .branch_or_jal(branch_or_jal), 
                    .ALU_Control(ALU_Control), .RegWrite_o(ID_RegWrite), .MemWrite(ID_MemWrite), .MemRead(ID_MemRead), .MemReg(ID_MemReg), .read_data1(read_data1), .read_data2(read_data2),
                    .EX_result(result), .EX_RegWrite(EX_RegWrite), .MEM_result(MEM_result), .MEM_RegWrite(MEM_RegWrite), .MEM_rd(MEM_rd), .imm(ID_imm), .ALUSrc(ID_ALUSrc));
    pipeline_ID_EX pipeline2(.clk(clk), .rst_n(rst_n), .D_stall(stall), .bubble(bubble), .i_rs(instr[19:15]), .i_rt(instr[24:20]), .i_rd(instr[11:7]), .i_ALU_Control(ALU_Control), .i_read_data1(read_data1), .i_ALUSru(ID_ALUSrc),
                             .i_imm(ID_imm), .i_RegWrite(ID_RegWrite), .i_MemWrite(ID_MemWrite), .i_MemRead(ID_MemRead), .i_MemReg(ID_MemReg), .i_pc_add4(ID_pc_add4), .i_read_data2(read_data2),.o_RegWrite(EX_RegWrite),
                             .o_MemWrite(EX_MemWrite), .o_MemRead(EX_MemRead), .o_MemReg(EX_MemReg), .o_read_data1(EX_read_data1), .o_imm(EX_imm), .o_pc_add4(EX_pc_add4),
                             .o_rs(rs), .o_rt(rt), .o_rd(EX_write_addr), .o_ALU_Control(EX_ALU_Control), .o_read_data2(EX_read_data2), .o_ALUSrc(EX_ALUSrc));                
    stage_EX stage2(.MemRead(EX_MemRead), .read_data1(EX_read_data1), .read_data2(EX_read_data2), .rs(rs), .rt(rt), .rd(EX_write_addr), .ALU_Control(EX_ALU_Control), .MEM_RegWrite(MEM_RegWrite), 
                    .WB_RegWrite(WB_reg_write), .MEM_rd(MEM_rd), .WB_rd(WB_write_addr), .MEM_write_data(MEM_result), .WB_write_data(WB_write_data), .result(result), .imm(EX_imm), .ALUSrc(EX_ALUSrc), .data2_r(EX_write_data));
    pipeline_EX_MEM pipeline3(.clk(clk), .rst_n(rst_n), .D_stall(stall), .i_RegWrite(EX_RegWrite), .i_MemWrite(EX_MemWrite), .i_MemRead(EX_MemRead), .i_MemReg(EX_MemReg), .i_pc_add4(EX_pc_add4),
                              .i_rd(EX_write_addr), .result(result), .i_write_data(EX_write_data), .o_RegWrite(MEM_RegWrite), .o_MemWrite(DCACHE_wen), .o_MemRead(DCACHE_ren), .o_MemReg(MEM_MemReg),
                              .o_pc_add4(MEM_pc_add4), .o_write_data(DCACHE_wdata), .o_result(MEM_result), .o_rd(MEM_rd));
    assign DCACHE_addr = MEM_result[31:2];
    pipeline_MEM_WB pipeline4(.clk(clk), .rst_n(rst_n), .D_stall(stall), .i_RegWrite(MEM_RegWrite), .i_MemReg(MEM_MemReg), .i_pc_add4(MEM_pc_add4), .i_read_data(DCACHE_rdata), .result(MEM_result), 
                              .i_rd(MEM_rd), .o_RegWrite(WB_reg_write), .o_MemReg(WB_MemReg), .o_pc_add4(WB_pc_add4), .o_read_data(WB_read_data), .o_result(WB_result), .o_rd(WB_write_addr));
    stage_WB stage3(.pc_add4(WB_pc_add4), .rdata(WB_read_data), .result(WB_result), .MemReg(WB_MemReg), .write_data(WB_write_data));
endmodule

module stage_IF(
    pc_add4,
    pc_add_imm,
    rs_add_imm,
    jalr,
    branch_or_jal,
    pc_next,
    pc_2or4 // 1 if pc+4 0 if pc+2
);  
    //==== input/output =======================================
    input jalr, branch_or_jal;
    input [31:0] pc_add4, pc_add_imm, rs_add_imm;
    output [31:0] pc_next;
    //==== wire/reg definition ================================
    wire [31:0] pc_0;
    input [31:0] pc_2or4;
    //==== combinational circuit ==============================
    assign pc_0 = (branch_or_jal)?  pc_add_imm : pc_2or4;
    assign pc_next = (jalr)? rs_add_imm : pc_0;
endmodule

module pipeline_pc(  // instruction fetch
    clk,
    rst_n,
    stall,
    hazard_stall,
    pc_next,
    pc,
    pc_add4
);
    //==== input/output =======================================
    input clk, rst_n, stall, hazard_stall;
    input [31:0] pc_next;
    output [31:0] pc, pc_add4;
    //==== wire/reg definition ================================
    reg [31:0] pc_r;
    //==== combinational circuit ==============================
    assign pc = pc_r;
    assign pc_add4 = pc + 4;
    //==== sequential circuit =================================
    always@ (posedge clk) begin
        if(!rst_n) pc_r <= 32'b0;
        else if (stall || hazard_stall) 
            pc_r <= pc;
        else pc_r <= pc_next;
    end
endmodule

module pipeline_IF_ID(  // instruction fetch
    clk,
    rst_n,
    stall,
    hazard_stall,
    flush,
    I_instr,
    instr,
    pc,
    pc_out,
    pc_add4,
    pc_add4_out, // for jal storing pc+4 or pc+2
    pc_2or4 // for next pc
   
);
    //==== input/output =======================================
    input clk, rst_n, stall, hazard_stall, flush;
    input [31:0] I_instr, pc, pc_add4;
    output [31:0] instr, pc_out;
    output  [31:0] pc_add4_out;
    output reg [31:0] pc_2or4;
    parameter TOP=0;
    parameter TOP32=1;
    parameter SECOND16=2;
    //==== wire/reg definition ================================
    reg [31:0] instr_r, pc_r, pc_add4_r,pc_add4_out_r,pc_add4_out_w;
    reg [1:0] state_w,state_r;
    wire [31:0] temp32,inst16;
    wire [31:0] pc2, inst16_32;
    reg [15:0] bottom_w,bottom_r;
    wire [31:0] temp16_0;
    reg [31:0] inst_temp;
    wire [15:0] decom_in;
     //==== combinational circuit ==============================
    assign instr = instr_r;
    assign pc_out = pc_r;
    assign temp32={I_instr[7:0], I_instr[15:8], I_instr[23:16], I_instr[31:24]};
    assign inst16={I_instr[23:16],I_instr[31:24],I_instr[7:0],I_instr[15:8]};
    assign pc2=pc+2;
    assign pc_add4_out=pc_add4_out_r;
    assign inst16_32={I_instr[23:16],I_instr[31:24],I_instr[7:0],I_instr[15:8]};
    assign decom_in=(state_r==SECOND16)?inst16[15:0]:inst16[31:16];
    decom decom1 (.mem_rdata_I(decom_in),.inst(temp16_0));
    always@(*) begin
        state_w=0;
        bottom_w={I_instr[7:0],I_instr[15:8]};
        pc_add4_out_w=pc2;
        inst_temp=temp16_0;
        pc_2or4=pc2;
        case (state_r)
            TOP:begin
                if(I_instr[25:24]==2'b11) begin // all 32
                    state_w=TOP;
                    inst_temp=temp32;
                    pc_2or4=pc_add4;
                    pc_add4_out_w=pc_add4;
                end 
                else if(I_instr[9:8]==2'b11) begin // 16+32
                    state_w=TOP32;
                    inst_temp=temp16_0;
                    pc_2or4=pc_add4;
                    pc_add4_out_w=pc_add4;
                end
                else begin // 16+16
                    state_w=SECOND16;
                    inst_temp=temp16_0;
                    pc_2or4=pc2;
                    pc_add4_out_w=pc2;
                end

            end 
            TOP32: begin
                if(I_instr[9:8]==2'b11) begin //32+32
                    state_w=TOP32;
                    inst_temp={I_instr[23:16],I_instr[31:24],bottom_r};
                    pc_2or4=pc_add4;
                    pc_add4_out_w=pc_add4;
                end
                else begin //32+16
                    state_w=SECOND16;
                    inst_temp={I_instr[23:16],I_instr[31:24],bottom_r};
                    pc_2or4=pc2;
                    pc_add4_out_w=pc2;
                end
            end
            SECOND16: begin //at bottom and currently 16
                state_w=TOP;
                inst_temp=temp16_0; 
                pc_2or4=pc2;
                pc_add4_out_w=pc2;                
            end
            default: begin
                state_w=TOP;
            end
        endcase
    end
    //==== sequential circuit =================================
    always@ (posedge clk) begin
        if(!rst_n) begin
            instr_r <= 32'b0;
            pc_r <= 32'b0;
            pc_add4_r <= 32'b0;
            state_r<=0;
            bottom_r<=0;
            pc_add4_out_r<=32'b0;
        end
        else if (stall || hazard_stall) begin
            instr_r <= instr;
            pc_r <= pc_out;
            pc_add4_r <= pc_add4_out;
            state_r<=state_r;
            bottom_r<=bottom_r;
            pc_add4_out_r<=pc_add4_out_r;
        end 
        else if (flush) begin
            instr_r <= 32'b0;
            pc_r <= 32'b0;
            pc_add4_r <= 32'b0;
            state_r<=0;
            bottom_r<=0;
            pc_add4_out_r<=32'b0;
        end
        else begin
            instr_r <= inst_temp;
            pc_r <= pc;
            pc_add4_r <= pc_add4;
            state_r<=state_w;
            bottom_r<=bottom_w;
            pc_add4_out_r<=pc_add4_out_w;
        end
    end
endmodule
module decom (mem_rdata_I,inst);
// need to support jalr,i type(addi), bne, slt
input [15:0] mem_rdata_I;
output reg [31:0] inst ;
wire [4:0] rd_lw,rs_lw,rs1_sw,rs2_sw,rd_and,rs2_and,rd_or,rs2_or,rd_sub,rs2_sub,rs1_beq,rs1_bnez,rd_srli,rd_srai,rd_andi;
assign rd_lw=mem_rdata_I[4:2]+8;
assign rs_lw=mem_rdata_I[9:7]+8;
assign rs1_sw=rs_lw;
assign rs2_sw=rd_lw;
assign rs2_and=rd_lw;
assign rd_and=rs_lw;
assign rd_or=rs_lw;
assign rs2_or=rd_lw;
assign rd_sub=rs_lw;
assign rs2_sub=rd_lw;
assign rs1_beq=rs_lw;
assign rs1_bnez=rs_lw;
assign rd_srli=rs_lw;
assign rd_srai=rs_lw;
assign rd_andi=rs_lw;
always@(*) begin
   inst={5'b0,mem_rdata_I[5],mem_rdata_I[12],rs2_sw,rs1_sw,3'b010,mem_rdata_I[11:10],mem_rdata_I[6],2'b0,7'b0100011};
    
    case (mem_rdata_I[1:0])
        
        2'b00: begin
            /*
            if (mem_rdata_I[15:13]==3'b110) begin //sw
               inst={5'b0,mem_rdata_I[5],mem_rdata_I[12],rs2_sw,rs1_sw,3'b010,mem_rdata_I[11:10],mem_rdata_I[6],2'b0,7'b0100011};
            end
            else begin //lw
                inst={5'b0,mem_rdata_I[5],mem_rdata_I[12:10],mem_rdata_I[6],2'b0,rs_lw,3'b010,rd_lw,7'b0000011};
            end
            */
            case (mem_rdata_I[15:13])
                3'b110:  inst={5'b0,mem_rdata_I[5],mem_rdata_I[12],rs2_sw,rs1_sw,3'b010,mem_rdata_I[11:10],mem_rdata_I[6],2'b0,7'b0100011};
                3'b000: inst=32'b00000000000000000000000000010011;
                default: inst={5'b0,mem_rdata_I[5],mem_rdata_I[12:10],mem_rdata_I[6],2'b0,rs_lw,3'b010,rd_lw,7'b0000011};
            endcase
        end 
        2'b10: begin
        case (mem_rdata_I[15:13])
            3'b000: begin
                inst={7'b0,mem_rdata_I[6:2],mem_rdata_I[11:7],3'b001,mem_rdata_I[11:7],7'b0010011}; // c.slli
            end
            3'b100:begin
                if(mem_rdata_I[12]) begin
                    if (mem_rdata_I[4]) begin //add
                        inst={7'b0,mem_rdata_I[6:2],mem_rdata_I[11:7],3'b0,mem_rdata_I[11:7],7'b0110011};
                    end
                    else begin //jalr
                        inst={12'b0,mem_rdata_I[11:7],3'b0,5'd1,7'b1100111};
                        //inst={12'b0,mem_rdata_I[11:7],3'b0,mem_rdata_I[6:2],7'b1100111};
                    end
                end
                else begin //mv
                    if(!mem_rdata_I[10]) begin
                        inst={12'b0,mem_rdata_I[11:7],3'b0,5'b0,7'b1100111}; //jr
                    end
                    else  begin
                        inst={12'b0,mem_rdata_I[6:2],3'b0,mem_rdata_I[11:7],7'b0010011}; 
                    end
                    
                end
            end
            default: ;
        endcase
        end
        default: //2'b01
        begin
            case (mem_rdata_I[15:13])
                3'b000: begin
                 inst={{7{mem_rdata_I[12]}},mem_rdata_I[6:2],mem_rdata_I[11:7],3'b0,mem_rdata_I[11:7],7'b0010011}; // c.addi
                end
                3'b001: begin
                 inst={mem_rdata_I[12],mem_rdata_I[8],mem_rdata_I[10:9],mem_rdata_I[6],mem_rdata_I[7],
                 mem_rdata_I[2],mem_rdata_I[11],mem_rdata_I[5:3],{9{mem_rdata_I[12]}},5'b00001,7'b1101111}; //jal 
                end
                3'b100: begin
                    if(mem_rdata_I[11:10]==2'b01) begin //srai
                        inst={7'b0100000,mem_rdata_I[6:2],rd_srai,3'b101,rd_srai,7'b0010011};
                    end
                    else if(mem_rdata_I[11:10]==2'b00) begin //srli
                        inst={7'b0,mem_rdata_I[6:2],rd_srli,3'b101,rd_srli,7'b0010011};
                    end
                    else begin //andi
                        inst={{7{mem_rdata_I[12]}},mem_rdata_I[6:2],rd_andi,3'b111,rd_andi,7'b0010011};
                    end
                end
                3'b101: begin inst={mem_rdata_I[12],mem_rdata_I[8],mem_rdata_I[10:9],mem_rdata_I[6],mem_rdata_I[7],mem_rdata_I[2],mem_rdata_I[11],
                mem_rdata_I[5:3],{9{mem_rdata_I[12]}},5'b00000,7'b1101111};   //c.j
                end
                3'b110: inst={{4{mem_rdata_I[12]}},mem_rdata_I[6:5],mem_rdata_I[2],5'b0,rs1_beq,3'b0,mem_rdata_I[11:10],mem_rdata_I[4:3],mem_rdata_I[12],7'b1100011}; //beqz
                3'b111: inst={{4{mem_rdata_I[12]}},mem_rdata_I[6:5],mem_rdata_I[2],5'b0,rs1_bnez,3'b001,mem_rdata_I[11:10],mem_rdata_I[4:3],mem_rdata_I[12],7'b1100011}; //bnez
                default:; 
            endcase
            
        end
    endcase
    
end


endmodule
module stage_ID(  // instruction fetch
    clk,
    rst_n,
    pc, 
    instr,
    EX_MemRead, 
    EX_write_addr,
    WB_reg_write,
    WB_write_data,
    WB_write_addr,
    hazard_stall,
    flush,
    pc_add_imm,
    rs_add_imm,
    jalr,
    branch_or_jal,
    ALU_Control,
    RegWrite_o,
    MemWrite, 
    MemRead, 
    MemReg,
    bubble,
    read_data1, 
    read_data_2,
    read_data2, 
    EX_result,
    MEM_result,
    EX_RegWrite,
    MEM_RegWrite,
    MEM_rd,
    imm,
    ALUSrc,
);
    //==== input/output =======================================
    input clk, rst_n, EX_MemRead, WB_reg_write, EX_RegWrite, MEM_RegWrite;
    input [31:0] instr, WB_write_data, pc, EX_result, MEM_result;
    input [4:0] WB_write_addr, EX_write_addr, MEM_rd;
    // EX_result(), .EX_RegWrite(), EX_write_addr                 .MEM_result(), .MEM_RegWrite()    MEM_rd    WB_write_data   WB_reg_write     WB_write_addr
    output flush, branch_or_jal;
    output [31:0] pc_add_imm, rs_add_imm, read_data1, read_data_2, read_data2;
    output reg [31:0] imm;
    output reg [3:0] ALU_Control;
    output reg jalr, hazard_stall, MemWrite, MemRead, bubble, RegWrite_o, ALUSrc;
    output reg [1:0] MemReg;
    //==== wire/reg definition ================================
    // control unit
    reg beq, bne, jal, RegWrite;
    // forward unit
    reg [31:0] data1, data2;
    // equal
    wire zero;
    //==== combinational circuit ==============================
    Registers Registers0(.clk(clk), .rst_n(rst_n), .RegWrite(WB_reg_write), 
                        .RegWrite_data(WB_write_data), .Read_add1(instr[19:15]), 
                        .Read_add2(instr[24:20]), .Write_add(WB_write_addr),
                        .Read_data1(read_data1), .Read_data2(read_data2));
    always @(*) begin   // forward unit data1
        if      (EX_RegWrite && (EX_write_addr == instr[19:15]))    data1 = EX_result;
        else if (MEM_RegWrite && (MEM_rd == instr[19:15]))          data1 = MEM_result;
        else if (WB_reg_write && (WB_write_addr == instr[19:15]))   data1 = WB_write_data;
        else                                                        data1 = read_data1;
    end
    always @(*) begin   // forward unit
        if (EX_RegWrite && (EX_write_addr == instr[24:20]))         data2 = EX_result;
        else if (MEM_RegWrite && (MEM_rd == instr[24:20]))          data2 = MEM_result;
        else if (WB_reg_write && (WB_write_addr == instr[24:20]))   data2 = WB_write_data;
        else                                                        data2 = read_data2;
    end
    always @(*) begin   // control unit
        if (!rst_n) begin
            beq = 0;
            bne = 0;
            MemWrite = 0;
            MemRead = 0;
            ALUSrc = 0;
            RegWrite = 0;
            MemReg = 0;
            jal = 0;
            jalr = 0;
        end else begin
            case(instr[6:0])
                7'b0110011: begin // R-type
                    beq = 0;
                    bne = 0;
                    MemWrite = 0;
                    MemRead = 0;
                    ALUSrc = 0;
                    RegWrite = 1;
                    MemReg = 0;
                    jal = 0;
                    jalr = 0;
                end
                7'b0100011: begin // sw
                    beq = 0;
                    bne = 0;
                    MemWrite = 1;
                    MemRead = 0;
                    ALUSrc = 1;
                    RegWrite = 0;
                    MemReg = 0;
                    jal = 0;
                    jalr = 0;
                end
                7'b0000011: begin // lw
                    beq = 0;
                    bne = 0;
                    MemWrite = 0;
                    MemRead = 1;
                    ALUSrc = 1;
                    RegWrite = 1;
                    MemReg = 1;
                    jal = 0;
                    jalr = 0;
                end
                7'b1100011: begin // beq, bne
                    MemWrite = 0;
                    MemRead = 0;
                    ALUSrc = 0;
                    RegWrite = 0;
                    MemReg = 0;
                    jal = 0;
                    jalr = 0;
                    if (instr[12]) begin
                        beq = 0;
                        bne = 1;
                    end else begin
                        beq = 1;
                        bne = 0;
                    end
                end
                7'b1101111: begin // jal
                    beq = 0;
                    bne = 0;
                    MemWrite = 0;
                    MemRead = 0;
                    ALUSrc = 1;
                    RegWrite = 1;
                    MemReg = 2;
                    jal = 1;
                    jalr = 0;
                end
                7'b1100111: begin // jalr
                    beq = 0;
                    bne = 0;
                    MemWrite = 0;
                    MemRead = 0;
                    ALUSrc = 1;
                    RegWrite = 1;
                    MemReg = 2;
                    jal = 0;
                    jalr = 1;
                end
                7'b0010011: begin // R-type with constant(imm)
                    beq = 0;
                    bne = 0;
                    MemWrite = 0;
                    MemRead = 0;
                    ALUSrc = 1;
                    RegWrite = 1;
                    MemReg = 0;
                    jal = 0;
                    jalr = 0;
                end
                default: begin
                    beq = 0;
                    bne = 0;
                    MemWrite = 0;
                    MemRead = 0;
                    ALUSrc = 0;
                    RegWrite = 0;
                    MemReg = 0;
                    jal = 0;
                    jalr = 0;
                end
            endcase
        end
    end
    always @(*) begin   // RegWrite = 0 when write_addr = 0
        if (|instr[11:7]) RegWrite_o = RegWrite;
        else RegWrite_o = 1'b0;
    end
    always @(*) begin   // imm
        if (!rst_n) imm = 32'b0;
        else begin
            case(instr[6:0])
                7'b0100011: begin // sw
                    imm = {{21{instr[31]}}, instr[30:25], instr[11:8], instr[7]};
                end
                7'b0000011: begin // lw
                    imm = {{21{instr[31]}}, instr[30:25], instr[24:21], instr[20]};
                end
                7'b1100011: begin // beq
                    imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
                end
                7'b1101111: begin // jal
                    imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:25], instr[24:21], 1'b0};
                end
                7'b1100111: begin // jalr
                    imm = {{21{instr[31]}}, instr[30:25], instr[24:21], instr[20]};
                end
                7'b0010011: begin // I type
                    imm = {{21{instr[31]}}, instr[30:25], instr[24:21], instr[20]};
                end
                default: begin
                    imm = 32'b0;
                end
            endcase
        end
    end
    always @(*) begin   // lw data hazard
        if (EX_MemRead) begin
            if ((EX_write_addr == instr[19:15]) | (EX_write_addr == instr[24:20])) begin
                bubble = 1'b1;
                hazard_stall = 1'b1;
            end else begin
                bubble = 1'b0;
                hazard_stall = 1'b0;
            end
        end else begin
            bubble = 1'b0;
            hazard_stall = 1'b0;
        end
    end
    // pc
    assign zero = (data1 == data2);
    assign pc_add_imm = pc + imm;
    assign rs_add_imm = data1 + imm;
    assign branch_or_jal = jal | ((beq & zero) | (bne & (~zero)));
    assign flush = branch_or_jal | jalr;
    // ALU_Control
    always@(*) begin // {instr[30], instr[14:12], instr[5:4]}
        case (instr[4:3])
            2'b10 : begin     // R type
                case (instr[14:13])
                    2'b11 : begin
                        if (instr[12]) ALU_Control = 4'b0000;   // and
                        else ALU_Control = 4'b0001;             // or
                    end
                    2'b10 : begin
                        if (instr[12]) begin
                            if (instr[30]) ALU_Control = 4'b0110;   // srai
                            else ALU_Control = 4'b0111;             // srli
                        end 
                        else ALU_Control = 4'b0010;      // xor
                    end
                    2'b01 : ALU_Control = 4'b0011;      // slt
                    2'b00 : begin
                        if (instr[12]) ALU_Control = 4'b0101;       // slli
                        else begin
                            if (instr[31:30]==2'b01) ALU_Control = 4'b0100;   // sub
                            else ALU_Control = 4'b1000;             // add
                        end
                    end
                endcase
            end
            2'b01 : begin
                ALU_Control = 4'b1000;
            end
            2'b00 : begin
                ALU_Control = 4'b1000;
            end
            default : begin
                ALU_Control = 4'b1000;
            end
        endcase
    end
endmodule

module Registers(
    input clk, rst_n, RegWrite,
    input[31:0] RegWrite_data,
    input[4:0] Read_add1, Read_add2, Write_add,
    output[31:0] Read_data1, Read_data2
);
    reg[31:0] reg_array[31:0];
    integer i;
    wire [31:0] rs, rt;
    wire rs_rd, rt_rd, or_Wadd;

    assign rs = (|Read_add1)? reg_array[Read_add1] : 32'b0;
    assign rt = (|Read_add2)? reg_array[Read_add2] : 32'b0;
    assign or_Wadd = (|Write_add);
    assign rs_rd = (Read_add1 == Write_add);
    assign rt_rd = (Read_add2 == Write_add);
    assign Read_data1 = (!RegWrite)? rs :
                        (or_Wadd && rs_rd)? RegWrite_data : rs;
    assign Read_data2 = (!RegWrite)? rt :
                        (or_Wadd && rt_rd)? RegWrite_data : rt;

    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for(i = 0; i < 32; i = i + 1) begin 
                reg_array[i] <= 32'b0;
            end
        end else begin
            if (RegWrite) begin
                reg_array[Write_add] <= RegWrite_data;
            end
        end
    end
endmodule

module pipeline_ID_EX(
    clk,
    rst_n,
    D_stall,
    bubble,
    i_rs,
    i_rt,
    i_rd,
    i_ALU_Control,
    i_read_data1,
    i_imm,
    i_RegWrite,
    i_MemWrite, 
    i_MemRead, 
    i_MemReg,
    i_pc_add4,
    i_read_data2,
    i_ALUSru,
    o_RegWrite, 
    o_MemWrite, 
    o_MemRead, 
    o_MemReg,
    o_read_data1, 
    o_imm, 
    o_pc_add4,
    o_read_data2,
    o_rs, 
    o_rt, 
    o_rd,
    o_ALU_Control,
    o_ALUSrc
);
    //==== input/output =======================================
    input clk, rst_n, D_stall, bubble;
    input i_RegWrite, i_MemWrite, i_MemRead, i_ALUSru; 
    input [1:0] i_MemReg;
    input [31:0] i_read_data1, i_imm, i_pc_add4, i_read_data2;
    input [4:0] i_rs, i_rt, i_rd;
    input [3:0] i_ALU_Control;
    output o_RegWrite, o_MemWrite, o_MemRead, o_ALUSrc;
    output [1:0] o_MemReg;
    output [31:0] o_read_data1, o_imm, o_pc_add4, o_read_data2;
    output [4:0] o_rs, o_rt, o_rd;
    output [3:0] o_ALU_Control;
    //==== wire/reg definition ================================
    reg o_RegWrite_r, o_MemWrite_r, o_MemRead_r, o_ALUSrc_r;
    reg [1:0] o_MemReg_r;
    reg [31:0] o_read_data1_r, o_imm_r, o_pc_add4_r, o_read_data2_r;
    reg [4:0] o_rs_r, o_rt_r, o_rd_r;
    reg [3:0] o_ALU_Control_r;
    //==== combinational circuit ==============================
    assign o_RegWrite = o_RegWrite_r; 
    assign o_MemWrite = o_MemWrite_r; 
    assign o_MemRead = o_MemRead_r; 
    assign o_MemReg = o_MemReg_r;
    assign o_read_data1 = o_read_data1_r; 
    assign o_imm = o_imm_r; 
    assign o_pc_add4 = o_pc_add4_r;
    assign o_rs = o_rs_r; 
    assign o_rt = o_rt_r; 
    assign o_rd = o_rd_r;
    assign o_ALU_Control = o_ALU_Control_r;
    assign o_read_data2 = o_read_data2_r;
    assign o_ALUSrc = o_ALUSrc_r;
    //==== sequential circuit =================================
    always@ (posedge clk) begin
        if(!rst_n) begin
            o_RegWrite_r <= 1'b0; 
            o_MemWrite_r <= 1'b0; 
            o_MemRead_r <= 1'b0; 
            o_ALUSrc_r <= 1'b0;
            o_MemReg_r <= 2'b0;
            o_read_data1_r <= 32'b0; 
            o_imm_r <= 32'b0; 
            o_pc_add4_r  <= 32'b0;
            o_read_data2_r <= 32'b0;
            o_rs_r <= 5'b0; 
            o_rt_r <= 5'b0; 
            o_rd_r <= 5'b0;
            o_ALU_Control_r <= 4'b0;
        end
        else if (D_stall) begin
            o_RegWrite_r <= o_RegWrite; 
            o_MemWrite_r <= o_MemWrite; 
            o_MemRead_r <= o_MemRead; 
            o_ALUSrc_r <= o_ALUSrc;
            o_MemReg_r <= o_MemReg;
            o_read_data1_r <= o_read_data1; 
            o_imm_r <= o_imm; 
            o_pc_add4_r <= o_pc_add4;
            o_read_data2_r <= o_read_data2;
            o_rs_r <= o_rs; 
            o_rt_r <= o_rt; 
            o_rd_r <= o_rd;
            o_ALU_Control_r <= o_ALU_Control;
        end 
        else if(bubble) begin
            o_RegWrite_r <= 1'b0; 
            o_MemWrite_r <= 1'b0; 
            o_MemRead_r <= 1'b0; 
            o_ALUSrc_r <= 1'b0;
            o_MemReg_r <= 2'b0;
            o_read_data1_r <= 32'b0; 
            o_imm_r <= 32'b0; 
            o_pc_add4_r  <= 32'b0;
            o_read_data2_r <= 32'b0;
            o_rs_r <= 5'b0; 
            o_rt_r <= 5'b0; 
            o_rd_r <= 5'b0;
            o_ALU_Control_r <= 4'b0;
        end
        else begin
            o_RegWrite_r <= i_RegWrite; 
            o_MemWrite_r <= i_MemWrite; 
            o_MemRead_r <= i_MemRead; 
            o_ALUSrc_r <= i_ALUSru;
            o_MemReg_r <= i_MemReg;
            o_read_data1_r <= i_read_data1; 
            o_imm_r <= i_imm; 
            o_pc_add4_r <= i_pc_add4;
            o_read_data2_r <= i_read_data2;
            o_rs_r <= i_rs; 
            o_rt_r <= i_rt; 
            o_rd_r <= i_rd;
            o_ALU_Control_r <= i_ALU_Control;
        end
    end
endmodule

module stage_EX( 
    MemRead, 
    read_data1, 
    read_data2, 
    rs, 
    rt, 
    rd,
    ALU_Control,
    MEM_RegWrite,
    WB_RegWrite,
    MEM_rd,
    WB_rd,
    MEM_write_data,
    WB_write_data,
    result,
    imm,
    ALUSrc,
    data2_r
);
    //==== input/output =======================================
    input MemRead, MEM_RegWrite, WB_RegWrite, ALUSrc; 
    input [31:0] read_data1, read_data2, MEM_write_data, WB_write_data, imm;
    input [4:0] rs, rt, rd, MEM_rd, WB_rd;
    input [3:0] ALU_Control;
    output reg [31:0] result, data2_r;
    //==== wire/reg definition ================================
    // forward
    reg [31:0] data1_r;
    wire [31:0] data1_w, data2_w;
    //==== combinational circuit ==============================
    assign data1_w = data1_r;
    always @(*) begin   // forward unit data1
        if      (MEM_RegWrite && (MEM_rd == rs)&&(rs!=0))    data1_r = MEM_write_data;
        else if (WB_RegWrite && (WB_rd == rs)&&(rs!=0))      data1_r = WB_write_data;
        else                                        data1_r = read_data1;
    end
    always @(*) begin   // forward unit data2
        if      (MEM_RegWrite && (MEM_rd == rt))    data2_r = MEM_write_data;
        else if (WB_RegWrite && (WB_rd == rt))      data2_r = WB_write_data;
        else                                        data2_r = read_data2;
    end
    // ALUSrc
    assign data2_w = (ALUSrc)? imm : data2_r;
    always @(*) begin   // ALU
        if (ALU_Control[3]) result = data1_r + data2_w;
        else begin
            case(ALU_Control[2:0])
                3'b000: result = data1_r & data2_w;
                3'b001: result = data1_r | data2_w;
                3'b010: result = data1_r ^ data2_w;
                3'b011: begin 
                    if($signed(data1_r) < $signed(data2_w)) result = 32'b1;
                    else result = 32'b0;
                end
                3'b100: result = $signed(data1_r) - $signed(data2_w);
                3'b101: result = data1_r << data2_w[4:0];
                3'b110: result = $signed(data1_r) >>> data2_w[4:0];
                3'b111: result = data1_r >> data2_w[4:0];
                default: result = 32'b0;
            endcase
        end
    end
endmodule

module pipeline_EX_MEM(
    clk,
    rst_n,
    D_stall,
    i_RegWrite,
    i_MemWrite, 
    i_MemRead, 
    i_MemReg,
    i_pc_add4,
    result,
    i_write_data,
    i_rd,
    o_RegWrite, 
    o_MemWrite, 
    o_MemRead, 
    o_MemReg,
    o_pc_add4,
    o_write_data,
    o_result,
    o_rd
);  
    //==== input/output =======================================
    input clk, rst_n, D_stall;
    input i_RegWrite, i_MemWrite, i_MemRead; 
    input [1:0] i_MemReg;
    input [4:0] i_rd;
    input [31:0] i_pc_add4, i_write_data, result;
    output o_RegWrite, o_MemWrite, o_MemRead;
    output [1:0] o_MemReg;
    output [4:0] o_rd;
    output [31:0] o_pc_add4, o_write_data, o_result;
    //==== wire/reg definition ================================
    reg o_RegWrite_r, o_MemWrite_r, o_MemRead_r;
    reg [1:0] o_MemReg_r;
    reg [4:0] o_rd_r;
    reg [31:0] o_pc_add4_r, write_data, o_result_r;
    //==== combinational circuit ==============================
    assign o_RegWrite = o_RegWrite_r; 
    assign o_MemWrite = o_MemWrite_r; 
    assign o_MemRead = o_MemRead_r; 
    assign o_MemReg = o_MemReg_r;
    assign o_pc_add4 = o_pc_add4_r;
    assign o_result = o_result_r;
    assign o_write_data = write_data;
    assign o_rd = o_rd_r;
    //==== sequential circuit =================================
    always@ (posedge clk) begin
        if(!rst_n) begin
            o_RegWrite_r <= 1'b0; 
            o_MemWrite_r <= 1'b0; 
            o_MemRead_r <= 1'b0; 
            o_MemReg_r <= 2'b0;
            o_pc_add4_r  <= 32'b0;
            o_result_r <= 32'b0;
            write_data <= 32'b0;
            o_rd_r <= 5'b0;
        end
        else if (D_stall) begin
            o_RegWrite_r <= o_RegWrite; 
            o_MemWrite_r <= o_MemWrite; 
            o_MemRead_r <= o_MemRead; 
            o_MemReg_r <= o_MemReg;
            o_pc_add4_r <= o_pc_add4;
            o_result_r <= o_result;
            write_data <= o_write_data;
            o_rd_r <= o_rd;
        end
        else begin
            o_RegWrite_r <= i_RegWrite; 
            o_MemWrite_r <= i_MemWrite; 
            o_MemRead_r <= i_MemRead; 
            o_MemReg_r <= i_MemReg;
            o_pc_add4_r <= i_pc_add4;
            o_result_r <= result;
            write_data <= {i_write_data[7:0], i_write_data[15:8], i_write_data[23:16], i_write_data[31:24]};
            o_rd_r <= i_rd;
        end
    end
endmodule

module pipeline_MEM_WB(
    clk,
    rst_n,
    D_stall,
    i_RegWrite,
    i_MemReg,
    i_pc_add4,
    i_read_data,
    result,
    i_rd,
    o_RegWrite, 
    o_MemReg,
    o_pc_add4,
    o_read_data,
    o_result,
    o_rd
);
    //==== input/output =======================================
    input clk, rst_n, D_stall;
    input i_RegWrite; 
    input [1:0] i_MemReg;
    input [4:0] i_rd;
    input [31:0] i_pc_add4, result, i_read_data;
    output o_RegWrite;
    output [1:0] o_MemReg;
    output [4:0] o_rd;
    output [31:0] o_pc_add4, o_result, o_read_data;
    //==== wire/reg definition ================================
    reg o_RegWrite_r;
    reg [1:0] o_MemReg_r;
    reg [4:0] o_rd_r;
    reg [31:0] o_pc_add4_r, o_result_r, o_read_data_r;
    //==== combinational circuit ==============================
    assign o_RegWrite = o_RegWrite_r; 
    assign o_MemReg = o_MemReg_r;
    assign o_pc_add4 = o_pc_add4_r;
    assign o_result = o_result_r;
    assign o_rd = o_rd_r;
    assign o_read_data = o_read_data_r;
    //==== sequential circuit =================================
    always@ (posedge clk) begin
        if(!rst_n) begin
            o_RegWrite_r <= 1'b0; 
            o_MemReg_r <= 2'b0;
            o_pc_add4_r  <= 32'b0;
            o_result_r <= 32'b0;
            o_rd_r <= 5'b0;
            o_read_data_r <= 32'b0;
        end
        else if (D_stall) begin
            o_RegWrite_r <= o_RegWrite; 
            o_MemReg_r <= o_MemReg;
            o_pc_add4_r <= o_pc_add4;
            o_result_r <= o_result;
            o_rd_r <= o_rd;
            o_read_data_r <= o_read_data;
        end
        else begin
            o_RegWrite_r <= i_RegWrite; 
            o_MemReg_r <= i_MemReg;
            o_pc_add4_r <= i_pc_add4;
            o_result_r <= result;
            o_rd_r <= i_rd;
            o_read_data_r <= {i_read_data[7:0], i_read_data[15:8], i_read_data[23:16], i_read_data[31:24]};
        end
    end
endmodule

module stage_WB( 
    pc_add4,
    rdata,
    result,
    MemReg,
    write_data
);
    //==== input/output =======================================
    input [1:0] MemReg; 
    input [31:0] pc_add4, rdata, result;
    output [31:0] write_data;
    //==== combinational circuit ==============================
    assign write_data = (MemReg[1])? pc_add4 : 
                        (MemReg[0])? rdata : result;
endmodule
module CHIP (	clk,
				rst_n,
//----------for slow_memD------------
				mem_read_D,
				mem_write_D,
				mem_addr_D,
				mem_wdata_D,
				mem_rdata_D,
				mem_ready_D,
//----------for slow_memI------------
				mem_read_I,
				mem_write_I,
				mem_addr_I,
				mem_wdata_I,
				mem_rdata_I,
				mem_ready_I,
//----------for TestBed--------------				
				DCACHE_addr, 
				DCACHE_wdata,
				DCACHE_wen   
			);
input			clk, rst_n;
//--------------------------

output			mem_read_D;
output			mem_write_D;
output	[31:4]	mem_addr_D;
output	[127:0]	mem_wdata_D;
input	[127:0]	mem_rdata_D;
input			mem_ready_D;
//--------------------------
output			mem_read_I;
output			mem_write_I;
output	[31:4]	mem_addr_I;
output	[127:0]	mem_wdata_I;
input	[127:0]	mem_rdata_I;
input			mem_ready_I;
//----------for TestBed--------------
output	[29:0]	DCACHE_addr;
output	[31:0]	DCACHE_wdata;
output			DCACHE_wen;
//--------------------------

// wire declaration
wire        ICACHE_ren;
wire        ICACHE_wen;
wire [29:0] ICACHE_addr;
wire [31:0] ICACHE_wdata;
wire        ICACHE_stall;
wire [31:0] ICACHE_rdata;

wire        DCACHE_ren;
wire        DCACHE_wen;
wire [29:0] DCACHE_addr;
wire [31:0] DCACHE_wdata;
wire        DCACHE_stall;
wire [31:0] DCACHE_rdata;


//=========================================
	// Note that the overall design of your RISCV includes:
	// 1. pipelined RISCV processor
	// 2. data cache
	// 3. instruction cache


	RISCV_Pipeline i_RISCV(
		// control interface
		.clk            (clk)           , 
		.rst_n          (rst_n)         ,
//----------I cache interface-------		
		.ICACHE_ren     (ICACHE_ren)    ,
		.ICACHE_wen     (ICACHE_wen)    ,
		.ICACHE_addr    (ICACHE_addr)   ,
		.ICACHE_wdata   (ICACHE_wdata)  ,
		.ICACHE_stall   (ICACHE_stall)  ,
		.ICACHE_rdata   (ICACHE_rdata)  ,
//----------D cache interface-------
		.DCACHE_ren     (DCACHE_ren)    ,
		.DCACHE_wen     (DCACHE_wen)    ,
		.DCACHE_addr    (DCACHE_addr)   ,
		.DCACHE_wdata   (DCACHE_wdata)  ,
		.DCACHE_stall   (DCACHE_stall)  ,
		.DCACHE_rdata   (DCACHE_rdata)
	);
	

	cache D_cache(
        .clk        (clk)         ,
        .proc_reset (~rst_n)      ,
        .proc_read  (DCACHE_ren)  ,
        .proc_write (DCACHE_wen)  ,
        .proc_addr  (DCACHE_addr) ,
        .proc_rdata (DCACHE_rdata),
        .proc_wdata (DCACHE_wdata),
        .proc_stall (DCACHE_stall),
        .mem_read   (mem_read_D)  ,
        .mem_write  (mem_write_D) ,
        .mem_addr   (mem_addr_D)  ,
        .mem_wdata  (mem_wdata_D) ,
        .mem_rdata  (mem_rdata_D) ,
        .mem_ready  (mem_ready_D)
	);

	cache I_cache(
        .clk        (clk)         ,
        .proc_reset (~rst_n)      ,
        .proc_read  (ICACHE_ren)  ,
        .proc_write (ICACHE_wen)  ,
        .proc_addr  (ICACHE_addr) ,
        .proc_rdata (ICACHE_rdata),
        .proc_wdata (ICACHE_wdata),
        .proc_stall (ICACHE_stall),
        .mem_read   (mem_read_I)  ,
        .mem_write  (mem_write_I) ,
        .mem_addr   (mem_addr_I)  ,
        .mem_wdata  (mem_wdata_I) ,
        .mem_rdata  (mem_rdata_I) ,
        .mem_ready  (mem_ready_I)
	);
endmodule
 
module cache(
    clk,
    proc_reset,
    proc_read,
    proc_write,
    proc_addr,
    proc_rdata,
    proc_wdata,
    proc_stall,
    mem_read,
    mem_write,
    mem_addr,
    mem_rdata,
    mem_wdata,
    mem_ready
);
    
//==== input/output definition ============================
    input          clk;
    // processor interface
    input          proc_reset;
    input          proc_read, proc_write;
    input   [29:0] proc_addr;
    input   [31:0] proc_wdata;
    output         proc_stall;
    output  [31:0] proc_rdata;
    // memory interface
    input  [127:0] mem_rdata;
    input          mem_ready;
    output         mem_read, mem_write;
    output  [27:0] mem_addr;
    output [127:0] mem_wdata;
    
//==== state/parameter/integer ============================
    reg [1:0] state_r, state_w;
    parameter S_IDLE = 2'b00;
    parameter S_READ = 2'b01;
    parameter S_WRITE = 2'b10;
    parameter S_WRITE_AND_READ = 2'b11;  // write mem then read mem

    integer i;
//==== wire/reg definition ================================
    reg [155:0] cache [0:3][0:1]; // cache[i]  155 : valid   154 : dirty   153-128 : tag   127-0 : data
    reg [155:0] cache_next [0:3][0:1];
    reg prev_index_not_used [0:3];    // for least recently used
    reg prev_index_not_used_next [0:3];
    reg [1:0] offset;     // 4 to 1              2bits
    reg [1:0] index;      // 8 blocks            2bits
    reg [25:0] tag, tag_0, tag_1;       // remain of address   26bits
    reg [155:0] block;
    reg proc_stall_r, proc_stall_w, mem_read_r, mem_read_w, mem_write_r, mem_write_w, dirty_write_r, dirty_write_w;
    reg [31:0] proc_rdata_r, proc_rdata_w, block_word, read_new_word;
    reg [127:0] mem_wdata_r, mem_wdata_w, write_new_data, new_write_data;
    reg [27:0]  mem_addr_r, mem_addr_w;
    reg hit, hit_0, hit_1, which_cache;
//==== combinational circuit ==============================
    assign proc_rdata = proc_rdata_w;
    assign proc_stall = proc_stall_w;
    assign mem_read = mem_read_w;
    assign mem_write = mem_write_w;
    assign mem_addr = mem_addr_w;
    assign mem_wdata = mem_wdata_w;

    always@(*) begin 
        for (i = 0; i < 4; i = i + 1) begin
            cache_next[i][0] = cache[i][0];
            cache_next[i][1] = cache[i][1];
            prev_index_not_used_next[i] = prev_index_not_used[i];
        end
        proc_stall_w = proc_stall_r;
        proc_rdata_w = proc_rdata_r;
        state_w = state_r;
        mem_read_w = mem_read_r;
        mem_write_w = mem_write_r;
        mem_addr_w = mem_addr_r;
        mem_wdata_w = mem_wdata_r;
        dirty_write_w = dirty_write_r;
        
        offset = proc_addr[1:0];
        index = proc_addr[4:3];
        tag = {proc_addr[29:5], proc_addr[2]};
        tag_0 = cache[index][0][153:128];
        tag_1 = cache[index][1][153:128];
        hit_0 = tag == tag_0; // consider as now not hit cache
        hit_1 = tag == tag_1; // consider as now hit cache
        hit = hit_0 | hit_1;
        which_cache = hit? hit_1 : prev_index_not_used[index];
        block = cache[index][which_cache];
        case (offset)
            2'b00: block_word = block[31:0];
            2'b01: block_word = block[63:32];
            2'b10: block_word = block[95:64];
            default: block_word = block[127:96]; // 2'b11
        endcase
        case (offset)
            2'b00: write_new_data = {block[127:32], proc_wdata};
            2'b01: write_new_data = {block[127:64], proc_wdata, block[31:0]};
            2'b10: write_new_data = {block[127:96], proc_wdata, block[63:0]};
            default: write_new_data = {proc_wdata, block[95:0]}; // 2'b11
        endcase
        case (offset)
            2'b00: read_new_word = mem_rdata[31:0];
            2'b01: read_new_word = mem_rdata[63:32];
            2'b10: read_new_word = mem_rdata[95:64];
            default: read_new_word = mem_rdata[127:96]; // 2'b11
        endcase
        case (offset)
            2'b00: new_write_data = {mem_rdata[127:32], proc_wdata};
            2'b01: new_write_data = {mem_rdata[127:64], proc_wdata, mem_rdata[31:0]};
            2'b10: new_write_data = {mem_rdata[127:96], proc_wdata, mem_rdata[63:0]};
            default: new_write_data = {proc_wdata, mem_rdata[95:0]}; // 2'b11
        endcase

        case (state_r)
            S_IDLE: begin 
                if (proc_read) begin
                    proc_stall_w = 1'b1;
                    if (block[155] && hit) begin  // valid & hit
                        proc_rdata_w = block_word;
                        proc_stall_w = 1'b0;
                        prev_index_not_used_next[index] = hit_0;
                    end else if (block[155] && block[154]) begin  // valid & miss & dirty
                        mem_read_w = 1'b0;
                        mem_write_w = 1'b1;
                        mem_addr_w = {block[153:129], index, block[128]};
                        mem_wdata_w = block[127:0];
                        dirty_write_w = 1'b0;
                        state_w = S_WRITE_AND_READ;
                    end else begin  // remain read
                        mem_read_w = 1'b1;
                        mem_write_w = 1'b0;
                        mem_addr_w = proc_addr[29:2];
                        state_w = S_READ;
                    end
                end else if (proc_write) begin
                    proc_stall_w = 1'b1;
                    if (block[155] && hit) begin  // valid & hit
                        cache_next[index][hit_1] = {2'b11, tag, write_new_data};
                        proc_stall_w = 1'b0;
                        prev_index_not_used_next[index] = hit_0;
                    end else if (block[155] && block[154]) begin  // valid & miss & dirty
                        mem_read_w = 1'b0;
                        mem_write_w = 1'b1;
                        mem_addr_w = {block[153:129], index, block[128]};
                        mem_wdata_w = block[127:0];
                        dirty_write_w = 1'b1;
                        state_w = S_WRITE_AND_READ;
                    end else begin  // remain write
                        mem_read_w = 1'b1;
                        mem_write_w = 1'b0;
                        mem_addr_w = proc_addr[29:2];
                        state_w = S_WRITE;
                    end
                end
            end
            S_READ: begin
                if (mem_ready) begin
                    mem_read_w = 1'b0;
                    proc_rdata_w = read_new_word;
                    cache_next[index][which_cache] = {2'b10, tag, mem_rdata};
                    proc_stall_w = 1'b0;
                    state_w = S_IDLE;
                    prev_index_not_used_next[index] = ~which_cache;
                end
            end
            S_WRITE_AND_READ: begin   // write mem then read mem
                if (mem_ready) begin
                    if (dirty_write_r) begin
                        mem_read_w = 1'b1;
                        mem_write_w = 1'b0;
                        mem_addr_w = proc_addr[29:2];
                        state_w = S_WRITE;
                        dirty_write_w = 1'b0;
                    end else begin
                        mem_read_w = 1'b1;
                        mem_write_w = 1'b0;
                        mem_addr_w = proc_addr[29:2];
                        state_w = S_READ;
                    end
                end
            end
            S_WRITE: begin
                if (mem_ready) begin
                    mem_read_w = 1'b0;
                    proc_rdata_w = read_new_word;
                    cache_next[index][which_cache] = {2'b11, tag, new_write_data};
                    proc_stall_w = 1'b0;
                    state_w = S_IDLE;
                    prev_index_not_used_next[index] = ~which_cache;
                end
            end
            default: begin
                state_w = S_IDLE;
                proc_stall_w = 1'b0;
            end
        endcase
    end
//==== sequential circuit =================================
    always@ (posedge clk) begin
        if(proc_reset) begin
            for (i = 0; i < 4; i = i + 1) begin
                cache[i][0] <= 156'b0;
                cache[i][1] <= 156'b0;
                prev_index_not_used[i] <= 1'b0;
            end
            proc_stall_r <= 1'b0;
            proc_rdata_r <= 32'b0;
            state_r <= S_IDLE;
            mem_read_r <= 1'b0;
            mem_write_r <= 1'b0;
            mem_addr_r <= 28'b0;
            mem_wdata_r <= 128'b0;
            dirty_write_r <= 1'b0;
        end
        else begin
            for (i = 0; i < 4; i = i + 1) begin
                cache[i][0] <= cache_next[i][0];
                cache[i][1] <= cache_next[i][1];
                prev_index_not_used[i] <= prev_index_not_used_next[i];
            end
            proc_stall_r <= proc_stall_w;
            proc_rdata_r <= proc_rdata_w;
            state_r <= state_w;
            mem_read_r <= mem_read_w;
            mem_write_r <= mem_write_w;
            mem_addr_r <= mem_addr_w;
            mem_wdata_r <= mem_wdata_w;
            dirty_write_r <= dirty_write_w;
        end
    end
endmodule

// 0000000_01100_01000_000_10000_0110011 //0x24// add  x16 x8  r12
// 0100000_01100_01000_000_10001_0110011 //0x28// sub  x17 x8  r12
// 0000000_01100_01000_111_10010_0110011 //0x2C// and  x18 x8  r12
// 0000000_01100_01000_110_10011_0110011 //0x30// or   x19 x8  r12
// 0000000_01100_01000_100_10100_0110011 //0x34// xor  x20 x8  r12
// 0000000_01100_01000_010_11000_0110011 //0x44// slt  x24 x8  r12

// 0000001_11001_00000_010_10100_0100011 //0xB0// sw   x25 x0  0x034

// 000000000000_00000_010_11001_0000011  //0x4C// lw   x25 x0  0x000

// 0_000000_00000_01111_000_0110_0_1100011 //0x80// beq  x15 x0  0x006 (to 0x8C) // to SwapExit
// 1_111111_01011_01100_001_0010_1_1100011 //0x5C// bne  x12 x11 0xFF2 (to 0x40) // to FibonacciLoop

// 0_0001011010_0_00000000_00000_1101111   //0x04// jal  x0  0x0005A (to 0xB8) 

// 000000000000_00001_000_00000_1100111    //0x0C// jalr x0  x1  0x000           // return OutputTestPort

// 000000000000_00000_000_01001_0010011    //0x14// addi x9  x0  0x000
// 000000000110_01001_111_01101_0010011  //0x18// andi x13 x9  0x006
// 000000000110_01010_110_01110_0010011  //0x1C// ori  x14 x10 0x006
// 111111111111_01000_100_01100_0010011  //0x14// xori x12 x8  0xFFF
// 000000001000_01011_010_01111_0010011  //0x20// slti x15 x11 0x008    (rs < constant)? 
// 0000000_00001_01100_001_10101_0010011 //0x38// slli x21 x12  1       left shift
// 0000000_11111_01100_101_10110_0010011 //0x3C// srli x22 x12 31       right shift (MSB put 0)
// 0100000_11111_01100_101_10111_0010011 //0x40// srai x23 x12 31       arithmetic right shift (MSB put previous MSB)
// 000000000000_00000_000_00000_0010011  //0x00// nop   (== addi x0 x0 0x000)