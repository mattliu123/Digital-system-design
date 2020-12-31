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


//unified
wire mem_read_D_u, mem_ready_D_u, mem_write_D_u, mem_read_I_u, mem_ready_I_u;
wire [27:0] mem_addr_D_u, mem_addr_I_u;
wire [127:0] mem_wdata_D_u, mem_rdata_D_u, mem_rdata_I_u;



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
    

    L1cache D_cache(
        .clk        (clk)         ,
        .proc_reset (~rst_n)      ,
        .proc_read  (DCACHE_ren)  ,
        .proc_write (DCACHE_wen)  ,
        .proc_addr  (DCACHE_addr) ,
        .proc_rdata (DCACHE_rdata),
        .proc_wdata (DCACHE_wdata),
        .proc_stall (DCACHE_stall),
        .mem_read   (mem_read_D_u)  ,//
        .mem_write  (mem_write_D_u) ,//
        .mem_addr   (mem_addr_D_u)  ,//
        .mem_wdata  (mem_wdata_D_u) ,//
        .mem_rdata  (mem_rdata_D_u) ,//
        .mem_ready  (mem_ready_D_u)//
    );

    L1cache I_cache(
        .clk        (clk)         ,
        .proc_reset (~rst_n)      ,
        .proc_read  (ICACHE_ren)  ,
        .proc_write (ICACHE_wen)  ,
        .proc_addr  (ICACHE_addr) ,
        .proc_rdata (ICACHE_rdata),
        .proc_wdata (ICACHE_wdata),
        .proc_stall (ICACHE_stall),
        .mem_read   (mem_read_I_u)  ,//
        .mem_write  (mem_write_I) ,
        .mem_addr   (mem_addr_I_u)  ,//
        .mem_wdata  (mem_wdata_I) ,
        .mem_rdata  (mem_rdata_I_u) ,//
        .mem_ready  (mem_ready_I_u)//
    );
cacheL2_unified L2_unified(
    .clk(clk),    // Clock
    .rst(~rst_n),
    //ICache
    .L2_read_I(mem_read_I_u),
    .L2_addr_I(mem_addr_I_u),
    .L2_rdata_I(mem_rdata_I_u),
    .L2_ready_I(mem_ready_I_u),
    //Dcache
    .L2_read_D(mem_read_D_u),
    .L2_write_D(mem_write_D_u),
    .L2_addr_D(mem_addr_D_u),
    .L2_wdata_D(mem_wdata_D_u),
    .L2_rdata_D(mem_rdata_D_u),
    .L2_ready_D(mem_ready_D_u),
    //Imem
    .mem_read_I(mem_read_I),
    .mem_addr_I(mem_addr_I),
    .mem_rdata_I(mem_rdata_I),
    .mem_ready_I(mem_ready_I),
    //Dmem
    .mem_read_D(mem_read_D),
    .mem_write_D(mem_write_D),
    .mem_addr_D(mem_addr_D),
    .mem_wdata_D(mem_wdata_D),
    .mem_rdata_D(mem_rdata_D),
    .mem_ready_D(mem_ready_D)
    
);
endmodule




