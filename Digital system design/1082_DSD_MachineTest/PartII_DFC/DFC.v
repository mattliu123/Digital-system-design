module DFC(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [1:0]   cmd;
input           cmd_valid;
output  [8:0]   dataout;
output          output_valid;
output          busy;

parameter IDLE      = 3'd0;
parameter LOAD_DATA = 3'd1;
parameter FIFO      = 3'd2;
parameter LIFO      = 3'd3;
parameter OUT       = 3'd4;

reg busy,output_valid;
reg [8:0] dataout;
reg [7:0] data_buf [0:7];
reg [7:0] nxt_data_buf [0:7];
reg [2:0] state, nxt_state;
reg [2:0] nxt_count, count;

wire [8:0] out1, out2, out3, out0;

integer i;

ALU A0	(.out(out0), .mode(1'b1), .in_a(data_buf[0]), .in_b(data_buf[4]));       
ALU A1	(.out(out1), .mode(1'b1), .in_a(data_buf[1]), .in_b(data_buf[5]));       
ALU A2	(.out(out2), .mode(1'b1), .in_a(data_buf[2]), .in_b(data_buf[6]));       
ALU A3	(.out(out3), .mode(1'b1), .in_a(data_buf[3]), .in_b(data_buf[7]));       



//========= FSM =================
always @(posedge clk or posedge reset) begin  
	if (reset) state <= IDLE;
	else state <= nxt_state;
end

always@(*) begin  
	case (state)
        IDLE: begin
        	nxt_count = count;
        	if((cmd_valid)&&(~busy)&&(cmd==2'd0))begin
        		nxt_state = LOAD_DATA;
        	end
        	else if((cmd_valid)&&(~busy)&&(cmd==2'd1))begin
        		nxt_state = FIFO;
        	end
        	else if((cmd_valid)&&(~busy)&&(cmd==2'd2))begin
        		nxt_state = LIFO;
        	end
        	else begin
        		nxt_state = IDLE;
        	end
        end
        LOAD_DATA: begin
        	if(count != 3'd7)begin
        		nxt_state = LOAD_DATA;
        		nxt_count = count+1;
        	end
        	else begin
        		nxt_state = IDLE;
        		nxt_count = 3'd0;
        	end 
        end
        FIFO: begin
        	if(count!=3'd3)begin
        		nxt_state = FIFO;
        		nxt_count = count+1;
        	end
        	else begin
        		nxt_state = IDLE;
        		nxt_count = 3'd0;
        	end
        end
        LIFO: begin
        	if(count!=3'd3)begin
        		nxt_state = LIFO;
        		nxt_count = count+1;
        	end
        	else begin
        		nxt_state = IDLE;
        		nxt_count = 3'd0;
        	end
        end
        /*OUT: begin
            if(cmd==2'd1)begin
            	nxt_count = count;
            	nxt_state = FIFO;
            end
            if(cmd==2'd2)begin
            	nxt_count = count;
            	nxt_state = LIFO;
            end
            else begin
            	nxt_count = count;
            	nxt_state = IDLE;
            end
        end*/
        default: begin
        	nxt_count = count;
        	nxt_state = IDLE;
        end
	endcase
end

//============== Combinational =================
always@(*)begin
    if(state==LOAD_DATA)begin
        for(i=0; i<8; i=i+1)begin
            nxt_data_buf[i] = data_buf[i];
        end
        case (count)        
            3'd0:nxt_data_buf[count] = datain;
            3'd1:nxt_data_buf[count] = datain;
            3'd2:nxt_data_buf[count] = datain;
            3'd3:nxt_data_buf[count] = datain;
            3'd4:nxt_data_buf[count] = datain;
            3'd5:nxt_data_buf[count] = datain;
            3'd6:nxt_data_buf[count] = datain;
            3'd7:nxt_data_buf[count] = datain;        
        endcase
    end
    else begin
        for(i=0; i<8; i=i+1)begin
            nxt_data_buf[i] = data_buf[i];
        end
    end
end
// dataout, output_valid
always @(*) begin  
	if ((state==FIFO)||(state==LIFO)) begin
		output_valid = 1'b1;
		if(state==FIFO)begin
			case (count)
				3'd0: dataout = out0;
				3'd1: dataout = out1;
				3'd2: dataout = out2;
				3'd3: dataout = out3;
			
				default : dataout = 9'd0;
			endcase
		end
		else begin
			case (count)
				3'd0: dataout = out3;
				3'd1: dataout = out2;
				3'd2: dataout = out1;
				3'd3: dataout = out0;
			
				default : dataout = 9'd0;
			endcase
		end
	end
	else begin
		output_valid = 1'b0;
		dataout = 9'd0;
	end
end

//busy
always @(*) begin		
	if (state==IDLE)
		busy = 1'b0;
	else
		busy = 1'b1;
end
				
//=============== Sequential =================
always @(posedge clk or posedge reset) begin  
	if (reset) begin
		for(i=0;i<8;i=i+1)
			data_buf[i] <= 8'd0;
		count <= 3'd0;
	end
	else begin
		for(i=0;i<8;i=i+1)
			data_buf[i] <= nxt_data_buf[i];
		count <= nxt_count;
	end
end

endmodule
