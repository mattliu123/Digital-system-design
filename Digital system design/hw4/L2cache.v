module L2cache (
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
	//L1 interface
	input L2_read;
	input L2_write;
	input [27:0] L2_addr;
	input [127:0] L2_wdata;
	output [31:0] L2_rdata;
	output L2_ready;

	//Mem interface
	input [31:0] mem_rdata;
	input mem_ready;
	output mem_read;
	output mem_write;
	output [27:0] mem_addr;
	output [127:0] mem_wdata;
//==== wire/reg definition ================================
	integer i;
	parameter IDLE = 3'd0;
	parameter READ = 3'd1;
	parameter WRITE = 3'd2;
	parameter WRITEBACK_R = 3'd3;
	parameter WRITEBACK_W = 3'd4;
	reg [307:0] cache2 [0:15];      //[307]valid1,    [306]dirty1,    [305:282]tag1,    [281:154]data1,    [153]valid2,   [152]dirty2,    [151:128]tag2,    [127:0]data2
	reg [307:0] n_cache2[0:15];
	reg [2:0] state, n_state;
	reg previous_used[0:15], n_previous_used[0:15];
	reg [127:0] L2_rdata;
	reg [27:0] mem_addr;
	wire [3:0] block_num;
	wire valid1, valid2, match1, match2, hit, writeread, which_cache;
	wire [153:0] block;
    wire [23:0] tag1, tag2;


//==== combinatioal part ==================================
	assign block_num = L2_addr[27:4];
	assign tag2 = cache2[block_num][151:128];
	assign tag1 = cache2[block_num][305:282];
	assign valid1 = cache2[block_num][307];
	assign valid2 = cache2[block_num][153];
	assign match1 = (tag1==L2_addr[27:4])?1'b1:1'b0;
	assign match2 = (tag2==L2_addr[27:4])?1'b1:1'b0;
	assign hit = ((valid1&&match1)||(valid2&&match2))?1'b1:1'b0;
	assign which_cache = (hit)?(valid2&match2):previous_used[block_num];
	assign block = (which_cache)?cache2[block_num][153:0]:cache2[block_num][307:154];
	assign writeread = (block[153]&&block[152]&&(!hit))?1'b1:1'b0;
	assign mem_wdata = block[127:0];

	always@(*)begin
		L2_ready = 0;
		mem_read = 0;
		mem_write = 0;
		for(i=0;i<16;i=i+1)begin
			n_cache2[i] = cache2[i];
			n_previous_used[i] = previous_used[i];
		end
		L2_rdata = 0;
		mem_addr = L2_addr;
		case (state)
			IDLE:begin
				if(L2_read)begin
					if(hit)begin
						n_state = IDLE;
						L2_rdata = block[127:0];
						L2_ready = 1;
					end
					else if(writeread)begin
						n_state = WRITEBACK_R;
					end
					else begin
						n_state = READ;
					end
				end
				else if(L2_write)begin
					if(hit)begin
						n_state = IDLE;
						n_cache2[block_num] = (which_cache)?{cache2[block_num][307:154],2'b11, L2_addr[27:4], L2_wdata}:{2'b11, L2_addr[27:4], L2_wdata,cache2[153:0]};
						L2_ready = 1;
					end
					else if(writeread)begin
						n_state = WRITEBACK_W;
					end
					else begin
						n_state = WRITE;
					end
				end
			end
			READ:begin
				if(mem_ready)begin
					L2_rdata = mem_rdata;
					n_cache2[block_num] = (which_cache)?{cache2[block_num][307:154],2'b10,L2_addr[27:4],mem_rdata}:{2'b10,L2_addr[27:4],mem_rdata,cache2[block_num][153:0]};
					n_previous_used[block_num] = ~which_cache;
					mem_read = 0;
					L2_ready = 1;
					n_state = IDLE;
				end
				else begin
					mem_read = 1;
					n_state = READ;
				end
			end
			WRITE:begin
				if(mem_ready)begin
					n_cache2[block_num] = (which_cache)?{cache2[block_num][307:154],2'b10,L2_addr[27:4],mem_rdata}:{2'b10,L2_addr[27:4],mem_rdata,cache2[block_num][153:0]};
					n_previous_used[block_num] = ~which_cache;
					mem_read = 0;
					L2_ready = 1;
					n_state = IDLE;
				end
				else begin
					mem_read = 1;
					n_state = WRITE;
				end
			end
			WRITEBACK_R:begin
				if(mem_ready)begin
					mem_write = 0;
					n_state = READ;
				end
				else begin
					mem_addr = {block[151:128],block_num};
					mem_write = 1;
					n_state = WRITEBACK_R;
				end
			end
			WRITEBACK_W:begin
				if(mem_ready)begin
					mem_write = 0;
					n_state = WRITE;
				end
				else begin
					mem_addr = {block_num[151:128],block_num};
					mem_write = 1;
					n_state = WRITEBACK_W;
				end
			end
			default : n_state = IDLE;
		endcase
	end
//====sequential part=======================================
always @(posedge clk) begin
		for(i=0;i<16;i=i+1)begin
			cache2[i] <= n_cache2[i];
			previous_used[i] <= n_previous_used[i];
		end
		state<=n_state;
	end	


endmodule