module L1cache(
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
    assign writeread = ((~hit)&&block[154]&&block[155])?1'b1:1'b0;
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
                        mem_write = 1'b1;
                    end
                    else begin
                        n_state = READ;
                        proc_stall = 1'b1;
                        mem_read = 1'b1;
                    end
                end
                else if(proc_write)begin
                    if(hit)begin
                        n_state = IDLE;
                    end
                    else if(writeread)begin
                        n_state = WRITEBACK_W;
                        proc_stall = 1'b1;
                        mem_write = 1'b1;
                    end
                    else begin
                        n_state = WRITE;
                        proc_stall = 1'b1;
                        mem_read = 1;
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

module cacheL2_unified (
    clk,    // Clock
    rst,
    //ICache
    L2_read_I,
    L2_addr_I,
    L2_rdata_I,
    L2_ready_I,
    //Dcache
    L2_read_D,
    L2_write_D,
    L2_addr_D,
    L2_wdata_D,
    L2_rdata_D,
    L2_ready_D,
    //Imem
    mem_read_I,
    mem_addr_I,
    mem_rdata_I,
    mem_ready_I,
    //Dmem
    mem_read_D,
    mem_write_D,
    mem_addr_D,
    mem_wdata_D,
    mem_rdata_D,
    mem_ready_D
    
);

    input clk;
    input rst;
    //ICache
    input L2_read_I;
    input [27:0] L2_addr_I;
    output [127:0] L2_rdata_I;
    output L2_ready_I;
    //Dcache
    input L2_read_D;
    input L2_write_D;
    input [27:0] L2_addr_D;
    input [127:0] L2_wdata_D;
    output [127:0] L2_rdata_D;
    output L2_ready_D;
    //Imem
    output mem_read_I;
    output [27:0] mem_addr_I;
    input [127:0] mem_rdata_I;
    input mem_ready_I;
    //Dmem
    output mem_read_D;
    output mem_write_D;
    output [27:0] mem_addr_D;
    output [127:0] mem_wdata_D;
    input [127:0] mem_rdata_D;
    input mem_ready_D;



    integer i;
    parameter IDLE = 3'd0;
    parameter READ_I = 3'd1;
    parameter READ_D = 3'd2;
    parameter WRITE = 3'd3;
    //parameter WRITEMISS = 3'd4;
    reg [151:0] cache_u [0:63];
    reg [151:0] n_cache_u [0:63];
    reg [2:0] state, n_state;
    reg L2_ready_D, n_L2ready_D, L2_ready_I, n_L2ready_I, mem_read_D, mem_write_D, mem_write_I, mem_read_I;
    reg [127:0] L2_rdata_D, L2_rdata_I;
    wire [5:0] block_num_D, block_num_I;
    wire valid_I, valid_D, match_I, match_D ,hit_I, hit_D;
    wire [21:0] tag_I, tag_D;
    //
    assign block_num_I = L2_addr_I[5:0];
    assign block_num_D = L2_addr_D[5:0];
    assign valid_I = cache_u[block_num_I][150];
    assign valid_D = cache_u[block_num_D][150];
    assign tag_I = L2_addr_I[27:6];
    assign tag_D = L2_addr_D[27:6];
    assign match_I = (tag_I==cache_u[block_num_I][149:128])?1:0;
    assign match_D = (tag_D==cache_u[block_num_D][149:128])?1:0;
    assign hit_I = (match_I&&valid_I)?1:0;
    assign hit_D = (match_D&&valid_D)?1:0;
    assign mem_addr_D = L2_addr_D;
    assign mem_addr_I = L2_addr_I;
    assign mem_wdata_D = cache_u[block_num_D][127:0];


    always@(*)begin
        for(i=0;i<64;i=i+1)begin
            n_cache_u[i] = cache_u[i];
        end
        n_L2ready_I = 0;
        n_L2ready_D = 0;
        mem_read_D = 0;
        mem_write_D = 0;
        mem_read_I = 0;
        L2_rdata_D = cache_u[block_num_D][127:0];
        L2_rdata_I = cache_u[block_num_I][127:0];
        case (state)
            IDLE:begin
                if(L2_read_D)begin
                    if(hit_D&&(~cache_u[block_num_D][151]))begin
                        L2_rdata_D = cache_u[block_num_D][127:0];
                        n_L2ready_D = 1;
                        n_state = IDLE;
                    end
                    else begin
                        n_state = READ_D;
                        mem_read_D = 1;
                    end
                end
                else if(L2_write_D)begin
                
                        n_state = WRITE;
                        mem_write_D = 1;
                    
                end
                else if(L2_read_I)begin
                    if(hit_I&&(cache_u[block_num_I][151]))begin
                        L2_rdata_I = cache_u[block_num_I][127:0];
                        n_L2ready_I = 1;
                        n_state = IDLE;
                    end
                    else begin
                        n_state = READ_I;
                        mem_read_I = 1;
                    end
                end
                else begin
                    n_state = IDLE;
                end
            end
            READ_D:begin
                if(mem_ready_D)begin
                    L2_rdata_D = mem_rdata_D;
                    n_cache_u[block_num_D] = {1'b0,1'b1,L2_addr_D[27:6],mem_rdata_D};
                    n_L2ready_D = 1;
                    mem_read_D = 0;
                    n_state = IDLE;
                end
                else begin
                    n_L2ready_D = 0;
                    n_state = READ_D;
                    mem_read_D = 1;
                end
            end
            READ_I:begin
                if(mem_ready_I)begin
                    L2_rdata_I = mem_rdata_I;
                    n_cache_u[block_num_I] = {2'b11,L2_addr_I[27:6],mem_rdata_I};
                    n_L2ready_I = 1;
                    mem_read_I = 0;
                    n_state = IDLE;
                end
                else begin
                    n_L2ready_I = 0;
                    n_state = READ_I;
                    mem_read_I = 1;
                end
            end
            WRITE:begin
                n_cache_u[block_num_D] = {2'b01,L2_addr_D[27:6],L2_wdata_D};
                if(mem_ready_D)begin
                    n_state = IDLE;
                    n_L2ready_D = 1;
                    mem_write_D = 0;
                end
                else begin
                    n_state = WRITE;
                    n_L2ready_D = 0;
                    mem_write_D = 1;
                end
            end
            /*WRITEMISS:begin
                if(mem_ready_D)begin
                    n_cache_u[block_num_D] = {2'b01,L2_addr_D[27:5],mem_rdata_D};
                    n_state = IDLE;
                    n_L2ready_D = 1;
                    mem_read_D = 0;
                end
                else begin
                    n_state = WRITEMISS;
                    n_L2ready_D = 0;
                    mem_read_D = 1;
                end
            end*/
            default : n_state = IDLE;
        endcase
    end
    always @(posedge clk) begin
        if(rst) begin
            for(i=0;i<64;i=i+1)begin
                cache_u[i]<=0;
            end
            state<=IDLE;
            L2_ready_I<=0;
            L2_ready_D<=0;
        end else begin
            for(i=0;i<64;i=i+1)begin
                cache_u[i]<=n_cache_u[i];
            end
             state<=n_state;
             L2_ready_I<=n_L2ready_I;
             L2_ready_D<=n_L2ready_D;
        end
    end
endmodule


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
    wire [31:0] IF_pc, IF_pc_add4, instr, IF_pc_next;
    // ID
    wire hazard_stall, jalr, branch_or_jal, ID_RegWrite, ID_MemWrite, ID_MemRead, bubble, ID_ALUSrc;
    wire [1:0] ID_MemReg;
    wire [31:0] ID_pc_add4, read_data1, read_data2, ID_imm;
    wire [3:0] ALU_Control;
    // EX
    wire EX_MemRead, EX_RegWrite, EX_MemWrite;
    wire [1:0] EX_MemReg;
    wire [31:0] EX_pc_add4, result, EX_write_data;
    wire [4:0] EX_write_addr;
    // MEM
    wire MEM_RegWrite;
    wire [1:0] MEM_MemReg;
    wire [31:0] MEM_pc_add4, MEM_result;
    wire [4:0] MEM_rd;
    // WB
    wire WB_reg_write;
    wire [31:0] WB_write_data;
    wire [4:0] WB_write_addr;
    //==== combinational circuit ==============================
    pipeline_IF pipeline0(.clk(clk), .rst_n(rst_n), .stall(stall), .hazard_stall(hazard_stall), .pc(IF_pc), .IF_pc_next(IF_pc_next));
    assign ICACHE_ren = 1'b1;
    assign ICACHE_wen = 1'b0;
    assign ICACHE_addr = IF_pc[31:2];
    assign ICACHE_wdata = 32'b0;
    assign stall = (ICACHE_stall | DCACHE_stall);
    
    pipeline_ID pipeline1(.clk(clk), .rst_n(rst_n), .stall(stall), .hazard_stall(hazard_stall), .instr(instr), .bubble(bubble), .jalr(jalr), .branch_or_jal(branch_or_jal), 
                    .MEM_rd(MEM_rd), .imm(ID_imm), .ALUSrc(ID_ALUSrc), .I_instr(ICACHE_rdata), .i_pc(IF_pc), .pc_add4(IF_pc_add4), .pc_add4_out(ID_pc_add4), .EX_MemRead(EX_MemRead), 
                    .EX_write_addr(EX_write_addr), .WB_reg_write(WB_reg_write), .WB_write_data(WB_write_data), .WB_write_addr(WB_write_addr),
                    .ALU_Control(ALU_Control), .RegWrite_o(ID_RegWrite), .MemWrite(ID_MemWrite), .MemRead(ID_MemRead), .MemReg(ID_MemReg), .data1(read_data1), .data2(read_data2), 
                    .EX_result(result), .EX_RegWrite(EX_RegWrite), .MEM_result(MEM_result), .MEM_RegWrite(MEM_RegWrite), .IF_pc(IF_pc), .IF_pc_next(IF_pc_next), .IF_pc_add4(IF_pc_add4)); 

    pipeline_EX pipeline2(.clk(clk), .rst_n(rst_n), .D_stall(stall), .bubble(bubble), .i_rs(instr[19:15]), .i_rt(instr[24:20]), .i_rd(instr[11:7]), .i_ALU_Control(ALU_Control), .i_read_data1(read_data1), 
                          .i_ALUSru(ID_ALUSrc), .i_imm(ID_imm), .i_RegWrite(ID_RegWrite), .i_MemWrite(ID_MemWrite), .i_MemRead(ID_MemRead), .i_MemReg(ID_MemReg), .i_pc_add4(ID_pc_add4), .i_read_data2(read_data2), 
                          .o_RegWrite(EX_RegWrite), .o_MemWrite(EX_MemWrite), .o_MemRead(EX_MemRead), .o_MemReg(EX_MemReg), .o_pc_add4(EX_pc_add4), .o_rd(EX_write_addr), .result(result), .data2_r(EX_write_data), 
                          .MEM_RegWrite(MEM_RegWrite), .WB_RegWrite(WB_reg_write), .MEM_rd(MEM_rd), .WB_rd(WB_write_addr), .MEM_write_data(MEM_result), .WB_write_data(WB_write_data));

    pipeline_MEM pipeline3(.clk(clk), .rst_n(rst_n), .D_stall(stall), .i_RegWrite(EX_RegWrite), .i_MemWrite(EX_MemWrite), .i_MemRead(EX_MemRead), .i_MemReg(EX_MemReg), .i_pc_add4(EX_pc_add4),
                           .i_rd(EX_write_addr), .result(result), .i_write_data(EX_write_data), .o_RegWrite(MEM_RegWrite), .o_MemWrite(DCACHE_wen), .o_MemRead(DCACHE_ren), .o_MemReg(MEM_MemReg),
                           .o_pc_add4(MEM_pc_add4), .o_write_data(DCACHE_wdata), .o_result(MEM_result), .o_rd(MEM_rd));
    assign DCACHE_addr = MEM_result[31:2];

    pipeline_WB pipeline4(.clk(clk), .rst_n(rst_n), .D_stall(stall), .i_RegWrite(MEM_RegWrite), .i_MemReg(MEM_MemReg), .i_pc_add4(MEM_pc_add4), .i_read_data(DCACHE_rdata), 
                          .result(MEM_result), .i_rd(MEM_rd), .o_RegWrite(WB_reg_write), .o_rd(WB_write_addr), .write_data(WB_write_data));

endmodule

module pipeline_IF(  // instruction fetch
    clk,
    rst_n,
    stall,
    hazard_stall,
    pc,
    IF_pc_next
);
    //==== input/output =======================================
    input clk, rst_n, stall, hazard_stall;
    input [31:0] IF_pc_next;
    output [31:0] pc;
    //==== wire/reg definition ================================
    reg [31:0] pc_r;
    //==== combinational circuit ==============================
    assign pc = pc_r;
    //==== sequential circuit =================================
    always@ (posedge clk) begin
        if(!rst_n) pc_r <= 32'b0;
        else if (stall || hazard_stall) pc_r <= pc;
        else       pc_r <= IF_pc_next;
    end

endmodule

module pipeline_ID(  // instruction fetch
    clk,
    rst_n,
    stall,
    instr,
    EX_MemRead, 
    EX_write_addr,
    WB_reg_write,
    WB_write_data,
    WB_write_addr,
    hazard_stall,
    jalr,
    branch_or_jal,
    ALU_Control,
    RegWrite_o,
    MemWrite, 
    MemRead, 
    MemReg,
    bubble,
    data1, 
    data2, 
    EX_result,
    MEM_result,
    EX_RegWrite,
    MEM_RegWrite,
    MEM_rd,
    imm,
    ALUSrc,
    I_instr,
    i_pc,
    pc_add4,
    pc_add4_out, 
    IF_pc,
    IF_pc_next,
    IF_pc_add4
);
    //==== input/output =======================================
    input clk, rst_n, stall, EX_MemRead, WB_reg_write, EX_RegWrite, MEM_RegWrite;
    input  [4:0] WB_write_addr, EX_write_addr, MEM_rd;
    input  [31:0] I_instr, i_pc, pc_add4, WB_write_data, EX_result, MEM_result, IF_pc;
    output [31:0] pc_add4_out;
    // EX_result(), .EX_RegWrite(), EX_write_addr                 .MEM_result(), .MEM_RegWrite()    MEM_rd    WB_write_data   WB_reg_write     WB_write_addr
    output branch_or_jal;
    output [31:0] instr, IF_pc_next, IF_pc_add4;
    output reg [31:0] imm, data1, data2;
    output reg [3:0] ALU_Control;
    output reg jalr, hazard_stall, MemWrite, MemRead, bubble, RegWrite_o, ALUSrc;
    output reg [1:0] MemReg;
    //==== wire/reg definition ================================
    wire flush;
    wire [31:0] pc_out, pc_add_imm, rs_add_imm;
    wire [31:0] read_data1, read_data2;
    // control unit
    reg beq, bne, jal, RegWrite;
    // equal
    wire zero;
    reg [31:0] instr_r, pc_r, pc_add4_r;
    //==== Register file ======================================
        reg[31:0] reg_array[31:0];
        integer i;

        assign read_data1 = (|instr[19:15])? reg_array[instr[19:15]] : 32'b0;
        assign read_data2 = (|instr[24:20])? reg_array[instr[24:20]] : 32'b0;

        always@(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                for(i = 0; i < 32; i = i + 1) begin 
                    reg_array[i] <= 32'b0;
                end
            end else begin
                if (WB_reg_write) begin
                    reg_array[WB_write_addr] <= WB_write_data;
                end
            end
        end
    //==== combinational circuit ==============================
    // IF pc
    wire [31:0] pc_0;
    assign IF_pc_add4 = IF_pc + 4;
    assign pc_0 = (branch_or_jal)? pc_add_imm : IF_pc_add4;
    assign IF_pc_next = (jalr)? rs_add_imm : pc_0;
    //
    assign instr = instr_r;
    assign pc_out = pc_r;
    assign pc_add4_out = pc_add4_r;
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
        case(instr[6:2])
            5'b01100: begin // R-type
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
            5'b01000: begin // sw
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
            5'b00000: begin // lw
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
            5'b11000: begin // beq, bne
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
            5'b11011: begin // jal
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
            5'b11001: begin // jalr
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
            5'b00100: begin // R-type with constant(imm)
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
    always @(*) begin   // RegWrite = 0 when write_addr = 0
        if (|instr[11:7]) RegWrite_o = RegWrite;
        else RegWrite_o = 1'b0;
    end
    always @(*) begin   // imm
        case(instr[6:2])
            5'b01000: begin // sw
                imm = {{21{instr[31]}}, instr[30:25], instr[11:8], instr[7]};
            end
            5'b00000: begin // lw
                imm = {{21{instr[31]}}, instr[30:25], instr[24:21], instr[20]};
            end
            5'b11000: begin // beq
                imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            end
            5'b11011: begin // jal
                imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:25], instr[24:21], 1'b0};
            end
            5'b11001: begin // jalr
                imm = {{21{instr[31]}}, instr[30:25], instr[24:21], instr[20]};
            end
            5'b00100: begin // I type
                imm = {{21{instr[31]}}, instr[30:25], instr[24:21], instr[20]};
            end
            default: begin
                imm = 32'b0;
            end
        endcase
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
    assign pc_add_imm = pc_out + imm;
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
                            if (instr[31:30] == 2'b01) ALU_Control = 4'b0100;   // sub
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
            pc_r <= i_pc;
            pc_add4_r <= pc_add4;
        end
    end
endmodule

module pipeline_EX(
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
    MEM_RegWrite, 
    WB_RegWrite,                                   ,
    MEM_write_data, 
    WB_write_data,
    MEM_rd, 
    WB_rd,
    o_RegWrite, 
    o_MemWrite, 
    o_MemRead, 
    o_MemReg, 
    o_pc_add4,
    o_rd,
    result, 
    data2_r
);
    //==== input/output =======================================
    input clk, rst_n, D_stall, bubble;
    input i_RegWrite, i_MemWrite, i_MemRead, i_ALUSru, MEM_RegWrite, WB_RegWrite; 
    input [1:0] i_MemReg;
    input [31:0] i_read_data1, i_imm, i_pc_add4, i_read_data2, MEM_write_data,  WB_write_data;
    input [4:0] i_rs, i_rt, i_rd, MEM_rd, WB_rd;
    input [3:0] i_ALU_Control;
    output o_RegWrite, o_MemWrite, o_MemRead;
    output [1:0] o_MemReg;
    output [31:0] o_pc_add4;
    output [4:0] o_rd;
    output reg [31:0] result, data2_r;
    //==== wire/reg definition ================================
    wire o_ALUSrc;
    wire [3:0] o_ALU_Control;
    wire [4:0]  o_rs, o_rt;
    wire [31:0] o_imm, o_read_data1, o_read_data2;
    reg o_RegWrite_r, o_MemWrite_r, o_MemRead_r, o_ALUSrc_r;
    reg [1:0] o_MemReg_r;
    reg [31:0] o_read_data1_r, o_imm_r, o_pc_add4_r, o_read_data2_r;
    reg [4:0] o_rs_r, o_rt_r, o_rd_r;
    reg [3:0] o_ALU_Control_r;
    // forward
    reg [31:0] data1_r;
    wire [31:0] data2_w;
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
    // forward unit data1
    always @(*) begin   
        if      (MEM_RegWrite && (MEM_rd == o_rs) && (|o_rs)) data1_r = MEM_write_data;
        else if (WB_RegWrite && (WB_rd == o_rs) && (|o_rs))   data1_r = WB_write_data;
        else                                                      data1_r = o_read_data1;
    end
    // forward unit data2
    always @(*) begin   
        if      (MEM_RegWrite && (MEM_rd == o_rt) && (|o_rt)) data2_r = MEM_write_data;
        else if (WB_RegWrite && (WB_rd == o_rt) && (|o_rt))   data2_r = WB_write_data;
        else                                                  data2_r = o_read_data2;
    end
    // ALUSrc
    assign data2_w = (o_ALUSrc)? o_imm : data2_r;
    // ALU
    always @(*) begin   
        if (o_ALU_Control[3]) result = data1_r + data2_w;
        else begin
            case(o_ALU_Control[2:0])
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

module pipeline_MEM(
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

module pipeline_WB(
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
    o_rd,
    write_data
);
    //==== input/output =======================================
    input clk, rst_n, D_stall;
    input i_RegWrite; 
    input [1:0] i_MemReg;
    input [4:0] i_rd;
    input [31:0] i_pc_add4, result, i_read_data;
    output o_RegWrite;
    output [4:0] o_rd;
    output [31:0] write_data;
    //==== wire/reg definition ================================
    wire [1:0] o_MemReg;
    wire [31:0] o_pc_add4, o_read_data, o_result;
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
    assign write_data = (o_MemReg[1])? o_pc_add4 : 
                        (o_MemReg[0])? o_read_data : o_result;
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