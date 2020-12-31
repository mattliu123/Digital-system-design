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
    parameter IDLE = 4'd0;
    parameter READ = 4'd1;
    parameter READMEM = 4'd2;
    parameter READDATA = 4'd3;
    parameter WRITE = 4'd4;
    parameter HIT = 4'd5;
    parameter MISS = 4'd6;
    parameter WRITEMEM = 4'd7;
    parameter WRITEDATA = 4'd8;
    parameter MISSREAD = 4'd9;
    parameter READHIT = 4'd10;
    reg proc_stall, mem_read, mem_write;
    reg [31:0] n_proc_rdata, proc_rdata;
    reg [153:0] cache1 [0:7];
    reg [153:0] n_cache1 [0:7];
    reg [3:0] state, n_state;
    reg n_proc_stall, n_mem_read, n_mem_write;
    reg dirty[0:7], n_dirty[0:7];
    wire valid, match;
    wire [24:0] tag;
    wire [2:0] block_num;
    wire [1:0] data_num;
    assign block_num = proc_addr[4:2];
    assign data_num = proc_addr[1:0];
    assign tag = cache1[block_num][152:128];
    assign valid = cache1[block_num][153];
    assign match = (tag==proc_addr[29:5])?1'b1:1'b0;
    assign mem_addr = proc_addr[29:2];
    assign mem_wdata = cache1[block_num][127:0];

//==== combinational circuit ==============================
always@(*)begin
    case(state)
        IDLE:
            begin
                if(proc_read)begin
                    n_state = READ;
                    n_proc_stall = 1;
                    n_mem_read = 0;
                    n_mem_write = 0;
                end
                else if(proc_write)begin
                    n_state = WRITE;
                    n_proc_stall = 1;
                    n_mem_read = 0;
                    n_mem_write = 0;
                end
                else begin
                    n_state = IDLE;
                    n_proc_stall = 0;
                    n_mem_write = 0;
                    n_mem_read = 0;
                end
            end
        READ:
            begin
                if(((!valid)||(!match))&&(proc_read)) begin
                    n_state = READMEM;
                    n_proc_stall = 1;
                    n_mem_read = 1;
                    n_mem_write = 0;
                end
                else if(proc_write) begin
                    n_state = WRITE;
                    n_proc_stall = 1;
                    n_mem_write = 0;
                    n_mem_read = 0;
                end
                else begin
                    n_state = READHIT;
                    n_proc_stall = 1;
                    n_mem_read = 0;
                    n_mem_write = 0;
                end
            end
        READHIT:
            begin
                n_state = IDLE;
                n_proc_stall = 0;
                n_mem_read = 0;
                n_mem_write = 0;
            end
        READMEM:
            begin
                if(mem_ready)begin
                    n_state = READDATA;
                    n_proc_stall = 1;
                    n_mem_read = 0;
                    n_mem_write = 0;
                end
                else begin
                    n_state = READMEM;
                    n_proc_stall = 1;
                    n_mem_read = 1;
                    n_mem_write = 0;
                end
            end
        READDATA:
            begin
                n_state = IDLE;
                n_proc_stall = 0;
                n_mem_read = 0;
                n_mem_write = 0;
            end
        WRITE:
            begin
                if((match&&valid)&&(proc_write)) begin
                    n_state = HIT;
                    n_proc_stall = 1;
                    n_mem_read = 0;
                    n_mem_write = 0;
                end
                else if(proc_read)begin
                    n_state = READ;
                    n_proc_stall = 1;
                    n_mem_read = 0;
                    n_mem_write = 0;
                end
                else begin
                    n_state = MISS;
                    n_proc_stall = 1;
                    n_mem_read = 1;
                    n_mem_write = 0;
                end
            end
        HIT:
            begin
                n_state = WRITEMEM;
                n_proc_stall = 1;
                n_mem_read = 0;
                n_mem_write = 1;
            end
        MISS:
            begin
                if(mem_ready)begin
                    n_state = MISSREAD;
                    n_proc_stall = 1;
                    n_mem_write = 0;
                    n_mem_read = 0;
                end
                else begin
                    n_state = MISS;
                    n_proc_stall = 1;
                    n_mem_read = 1;
                    n_mem_write = 0;
                end
            end
        MISSREAD:
            begin
                    n_state = HIT;
                    n_proc_stall = 1;
                    n_mem_write = 0;
                    n_mem_read = 0;
            end
        WRITEMEM:
            begin
                if(mem_ready)begin
                    n_state = WRITEDATA;
                    n_proc_stall = 1;
                    n_mem_read = 0;
                    n_mem_write = 0;
                end
                else begin
                    n_state = WRITEMEM;
                    n_proc_stall = 1;
                    n_mem_read = 0;
                    n_mem_write = 1;
                end
            end
        WRITEDATA:
            begin
                n_state = IDLE;
                n_proc_stall = 0;
                n_mem_read = 0;
                n_mem_write = 0;
            end
        default:
            begin
                n_state = IDLE;
                n_proc_stall = 0;
                n_mem_read = 0;
                n_mem_write = 0;
            end
    endcase // state
end

