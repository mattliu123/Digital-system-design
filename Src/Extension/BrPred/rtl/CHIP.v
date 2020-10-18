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
	DCACHE_rdata,
    correction //delete later
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
    output [1:0] correction;//delete
    
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
    wire jump;
    wire [1:0] correct;
    wire mispredict;
    wire [1:0] branch;
    // WB
    wire WB_reg_write;
    wire [1:0] WB_MemReg;
    wire [31:0] WB_write_data, WB_pc_add4, WB_read_data, WB_result;
    wire [4:0] WB_write_addr;
    wire predict_result;
    wire [31:0] correct_prediction;
    //==== combinational circuit ==============================
    stage_IF stage0(.correct_prediction(correct_prediction),.clk(clk),.rst_n(rst_n),.mispredict(mispredict),.jump(jump),.i_cache(ICACHE_rdata),.pc_add4(IF_pc_add4), .pc_add_imm(pc_add_imm),
     .rs_add_imm(rs_add_imm), .jalr(jalr), .branch_or_jal(branch_or_jal), .pc_next(pc_next));
    pipeline_pc pipeline0(.clk(clk), .rst_n(rst_n), .stall(stall), .hazard_stall(hazard_stall), .pc_next(pc_next), .pc(IF_pc), .pc_add4(IF_pc_add4));
    assign ICACHE_ren = 1'b1;
    assign ICACHE_wen = 1'b0;
    assign ICACHE_addr = IF_pc[31:2];
    assign ICACHE_wdata = 32'b0;
    assign stall = (ICACHE_stall | DCACHE_stall);
    assign correction=correct;//delete
    prediction pre(.branch(branch),.clk(clk),.rst_n(rst_n),.jump(jump),.correct(correct));
    pipeline_IF_ID pipeline1(.clk(clk), .rst_n(rst_n), .stall(stall), .hazard_stall(hazard_stall), .flush(flush), .I_instr(ICACHE_rdata),
                             .instr(instr), .pc(IF_pc), .pc_out(ID_pc), .pc_add4(IF_pc_add4), .pc_add4_out(ID_pc_add4),.jump(jump),.predict_result(predict_result));    
    stage_ID stage1(.branch(branch),.correct_prediction(correct_prediction),.mispredict(mispredict),.correct(correct),.predict_result(predict_result),.clk(clk), .rst_n(rst_n), .pc(ID_pc), .instr(instr), .EX_MemRead(EX_MemRead), .EX_write_addr(EX_write_addr), .WB_reg_write(WB_reg_write), .bubble(bubble), .WB_write_data(WB_write_data), 
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
    clk,
    rst_n,
    pc_add4,
    pc_add_imm,
    rs_add_imm,
    jalr,
    branch_or_jal,
    pc_next,
    i_cache,
    jump,
    mispredict,
    correct_prediction
);  
    //==== input/output =======================================
    input [31:0] i_cache;
    input jump,clk,rst_n;
    input jalr, branch_or_jal;
    input [31:0] pc_add4, pc_add_imm, rs_add_imm,correct_prediction;
    output [31:0] pc_next;
    input mispredict;
    //==== wire/reg definition ================================
    wire [31:0]  inst;
    reg [31:0] pc0;
    reg [31:0] pc_prediction;
    wire [31:0] imm, pc_prdiction_imm;
    //==== combinational circuit ==============================
    assign inst={i_cache[7:0], i_cache[15:8], i_cache[23:16], i_cache[31:24]};
    assign pc_next = (jalr)? rs_add_imm : pc0;
    assign imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
    assign pc_prdiction_imm=pc_add4+imm-4;
    reg pre_jump;
    always@(*) begin
        
        pc0=pc_prediction;
        if(branch_or_jal) begin 
            pc0=pc_add_imm;
        end
        else if　(mispredict) begin
            pc0=correct_prediction;
        end
        else begin
            pc0=pc_prediction;
        end
    end
    always@(*) begin
        if(inst[6:0]==7'b1100011) begin
            if(jump) begin
                pc_prediction=pc_prdiction_imm;
            end
            else begin
                pc_prediction=pc_add4;
            end
        end
        else begin
            pc_prediction=pc_add4;
        end
    end
    always@(posedge clk) begin
        if(!rst_n) begin
            pre_jump<=0;
        end
        else begin
            pre_jump<=jump;
        end
    end

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
    wire [31:0] inst;
    //==== combinational circuit ==============================
    assign pc = pc_r; //our pc
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
    pc_add4_out,
    jump,
    predict_result
);
    //==== input/output =======================================
    input clk, rst_n, stall, hazard_stall, flush,jump;
    input [31:0] I_instr, pc, pc_add4;
    output [31:0] instr, pc_out, pc_add4_out;
    output predict_result;
    //==== wire/reg definition ================================
    reg [31:0] instr_r, pc_r, pc_add4_r;
    reg predict_result_r;
    //==== combinational circuit ==============================
    assign instr = instr_r;
    assign pc_out = pc_r;
    assign pc_add4_out = pc_add4_r;
    assign predict_result=predict_result_r;
    //==== sequential circuit =================================
    always@ (posedge clk) begin
        if(!rst_n) begin
            instr_r <= 32'b0;
            pc_r <= 32'b0;
            pc_add4_r <= 32'b0;
        end
        else if (stall || hazard_stall) begin
            instr_r <= instr;
            pc_r <= pc_out;
            pc_add4_r <= pc_add4_out;
        end 
        else if (flush) begin
            instr_r <= 32'b0;
            pc_r <= 32'b0;
            pc_add4_r <= 32'b0;
        end
        else begin
            instr_r <= {I_instr[7:0], I_instr[15:8], I_instr[23:16], I_instr[31:24]};
            pc_r <= pc;
            pc_add4_r <= pc_add4;
        end
    end
    always@(posedge clk ) begin
        if(!rst_n) begin
            predict_result_r<=0;
        end
        else if(stall) begin
            predict_result_r<=predict_result;
        end
        else begin
            predict_result_r<=jump;
        end
    end
