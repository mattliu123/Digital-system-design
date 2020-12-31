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
    reg [31:0] proc_rdata, n_proc_rdata;
    reg proc_stall, n_proc_stall;
    reg mem_write, n_mem_write, mem_read, n_mem_read;
    reg [3:0] state, n_state;
    reg [309:0] cache1 [0:3];
    reg [309:0] n_cache1[0:3];
    reg count_r [0:3], count_l[0:3], n_count_r[0:3], n_count_l[0:3];
    wire valid1, valid2, match1, match2;
    wire [25:0] tag1, tag2;
    wire [1:0] block_num;
    wire [1:0] data_num;
//==== combinational circuit ==============================
	assign block_num = proc_addr[3:2];
	assign data_num = proc_addr[1:0];
	assign tag1 = cache1[block_num][308:283];
	assign tag2 = cache1[block_num][153:128];
	assign valid1 = cache1[block_num][309];
	assign valid2 = cache1[block_num][154];
	assign match1 = (tag1==proc_addr[29:4])?1'b1:1'b0;
	assign match2 = (tag2==proc_addr[29:4])?1'b1:1'b0;
	assign mem_addr = proc_addr[29:2];
    assign mem_wdata = (match1&&valid1)?cache1[block_num][282:155]:cache1[block_num][127:0];

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
					n_mem_read = 0;
					n_mem_write = 0;
				end
			end
			READ:
			begin
				if(((!valid1)||(!match1))&&((!valid2)||(!match2))&&(proc_read))begin
					n_state = READMEM;
					n_proc_stall = 1;
					n_mem_read = 1;
					n_mem_write = 0;
				end
				else if(proc_write)begin
					n_state = WRITE;
					n_proc_stall = 1;
					n_mem_read = 0;
					n_mem_write = 0;
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
				if((match1&&valid1)||(match2&&valid2)&&(proc_write))begin
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
					n_mem_read = 0;
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
        for(i=0; i<4; i=i+1)begin
            n_cache1[i] = cache1[i];
            n_count_l[i] = count_l[i];
            n_count_r[i] = count_r[i];
        end
        case (state)
            READDATA:
            begin
                if(count_r[block_num])begin
                    n_cache1[block_num][309] = 1;
                    n_cache1[block_num][308:283] = proc_addr[29:4];
                    n_cache1[block_num][282:155] = mem_rdata;
                    n_cache1[block_num][154:0] = cache1[block_num][154:0];
                    n_count_l[block_num] = 1;
                    n_count_r[block_num] = 0;
                end
                else begin
                    n_cache1[block_num][309:155] = cache1[block_num][309:155];
                    n_cache1[block_num][154] = 1;
                    n_cache1[block_num][153:128] = proc_addr[29:4];
                    n_cache1[block_num][127:0] = mem_rdata;
                    n_count_r[block_num] = 1;
                    n_count_l[block_num] = 0;
                end
            end
            HIT:
            begin
                if((match1&&valid1))begin
                    if(data_num==2'b11)begin
                        n_cache1[block_num] = {cache1[block_num][309:283],proc_wdata,cache1[block_num][250:0]};
                    end
                    else if(data_num==2'b10)begin
                        n_cache1[block_num] = {cache1[block_num][309:251],proc_wdata,cache1[block_num][218:0]};
                    end
                    else if(data_num==2'b01)begin
                        n_cache1[block_num] = {cache1[block_num][309:219],proc_wdata,cache1[block_num][186:0]};
                    end
                    else if(data_num==2'b00)begin
                        n_cache1[block_num] = {cache1[block_num][309:187],proc_wdata,cache1[block_num][154:0]};
                    end
                    else begin
                        n_cache1[block_num] = cache1[block_num];
                    end
                end
                else if((match2&&valid2))begin
                    if(data_num==2'b11)begin
                        n_cache1[block_num] = {cache1[block_num][309:128],proc_wdata,cache1[block_num][95:0]};
                    end
                    else if(data_num==2'b10)begin
                        n_cache1[block_num] = {cache1[block_num][309:96],proc_wdata,cache1[block_num][63:0]};
                    end
                    else if(data_num==2'b01)begin
                        n_cache1[block_num] = {cache1[block_num][309:64],proc_wdata,cache1[block_num][31:0]};
                    end
                    else if(data_num==2'b00)begin
                        n_cache1[block_num] = {cache1[block_num][309:32],proc_wdata};
                    end
                    else begin
                        n_cache1[block_num] = cache1[block_num];
                    end
                end
                else begin
                    n_cache1[block_num] = cache1[block_num];
                end
            end
            MISSREAD:
            begin
                if(count_r[block_num])begin
                    n_cache1[block_num][309] = 1;
                    n_cache1[block_num][308:283] = proc_addr[29:4];
                    n_cache1[block_num][282:155] = mem_rdata;
                    n_cache1[block_num][154:0] = cache1[block_num][154:0];
                    n_count_l[block_num] = 1;
                    n_count_r[block_num] = 0;
                end
                else begin
                    n_cache1[block_num][309:155] = cache1[block_num][309:155];
                    n_cache1[block_num][154] = 1;
                    n_cache1[block_num][153:128] = proc_addr[29:4];
                    n_cache1[block_num][127:0] = mem_rdata;
                    n_count_r[block_num] = 1;
                    n_count_l[block_num] = 0;
                end
            end
            default : n_cache1[block_num] = cache1[block_num];
        endcase
    end

    always@(*)begin
        if(state==READDATA)begin
            if(count_r[block_num])begin
                if(data_num==2'b11)begin
                    n_proc_rdata = n_cache1[block_num][282:251];
                end
                else if(data_num==2'b10)begin
                    n_proc_rdata = n_cache1[block_num][250:219];
                end
                else if(data_num==2'b01)begin
                    n_proc_rdata = n_cache1[block_num][218:187];
                end
                else if(data_num==2'b00)begin
                    n_proc_rdata = n_cache1[block_num][186:155];
                end
                else begin
                    n_proc_rdata = proc_rdata;
                end
            end
            else begin
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
        end
        else if(state==READHIT)begin
            if((!valid1)||(!match1))begin
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
                if(data_num==2'b11)begin
                    n_proc_rdata = n_cache1[block_num][282:251];
                end
                else if(data_num==2'b10)begin
                    n_proc_rdata = n_cache1[block_num][250:219];
                end
                else if(data_num==2'b01)begin
                    n_proc_rdata = n_cache1[block_num][218:187];
                end
                else if(data_num==2'b00)begin
                    n_proc_rdata = n_cache1[block_num][186:155];
                end
                else begin
                    n_proc_rdata = proc_rdata;
                end
            end
        end
        else begin
            n_proc_rdata = proc_rdata;
        end
    end
//==== sequential circuit =================================
always@( posedge clk ) begin
    if( proc_reset ) begin
        for (i = 0; i < 4; i=i+1) begin
            cache1[i]<=0;
            count_l[i]<=0;
            count_r[i]<=1;
        end
        mem_read<=0;
        mem_write<=0;
        proc_stall<=0;
        proc_rdata<=0;
        state<=IDLE;
    end
    else begin
        for (i = 0; i < 4; i=i+1) begin
            cache1[i]<=n_cache1[i];
            count_l[i]<=n_count_l[i];
            count_r[i]<=n_count_r[i];
        end
        mem_read<=n_mem_read;
        mem_write<=n_mem_write;
        proc_stall<=n_proc_stall;
        proc_rdata<=n_proc_rdata;
        state<=n_state;
    end
end

endmodule