always@(*)begin
    for(i=0; i<8; i=i+1)begin
        n_cache1[i] = cache1[i];
    end
    case(state)
        /*IDLE:
            begin
                n_cache1[block_num][153] = cache1[block_num][153];
                n_cache1[block_num][152:128] = tag;
                n_cache1[block_num][127:0] = cache1[block_num][127:0];
            end
        READ:
            begin
                n_cache1[block_num][153] = cache1[block_num][153];
                n_cache1[block_num][152:128] = tag;
                n_cache1[block_num][127:0] = cache1[block_num][127:0];
            end
        READMEM:
            begin
                n_cache1[block_num][153] = cache1[block_num][153];
                n_cache1[block_num][152:128] = tag;
                n_cache1[block_num][127:0] = cache1[block_num][127:0];
            end*/
 		READDATA:
            begin
                n_cache1[block_num][153] = 1;
                n_cache1[block_num][152:128] = proc_addr[29:5];
                n_cache1[block_num][127:0] = mem_rdata;
            end
        /*WRITE:
            begin
                n_cache1[block_num][153] = cache1[block_num][153];
                n_cache1[block_num][152:128] = tag;
                n_cache1[block_num][127:0] = cache1[block_num][127:0];
            end*/
  		HIT:
            begin
                if(data_num==2'b11)begin
                    n_cache1[block_num] = {cache1[block_num][153:128], proc_wdata, cache1[block_num][95:0]};
                end
                else if(data_num==2'b10)begin
                    n_cache1[block_num] = {cache1[block_num][153:96], proc_wdata, cache1[block_num][63:0]};
                end
                else if(data_num==2'b01)begin
                    n_cache1[block_num] = {cache1[block_num][153:64], proc_wdata, cache1[block_num][31:0]};
                end
                else if(data_num==2'b00)begin
                    n_cache1[block_num] = {cache1[block_num][153:32], proc_wdata};
                end
                else begin
                    n_cache1[block_num] = cache1[block_num];
                end
            end
        /*MISS:
            begin
                n_cache1[block_num][153] = cache1[block_num][153];
                n_cache1[block_num][152:128] = tag;
                n_cache1[block_num][127:0] = cache1[block_num][127:0];
            end*/
  		MISSREAD:
            begin
                n_cache1[block_num][153] = 1;
                n_cache1[block_num][152:128] = proc_addr[29:5];
                n_cache1[block_num][127:0] = mem_rdata;
            end
        /*WRITEMEM:
            begin
                n_cache1[block_num][153] = cache1[block_num][153];
                n_cache1[block_num][152:128] = tag;
                n_cache1[block_num][127:0] = cache1[block_num][127:0];
            end
        WRITEDATA:
            begin
                n_cache1[block_num][153] = cache1[block_num][153];
                n_cache1[block_num][152:128] = tag;
                n_cache1[block_num][127:0] = cache1[block_num][127:0];
            end*/
 		default:
         	begin
         		n_cache1[block_num] = cache1[block_num];
         	end
    endcase
end

always@(*)begin
    if((state==READDATA)||(state==READHIT))begin
        if(data_num==2'b11)begin
            n_proc_rdata = n_cache1[block_num][127:96];
        end
        else if(data_num==2'b10)begin
            n_proc_rdata = n_cache1[block_num][95:64];
        end
        else if(data_num==2'b01)begin
            n_proc_rdata = n_cache1[block_num][63:32];
        end
        else if(data_num==2'b00)begin
            n_proc_rdata = n_cache1[block_num][31:0];
        end
        else begin
            n_proc_rdata = proc_rdata;
        end

    end
    else begin
        n_proc_rdata = proc_rdata;
    end
end

/*always@(*)begin
    if(state==HIT)begin
        if(data_num==2'b11)begin
            n_cache1[block_num] = {cache1[block_num][153:128], proc_wdata, cache1[block_num][95:0]};
        end
        else if(data_num==2'b10)begin
            n_cache1[block_num] = {cache1[block_num][153:96], proc_wdata, cache1[block_num][63:0]};
        end
        else if(data_num==2'b01)begin
            n_cache1[block_num] = {cache1[block_num][153:64], proc_wdata, cache1[block_num][31:0]};
        end
        else if(data_num==2'b00)begin
            n_cache1[block_num] = {cache1[block_num][153:32], proc_wdata};
        end
        else begin
            n_cache1[block_num] = cache1[block_num];
        end
    end
    else begin
            n_cache1[block_num] = cache1[block_num];
    end
end*/ 
//==== sequential circuit =================================
always@( posedge clk ) begin
    if( proc_reset ) begin
        for (i = 0; i < 8; i=i+1) begin
            cache1[i]<=0;
            dirty[i]<=0;
        end
        mem_read<=0;
        mem_write<=0;
        proc_stall<=0;
        proc_rdata<=0;
        state<=IDLE;
    end
    else begin
        for (i = 0; i < 8; i=i+1) begin
            cache1[i]<=n_cache1[i];
            dirty[i]<=n_dirty[i];
        end
        mem_read<=n_mem_read;
        mem_write<=n_mem_write;
        proc_stall<=n_proc_stall;
        proc_rdata<=n_proc_rdata;
        state<=n_state;
    end
end

endmodule