endmodule
/*
module prediction (clk, rst_n,jump, correct);
input [1:0] correct; // usual 2, correct 1, incorrect 0
input clk, rst_n;
output reg jump; // jump=0 pc+4, jump=1, branch
reg [1:0] state_w,state_r;
parameter PC4_DEEP =0 ;
parameter PC4_SHALLOW=1;
parameter JUMP_SHALLOW=2;
parameter JUMP_DEEP=3;
always@(*) begin
    state_w=PC4_DEEP;
    jump=0;
    case (state_r)
        PC4_DEEP: begin
            jump=0;
            if(correct==0) begin
                state_w=PC4_SHALLOW;
            end
            else begin
                state_w=PC4_DEEP;
            end
        end
        PC4_SHALLOW: begin
            jump=0;
            case (correct)
                2'd0: state_w=JUMP_SHALLOW;
                2'd1: state_w=PC4_DEEP; 
                default: state_w=PC4_SHALLOW;
            endcase
        end
        JUMP_SHALLOW: begin
            jump=1;
            case (correct)
                2'd0: state_w=PC4_SHALLOW;
                2'd1: state_w=JUMP_DEEP; 
                default: state_w=JUMP_SHALLOW;
            endcase
            
        end
        JUMP_DEEP: begin
            jump=1;
            if(correct==0) begin
                state_w=JUMP_SHALLOW;
            end
            else begin
                state_w=JUMP_DEEP;
            end
        end
        default: state_w=PC4_DEEP;
    endcase
end
always@(posedge clk) begin
    if(!rst_n) begin
        state_r<=0;
    end
    else begin
        state_r<=state_w;
    end
end


endmodule
*/
module prediction (clk, rst_n,jump, correct,branch); //always not taken
input [1:0] correct,branch; // usual 2, correct 1, incorrect 0
input clk, rst_n;
output reg jump; // jump=0 pc+4, jump=1, branch
reg [1:0] state0_w,state0_r, state1_w,state1_r,state2_w,state2_r,state3_w,state3_r;
reg last2_w,last2_r,last1_w,last1_r;
reg [2:0] record_r,record_w;
always@(*) begin
   // record_w={last3_r,last2_r,last1_r};
    record_w={last2_r,last1_r};
