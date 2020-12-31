// Your SingleCycle MIPS code

module CHIP(clk,
            rst_n,
            // for mem_D
            mem_wen_D,
            mem_addr_D,
            mem_wdata_D,
            mem_rdata_D,
            // for mem_I
            mem_addr_I,
            mem_rdata_I
    );

    input         clk, rst_n ;
    // for mem_D
    output        mem_wen_D  ;  // mem_wen_D is high, CHIP writes data to D-mem; else, CHIP reads data from D-mem
    output [31:0] mem_addr_D ;  // the specific address to fetch/store data 
    output [31:0] mem_wdata_D;  // data writing to D-mem 
    input  [31:0] mem_rdata_D;  // data reading from D-mem
    // for mem_I
    output reg [31:0] mem_addr_I ;  // the fetching address of next instruction
    input  [31:0] mem_rdata_I;  // instruction reading from I-mem


    integer i;
    wire [5:0] opcode, funct;
    wire [4:0] rs, rt, rd, shamt, write_i;
    wire signed [15:0] address;
    wire signed [31:0] readdata1, readdata2, address_ex, address_exs;
    wire jumpRS;
    reg RegDst, jump, branch, Mem2Reg, ALUSrc, RegWrite, storeRA, zero;
    reg [1:0] ALUop;
    reg [3:0] ALUctrl;
    reg signed [31:0] ALUin, ALUout;
    reg signed [31:0] register [31:0];
    reg signed [31:0] n_register [31:0];
    reg [31:0] PC_in, branch_addr, jump_addr, addr_I_4;
    reg mem_wen_D;
    

    assign opcode = mem_rdata_I[31:26];
    assign rs = mem_rdata_I[25:21];
    assign rt = mem_rdata_I[20:16];
    assign rd = mem_rdata_I[15:11];
    assign shamt = mem_rdata_I[10:6];
    assign funct = mem_rdata_I[5:0];
    assign address = mem_rdata_I[15:0];
    assign address_ex = (address[15])?{16'b1111_1111_1111_1111,address}:{16'b0000_0000_0000_0000,address};
    assign address_exs = address_ex<<2;
    assign jumpRS = ((opcode==6'd0)&&(funct==6'd8))?1:0;

    always@(*) begin //Control
    	case(opcode)
    		6'b000000:begin //add sub and or slt
    			ALUop = 2'b10;
    			RegDst = 1;
    			jump = 0;
                storeRA = 0;
                branch = 0;
                Mem2Reg = 0;
                ALUSrc = 0;
                mem_wen_D = 0;
                RegWrite = (funct==6'd8)?0:1;
    		end	
            6'b000100:begin //beq
                ALUop = 2'b01;
                RegDst = 0;
                jump = 0;
                storeRA = 0;
                branch = 1;
                Mem2Reg = 0;
                ALUSrc = 0;
                RegWrite = 0;
                mem_wen_D = 0;
            end
            6'b100011:begin //lw
                ALUop = 2'b00;
                RegDst = 0;
                jump = 0;
                storeRA = 0;
                branch = 0;
                Mem2Reg = 1;
                ALUSrc = 1;
                RegWrite = 1;
                mem_wen_D = 0;
            end
            6'b101011:begin //sw
                ALUop = 2'b00;
                RegDst = 0;
                jump = 0;
                storeRA = 0;
                branch = 0;
                Mem2Reg = 0;
                ALUSrc = 1;
                RegWrite = 0;
                mem_wen_D = 1;
            end
            6'b000010:begin //j
                ALUop = 2'b00;
                RegDst = 0;
                jump = 1;
                storeRA = 0;
                branch = 0;
                Mem2Reg = 0;
                ALUSrc = 0;
                RegWrite = 0;
                mem_wen_D = 0;
            end
            6'b000011:begin //jal
                ALUop = 2'b00;
                RegDst = 0;
                jump = 1;
                storeRA = 1;
                branch = 0;
                Mem2Reg = 0;
                ALUSrc = 0;
                RegWrite = 0;
                mem_wen_D = 0;
            end
            default:begin
                ALUop = 2'bxx;
                RegDst = 1'bx;
                jump = 1'bx;
                storeRA = 1'bx;
                branch = 1'bx;
                Mem2Reg = 1'bx;
                ALUSrc = 1'bx;
                RegWrite = 1'bx;
                mem_wen_D = 1'bx;
            end
    	endcase
    end

    always@(*) begin //ALU control
        case (ALUop)
            2'b00: begin //lw sw
                ALUctrl = 4'b0010;
            end
            2'b01: begin //beq
                ALUctrl = 4'b0110;
            end
            2'b10: begin
                case(funct)
                    6'b100000: ALUctrl = 4'b0010;
                    6'b100010: ALUctrl = 4'b0110;
                    6'b100100: ALUctrl = 4'b0000;
                    6'b100101: ALUctrl = 4'b0001;
                    6'b101010: ALUctrl = 4'b0111;
                    default: ALUctrl = 4'bxxxx;
                endcase
            end
            default : ALUctrl = 4'bxxxx;
        endcase
    end
    assign readdata1 = register[rs];
    assign readdata2 = register[rt];
    assign write_i = (RegDst)?rd:rt;
    always@(*)begin
        ALUin = (ALUSrc)?address_ex:readdata2;
        case(ALUctrl)
            4'b0010:begin //add
                zero = 0;
                ALUout = readdata1 + ALUin;
            end
            4'b0110:begin //sub
            	zero = (readdata1==ALUin)?1:0;
            	ALUout = readdata1 - ALUin;
            end
            4'b0000:begin //and
        		zero = 0;
        		ALUout = readdata1&ALUin;
        	end
        	4'b0001:begin //or
        		zero = 0;
        		ALUout = readdata1|ALUin;
        	end
        	4'b0111:begin //slt
        		zero = 0;
                ALUout = (readdata1<ALUin)?1:0;
            end
            default:begin
                zero = 1'bx;
                ALUout = 32'bx;
            end
        endcase  
    end
    assign mem_wdata_D = readdata2;
    assign mem_addr_D = ALUout;
    always@(*)begin
    	for(i=0;i<31;i=i+1)begin
            if((i==write_i)&&(RegWrite==1))begin
                n_register[i] = (Mem2Reg)?mem_rdata_D:ALUout;
            end
            else begin
                n_register[i] = register[i];
            end
        end
    end
    always@(*)begin //PC
    	addr_I_4 = mem_addr_I + 4;
        n_register[31] = (storeRA)?addr_I_4:register[31];
    	jump_addr = {addr_I_4[31:28],mem_rdata_I[25:0],2'b00};
    	branch_addr = address_exs+addr_I_4;
    	PC_in = (jumpRS)?register[rs]:((jump)?jump_addr:((branch&&zero)?branch_addr:addr_I_4));
    end
    always@(posedge clk)begin
    	if(rst_n==0)begin
    		for (i = 1; i < 32; i=i+1) begin
    			register[i] <= 0;
    		end
    		mem_addr_I <= 0;
            register[0] <= 0;
    	end
    	else begin
    		for (i = 1; i < 32; i=i+1) begin
    			register[i] <= n_register[i];
    		end
    		mem_addr_I <= PC_in;
    		register[0] <= 0;
    	end
    end
endmodule