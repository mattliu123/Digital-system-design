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
    wire read, write, ready;
    wire [27:0] addr;
    wire [127:0] wdata, rdata;

    L1cache cache_1(
        .clk(clk), 
        .proc_reset(proc_reset), 
        .proc_read(proc_read), 
        .proc_write(proc_write), 
        .proc_addr(proc_addr), 
        .proc_rdata(proc_rdata), 
        .proc_wdata(proc_wdata),
        .proc_stall(proc_stall),
        .mem_read(read),
        .mem_write(write),
        .mem_addr(addr),
        .mem_rdata(rdata),
        .mem_wdata(wdata),
        .mem_ready(ready)
    );

    L2cache cache_2(
        .rst(proc_reset),
        .clk(clk),
        .L2_read(read),
        .L2_write(write),
        .L2_addr(addr),
        .L2_wdata(wdata),
        .L2_rdata(rdata),
        .L2_ready(ready),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_rdata(mem_rdata),
        .mem_ready(mem_ready)
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

module L2cache (
    rst,
    clk,    // Clock
    L2_read,
    L2_write,
    L2_addr,
    L2_wdata,
    L2_rdata,
    L2_ready,
    mem_read,
    mem_write,
    mem_addr,
    mem_wdata,
    mem_rdata,
    mem_ready
);

//==== input/output definition ============================
    input clk;
    input rst;
    //L1 interface
    input L2_read;
    input L2_write;
    input [27:0] L2_addr;
    input [127:0] L2_wdata;
    output [127:0] L2_rdata;
    output L2_ready;

    //Mem interface
    input [127:0] mem_rdata;
    input mem_ready;
    output mem_read;
    output mem_write;
    output [27:0] mem_addr;
    output [127:0] mem_wdata;
//==== wire/reg definition ================================
    integer i;
    parameter IDLE = 2'd0;
    parameter READ = 2'd1;
    parameter WRITE = 2'd2;
    parameter WRITEMISS = 2'd3;
    reg [151:0] cache2 [0:31];      //[151]valid    [150:128]tag     [127:0]data
    reg [151:0] n_cache2[0:31];     
    reg [1:0] state, n_state;
    reg [127:0] L2_rdata;
    wire [4:0] block_num;
    wire valid, match, hit;
    wire [22:0] tag;
    reg L2_ready, mem_read, mem_write, n_L2_ready;
    assign block_num = L2_addr[4:0];
    assign valid = cache2[block_num][151];
    assign tag = cache2[block_num][150:128];
    assign match = (tag==L2_addr[27:5])?1:0;
    assign hit = (valid&&match)?1:0;
    assign mem_addr = L2_addr;
    assign mem_wdata = cache2[block_num][127:0];

    always@(*)begin
        for (i = 0; i < 32; i=i+1) begin
            n_cache2[i] = cache2[i];
        end
        n_L2_ready = 0;
        mem_read = 0;
        mem_write = 0;
        L2_rdata = cache2[block_num][127:0];
        case (state)
            IDLE:begin
                if(L2_read)begin
                    if(hit)begin
                        L2_rdata = cache2[block_num][127:0];
                        n_state = IDLE;
                        n_L2_ready = 1;
                    end
                    else begin
                        n_state = READ;
                        mem_read = 1;
                    end
                end
                else if(L2_write)begin
                    if(hit)begin
                        n_state = WRITE;
                        mem_write = 1;
                    end
                    else begin
                        n_state = WRITEMISS;
                        mem_read = 1;
                    end
                end
                else begin
                    n_state = IDLE;
                end
            end
            READ:begin
                if(mem_ready)begin
                    n_cache2[block_num] = {1'b1,L2_addr[27:5],mem_rdata};
                    L2_rdata = mem_rdata;
                    mem_read = 0;
                    n_L2_ready = 1;
                    n_state = IDLE;
                end
                else begin
                    mem_read = 1;
                    n_L2_ready = 0;
                    n_state = READ;
                end
            end
            WRITE:begin
                n_cache2[block_num] = {1'b1,L2_addr[27:5],L2_wdata};
                if(mem_ready)begin
                    mem_write = 0;
                    n_L2_ready = 1;
                    n_state = IDLE;
                end
                else begin
                    mem_write = 1;
                    n_L2_ready = 0;
                    n_state = WRITE;
                end
            end
            WRITEMISS:begin
                if(mem_ready)begin
                    n_cache2[block_num] = {1'b1,L2_addr[27:5],mem_rdata};
                    mem_write = 1;
                    mem_read = 0;
                    n_L2_ready = 0;
                    n_state = WRITE;
                end
                else begin
                    mem_read = 1;
                    mem_write = 0;
                    n_L2_ready = 0;
                    n_state = WRITEMISS;
                end
            end
            default : n_state = IDLE;
        endcase
    end
    always @(posedge clk) begin
        if(rst) begin
            for (i = 0; i < 32; i=i+1) begin
                cache2[i]<=0;
            end
            state<=IDLE;
            L2_ready<=0;
        end else begin
            for (i = 0; i < 32; i=i+1) begin
                cache2[i]<=n_cache2[i];
            end
            state<=n_state;
            L2_ready<=n_L2_ready;
        end
    end

endmodule