end
parameter STRONGLY_NT=0;
parameter WEAKLY_NT =1 ;
parameter WEAKLY_T = 2;
parameter STRONGLY_T = 3 ;
always@(*) begin
    state0_w=state0_r;
    state1_w=state1_r;
    state2_w=state2_r;
    state3_w=state3_r;
    /*
    state4_w=state4_r;
    state5_w=state5_r;
    state6_w=state6_r;
    state7_w=state7_r;
    */
    jump=1;
    case (record_r)
        2'b00: begin
            case (state0_r)
                STRONGLY_NT: begin
                    jump=0;
                    if(correct==0) begin
                        state0_w=WEAKLY_NT;
                    end
                    else state0_w=STRONGLY_NT;
                end 
                WEAKLY_NT: begin
                    jump=0;
                    case (correct)
                        2'd0: state0_w=WEAKLY_T;
                        2'd1: state0_w=STRONGLY_NT; 
                        default: state0_w=WEAKLY_NT;
                    endcase
                end
                WEAKLY_T: begin
                    jump=1;
                    case (correct)
                        2'd0: state0_w=WEAKLY_NT;
                        2'd1: state0_w=STRONGLY_T; 
                        default: state0_w=WEAKLY_T;
                    endcase
                end
                STRONGLY_T:begin
                    jump=1;
                    if(correct==0) begin
                        state0_w=WEAKLY_T;
                    end
                    else state0_w=STRONGLY_T;
                end
                default: begin
                    state0_w=state0_r;
                    jump=1;
                end
            endcase
        end 
        2'b01: begin
             case (state1_r)
                STRONGLY_NT: begin
                    jump=0;
                    if(correct==0) begin
                        state1_w=WEAKLY_NT;
                    end
                    else state1_w=STRONGLY_NT;
                end 
                WEAKLY_NT: begin
                    jump=0;
                    case (correct)
                        2'd0: state1_w=WEAKLY_T;
                        2'd1: state1_w=STRONGLY_NT; 
                        default: state1_w=WEAKLY_NT;
                    endcase
                end
                WEAKLY_T: begin
                    jump=1;
                    case (correct)
                        2'd0: state1_w=WEAKLY_NT;
                        2'd1: state1_w=STRONGLY_T; 
                        default: state1_w=WEAKLY_T;
                    endcase
                end
                STRONGLY_T:begin
                    jump=1;
                    if(correct==0) begin
                        state1_w=WEAKLY_T;
                    end
                    else state1_w=STRONGLY_T;
                end
                default: begin
                    state1_w=state1_r;
                    jump=1;
                end
            endcase
        end 
        2'b10: begin
             case (state2_r)
                STRONGLY_NT: begin
                    jump=0;
                    if(correct==0) begin
                        state2_w=WEAKLY_NT;
                    end
                    else state2_w=STRONGLY_NT;
                end 
                WEAKLY_NT: begin
                    jump=0;
                    case (correct)
                        2'd0: state2_w=WEAKLY_T;
                        2'd1: state2_w=STRONGLY_NT; 
                        default: state2_w=WEAKLY_NT;
                    endcase
                end
                WEAKLY_T: begin
                    jump=1;
                    case (correct)
                        2'd0: state2_w=WEAKLY_NT;
                        2'd1: state2_w=STRONGLY_T; 
                        default: state2_w=WEAKLY_T;
                    endcase
                end
                STRONGLY_T:begin
                    jump=1;
                    if(correct==0) begin
                        state2_w=WEAKLY_T;
                    end
                    else state2_w=STRONGLY_T;
                end
                default: begin
                    state2_w=state2_r;
                    jump=1;
                end
            endcase
        end 
        2'b11: begin
             case (state3_r)
                STRONGLY_NT: begin
                    jump=0;
                    if(correct==0) begin
                        state3_w=WEAKLY_NT;
                    end
                    else state3_w=STRONGLY_NT;
                end 
                WEAKLY_NT: begin
                    jump=0;
                    case (correct)
                        2'd0: state3_w=WEAKLY_T;
                        2'd1: state3_w=STRONGLY_NT; 
                        default: state3_w=WEAKLY_NT;
                    endcase
                end
                WEAKLY_T: begin
                    jump=1;
                    case (correct)
                        2'd0: state3_w=WEAKLY_NT;
                        2'd1: state3_w=STRONGLY_T; 
                        default: state3_w=WEAKLY_T;
                    endcase
                end
                STRONGLY_T:begin
                    jump=1;
                    if(correct==0) begin
                        state3_w=WEAKLY_T;
                    end
                    else state3_w=STRONGLY_T;
                end
                default: begin
                    state3_w=state3_r;
                    jump=1;
                end
            endcase
        end 

        
        default: begin
            jump=1;
        end 
    endcase
