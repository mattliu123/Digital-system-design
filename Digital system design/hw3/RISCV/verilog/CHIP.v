// Your SingleCycle RISC-V code

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
    output reg [31:0]  mem_addr_I ;  // the fetching address of next instruction
    input  [31:0] mem_rdata_I;  // instruction reading from I-mem

    integer i;
    wire [31:0] inst, bimm, jimm, mem_rdata, iimm;
    wire [6:0] opcode, funct7;
    wire [4:0] rs1, rs2, rd, write_i;
    wire [2:0] funct3;
    wire signed [15:0] address;
    wire signed [31:0] readdata1, readdata2, address_ex, address_exs;
    wire jumpRS;
    reg branch, Mem2Reg, ALUSrc, RegWrite, storeRA, zero, jal, jalr;
    reg [3:0] ALUctrl;
    reg signed [31:0] ALUin, ALUout;
    reg signed [31:0] register [31:0];
    reg signed [31:0] n_register [31:0];
    reg [31:0] PC_in, branch_addr, jump_addr, addr_I_4;
    reg mem_wen_D;
    
    assign inst = {mem_rdata_I[7:0],mem_rdata_I[15:8],mem_rdata_I[23:16],mem_rdata_I[31:24]};
    assign mem_rdata = {mem_rdata_D[7:0],mem_rdata_D[15:8],mem_rdata_D[23:16],mem_rdata_D[31:24]};
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign rd = inst[11:7];
    assign opcode = inst[6:0];
    assign funct7 = inst[31:25];
    assign funct3 = inst[14:12];
    assign bimm = {inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
    assign jimm = (inst[31])?{12'b1111_1111_1111, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0}:{12'b0000_0000_0000, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0};
    assign iimm = {20'd0,inst[31:20]};

    always@(*) begin //Control
        case(opcode)
            7'b0110011:begin //add sub and or slt
                jal = 0;
                jalr = 0;
                storeRA = 0;
                branch = 0;
                Mem2Reg = 0;
                ALUSrc = 0;
                mem_wen_D = 0;
                RegWrite = 1;
            end 
            7'b1100011:begin //beq
                jal = 0;
                jalr = 0;
                storeRA = 0;
                branch = 1;
                Mem2Reg = 0;
                ALUSrc = 0;
                RegWrite = 0;
                mem_wen_D = 0;
            end
            7'b0000011:begin //lw
                jal = 0;
                jalr = 0;
                storeRA = 0;
                branch = 0;
                Mem2Reg = 1;
                ALUSrc = 1;
                RegWrite = 1;
                mem_wen_D = 0;
            end
            7'b0100011:begin //sw
                jal = 0;
                jalr = 0;
                storeRA = 0;
                branch = 0;
                Mem2Reg = 0;
                ALUSrc = 1;
                RegWrite = 0;
                mem_wen_D = 1;
            end
            7'b1101111:begin //jal
                jal = 1;
                jalr = 0;
                storeRA = 1;
                branch = 0;
                Mem2Reg = 0;
                ALUSrc = 0;
                RegWrite = 0;
                mem_wen_D = 0;
            end
            7'b1100111:begin //jalr
                jal = 0;
                jalr = 1;
                storeRA = 1;
                branch = 0;
                Mem2Reg = 0;
                ALUSrc = 0;
                RegWrite = 0;
                mem_wen_D = 0;
            end
            default:begin
                jal = 1'bx;
                jalr = 1'bx;
                storeRA = 1'bx;
                branch = 1'bx;
                Mem2Reg = 1'bx;
                ALUSrc = 1'bx;
                RegWrite = 1'bx;
                mem_wen_D = 1'bx;
            end
        endcase
    end

    always@(*) begin//ALUctrl
        ALUctrl[0] = opcode[4]&funct3[2]&funct3[1]&(!funct3[0]);
        ALUctrl[1] = !(opcode[4]&(!opcode[3])&funct3[1]);
        ALUctrl[2] = ((!opcode[4])&(!funct3[1]))|(funct7[5]&opcode[4]);
        ALUctrl[3] = opcode[4]&(!funct3[2])&funct3[1];
    end
    assign readdata1 = register[rs1];
    assign readdata2 = register[rs2];
    always@(*)begin
        ALUin = (mem_wen_D)?{iimm[31:5],rd}:((ALUSrc)?iimm:readdata2);
        case(ALUctrl)
            4'b0000:begin
                zero=0;
                ALUout = readdata1&ALUin;
            end
            4'b0001:begin
                zero=0;
                ALUout = readdata1|ALUin;
            end
            4'b0010:begin
                zero=0;
                ALUout = readdata1+ALUin;
            end
            4'b0110:begin
                zero=(readdata1==ALUin)?1:0;
                ALUout = readdata1-ALUin;
            end
            4'b1000:begin
                zero=0;
                ALUout = (readdata1<ALUin)?1:0;
            end
            default:begin
                zero = 1'bx;
                ALUout = 32'bx;
            end
        endcase
    end
    assign mem_wdata_D = {readdata2[7:0],readdata2[15:8],readdata2[23:16],readdata2[31:24]};
    assign mem_addr_D = ALUout;
    always@(*)begin
        for(i=0;i<31;i=i+1)begin
            if((i==rd)&&(RegWrite==1))begin
                n_register[i] = (Mem2Reg)?mem_rdata:ALUout;
            end
            else if(i==rd&&storeRA==1)begin
            	n_register[i] = addr_I_4;
            end
            else begin
                n_register[i] = register[i];
            end
        end
    end
     always@(*)begin //PC
        addr_I_4 = mem_addr_I + 4;
        jump_addr = mem_addr_I+jimm;
        branch_addr = mem_addr_I+bimm;
        PC_in = (jalr)?(register[rs1]+iimm):((jal)?jump_addr:((branch&&zero)?branch_addr:addr_I_4));
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