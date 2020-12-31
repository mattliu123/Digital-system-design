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