end
always@(*) begin
    last1_w=last1_r;
    last2_w=last2_r;
    //last3_w=last3_r;
    if(!branch[1]) begin
        last1_w=branch[0];
        last2_w=last1_r;
        //last3_w=last2_r;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        last1_r<=0;
        last2_r<=0;
    //    last3_r<=0;
        state0_r<=0;
        state1_r<=3;
        state2_r<=0;
        state3_r<=0;
       // state4_r<=3;
       // state5_r<=0;
      //  state6_r<=3;
      //  state7_r<=3;
        record_r<=2'b00;
    end
    else begin
        last1_r<=last1_w;
        last2_r<=last2_w;
        state0_r<=state0_w;
        state1_r<=state1_w;
        state2_r<=state2_w;
        state3_r<=state3_w;
     //   state4_r<=state4_w;
      //  state5_r<=state5_w;
     //   state6_r<=state6_w;
     //   state7_r<=state7_w;
        record_r<=record_w;
    end
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
    predict_result,
    correct,
    mispredict,
    correct_prediction,
    branch
);
    //==== input/output =======================================
    input clk, rst_n, EX_MemRead, WB_reg_write, EX_RegWrite, MEM_RegWrite,predict_result;
    input [31:0] instr, WB_write_data, pc, EX_result, MEM_result;
    input [4:0] WB_write_addr, EX_write_addr, MEM_rd;
    // EX_result(), .EX_RegWrite(), EX_write_addr                 .MEM_result(), .MEM_RegWrite()    MEM_rd    WB_write_data   WB_reg_write     WB_write_addr
    output flush, branch_or_jal;
    output [31:0] pc_add_imm, rs_add_imm, read_data1, read_data_2, read_data2;
    output reg [31:0] imm;
    output reg [3:0] ALU_Control;
    output reg jalr, hazard_stall, MemWrite, MemRead, bubble, RegWrite_o, ALUSrc;
    output reg [1:0] MemReg;
    output [1:0] correct;
    output mispredict;
    output [31:0] correct_prediction;
    output reg [1:0] branch;
    //==== wire/reg definition ================================
    // control unit
    reg beq, bne, jal, RegWrite;
    reg [31:0] correct_prediction;
    // forward unit
    reg [31:0] data1, data2;
    // equal
    wire zero;
    //wire mispredict;

    
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
    always@(*) begin
        if((beq&&zero)||(bne&&(!zero))) begin
            branch=1;
        end
        else if ((beq&&(!zero))||(bne&&zero)) begin
            branch=0;
        end
        else begin
            branch=2;
        end
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
    assign mispredict=((bne||beq)&&((beq&&zero&&(!predict_result))||(bne&&(!zero)&&(!predict_result))||(beq&&(!zero)&&predict_result)
    ||(bne&&(zero)&&predict_result)));
    assign branch_or_jal = jal;
            
    assign flush = branch_or_jal | jalr|mispredict;
    assign correct=(beq|bne)?((mispredict)?0:1) : 2;
    
    always@(*) begin
        if((beq&&zero)||(bne&&(!zero))) begin
            correct_prediction=pc_add_imm;
        end
        else begin
            correct_prediction=pc+4;
        end

    end
    
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
// Top module of your design, you cannot modify this module!!
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
				DCACHE_wen,
                correction //delete   
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
output [1:0] correction; //delete
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
wire [1:0] correct;
assign correction=correct;


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
		.DCACHE_rdata   (DCACHE_rdata),
        .correction(correct)
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
    
//==== wire/reg definition ================================
    integer i;
    parameter IDLE = 3'd0;
    parameter READ = 3'd1;
    parameter WRITE = 3'd2;
    parameter WRITEBACK_R = 3'd3;
    parameter WRITEBACK_W = 3'd4;
    reg [311:0] cache1[0:3];       //[311]:valid1   [310]:dirty1    [309:284]:tag1    [283:156]:data1   [155]:valid2     [154]:dirty2    [153:128]:tag2    [127:0]:data2
    reg [311:0] n_cache1[0:3];
    reg [2:0] state, n_state;
    reg previous_used [0:3];
    reg n_previous_used [0:3];
    wire valid1, valid2, match1, match2, hit, writeread, which_cache;
    wire [155:0] block;
    wire [25:0] tag1, tag2;
    wire [1:0] block_num;
    wire [1:0] data_num;
    reg proc_stall, mem_read, mem_write;
    reg [31:0] blockword, newreadword, proc_rdata;
    reg [127:0] newdata_write, newdata_write_mem;
    reg [27:0] mem_addr;
//==== combinational circuit ==============================
    assign block_num = proc_addr[3:2];
    assign data_num = proc_addr[1:0];
    assign tag1 = cache1[block_num][309:284];
    assign tag2 = cache1[block_num][153:128];
    assign valid1 = cache1[block_num][311];
    assign valid2 = cache1[block_num][155];
    assign match1 = (tag1==proc_addr[29:4])?1'b1:1'b0;
    assign match2 = (tag2==proc_addr[29:4])?1'b1:1'b0;
    assign hit = ((valid1&&match1)||(valid2&&match2))?1'b1:1'b0;
    assign which_cache = (hit)?(valid2&match2):previous_used[block_num];
    assign block = (which_cache)?cache1[block_num][155:0]:cache1[block_num][311:156];
    assign writeread = ((!hit)&&block[154]&&block[155])?1'b1:1'b0;
    //assign mem_addr = proc_addr[29:2];
    assign mem_wdata = block[127:0];
    always@(*)begin
        proc_stall = 0;
        mem_write = 0;
        mem_read = 0;
        case (state)
            IDLE:begin
                if(proc_read)begin
                    if(hit)begin
                        n_state = IDLE;
                    end
                    else if(writeread)begin
                        n_state = WRITEBACK_R;
                        proc_stall = 1'b1;
                    end
                    else begin
                        n_state = READ;
                        proc_stall = 1'b1;
                    end
                end
                else if(proc_write)begin
                    if(hit)begin
                        n_state = IDLE;
                    end
                    else if(writeread)begin
                        n_state = WRITEBACK_W;
                        proc_stall = 1'b1;
                    end
                    else begin
                        n_state = WRITE;
                        proc_stall = 1'b1;
                    end
                end
                else begin
                    n_state = IDLE;
                end
            end

            READ:begin
                if(mem_ready)begin
                    proc_stall = 1'b0;
                    mem_read = 1'b0;
                    n_state = IDLE;
                end
                else begin
                    proc_stall = 1'b1;
                    mem_read = 1'b1;
                    n_state = READ;
                end
            end

            WRITE:begin
                if(mem_ready)begin
                    proc_stall = 1'b0;
                    mem_write = 1'b0;
                    n_state = IDLE;
                end
                else begin
                    proc_stall = 1'b1;
                    mem_read = 1'b1;
                    n_state = WRITE;
                end
            end

            WRITEBACK_R:begin
                if(mem_ready)begin
                    proc_stall = 1'b1;
                    mem_write = 0;
                    n_state = READ;
                end
                else begin
                    proc_stall = 1'b1;
                    mem_write = 1'b1;
                    n_state = WRITEBACK_R;
                end
            end

            WRITEBACK_W:begin
                if(mem_ready)begin
                    proc_stall = 1'b1;
                    mem_write = 1'b0;
                    n_state = WRITE;
                end
                else begin
                    proc_stall = 1'b1;
                    mem_write = 1'b1;
                    n_state = WRITEBACK_W;
                end
            end
            default : n_state = IDLE;
        endcase
    end
    always@(*)begin
        for(i=0; i<4; i=i+1)begin
            n_cache1[i] = cache1[i];
            n_previous_used[i] = previous_used[i];
        end
        proc_rdata = 32'd0;
        mem_addr = proc_addr[29:2];
        case (state)
            IDLE:begin
                if(proc_read&&hit)begin
                    proc_rdata = blockword;
                end
                else if(proc_write&&hit)begin
                    n_cache1[block_num] = (which_cache)?{cache1[block_num][311:156],2'b11,proc_addr[29:4], newdata_write}:{2'b11,proc_addr[29:4], newdata_write,cache1[block_num][155:0]};
                end
            end
            READ:begin
                proc_rdata = newreadword;
                n_cache1[block_num] = (which_cache)?{cache1[block_num][311:156],2'b10,proc_addr[29:4], mem_rdata}:{2'b10,proc_addr[29:4], mem_rdata,cache1[block_num][155:0]};
                n_previous_used[block_num] = ~which_cache;
            end
            WRITE:begin
                n_cache1[block_num] = (which_cache)?{cache1[block_num][311:156],2'b11,proc_addr[29:4], newdata_write_mem}:{2'b11,proc_addr[29:4], newdata_write_mem,cache1[block_num][155:0]};
                n_previous_used[block_num] = ~which_cache;
            end
            WRITEBACK_R:begin
            	mem_addr = {block[153:128],block_num};
            end
            WRITEBACK_W:begin
            	mem_addr = {block[153:128],block_num};
            end

            default : /* default */;
        endcase
    end

    always@(*)begin
        case (data_num)
            2'b00:begin
                blockword = block[31:0];
                newreadword = mem_rdata[31:0];
                newdata_write = {block[127:32], proc_wdata};
                newdata_write_mem = {mem_rdata[127:32], proc_wdata};
            end
            2'b01:begin
                blockword = block[63:32];
                newreadword = mem_rdata[63:32];
                newdata_write = {block[127:64],proc_wdata,block[31:0]};
                newdata_write_mem = {mem_rdata[127:64],proc_wdata,block[31:0]};
            end
            2'b10:begin
                blockword = block[95:64];
                newreadword = mem_rdata[95:64];
                newdata_write = {block[127:96],proc_wdata,block[63:0]};
                newdata_write_mem = {mem_rdata[127:96],proc_wdata,block[63:0]};
            end
            default:begin
                blockword = block[127:96];
                newreadword = mem_rdata[127:96];
                newdata_write = {proc_wdata,block[95:0]};
                newdata_write_mem = {proc_wdata,mem_rdata[95:0]};
            end
        endcase
    end
//==== sequential circuit =================================
always@( posedge clk ) begin
    if( proc_reset ) begin
        for(i=0;i<4;i=i+1)begin
            cache1[i]<=0;
            previous_used[i]<=0;
        end
        state<=IDLE;
    end
    else begin
        for(i=0;i<4;i=i+1)begin
            cache1[i]<=n_cache1[i];
            previous_used[i]<=n_previous_used[i];
        end
        state<=n_state;
    end
end

endmodule
