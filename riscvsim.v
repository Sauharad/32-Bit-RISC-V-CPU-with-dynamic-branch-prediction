`timescale 1ns / 1ps

/* This tesbench inserts instructions into the CPU's main memory
   
   The instructions have been chosen to ensure that the functioning of all the module within the design i.e. the pipeline operation,
   the cache, the branch prediction unit, the hazard units all get tested.
   
*/

module riscvsim;
reg clk,start;

riscv32 DUT(.clk(clk),.start(start));

wire [31:0] regfile [0:31] = DUT.riscv_datapath.reg_file;

wire [31:0] PC = DUT.riscv_datapath.PC;
wire [31:0] PPC = DUT.riscv_datapath.PPC;

wire [7:0] Inst_Mem [0:255] = DUT.riscv_instmem.Inst_Mem;
wire imem_read = DUT.imem_read;
wire imem_valid = DUT.imem_valid;

wire [0:23] ICache_VTP [0:63] [0:3] = DUT.riscv_icache.ICache_VTP;
wire [0:31] ICache_Data [0:63] [0:3] [0:7] = DUT.riscv_icache.ICache_Data;

wire icache_read = DUT.datapath_to_icache_read;
wire icache_read_again = DUT.icache_read_again;
wire cache_hit = DUT.icache_hit;
wire [31:0] cache_fetch = DUT.icache_fetch;
wire icache_updated = DUT.icache_update_occured;

wire [1:0] bht [0:31] = DUT.riscv_datapath.riscv_bht.BHTable;
wire [0:50] btb [0:31] [0:3] = DUT.riscv_datapath.riscv_btb.BTBuffer;

wire bht_hit = DUT.riscv_datapath.bht_hit;
wire btb_hit = DUT.riscv_datapath.btb_hit;
wire branch_pred = DUT.riscv_datapath.branch_pred;


wire [6:0] opcode = DUT.riscv_datapath.opcode;
wire [6:0] funct7 = DUT.riscv_datapath.funct7;
wire [6:0] funct3 = DUT.riscv_datapath.funct3;


wire regwrite = DUT.riscv_datapath.RegWrite;
wire memtoreg = DUT.riscv_datapath.MemToReg;
wire memread = DUT.riscv_datapath.MemRead;
wire memwrite = DUT.riscv_datapath.MemWrite;
wire alusrc = DUT.riscv_datapath.ALUSrc;
wire isstall = DUT.riscv_datapath.IsStall;
wire load_stall = DUT.riscv_datapath.load_stall;
wire [1:0] br_stall = DUT.riscv_datapath.br_stall;
wire [1:0] br_stall_prev = DUT.riscv_datapath.br_stall_prev;
wire [4:0] aluop = DUT.riscv_datapath.ALUOp;
wire pcsrccont = DUT.riscv_datapath.PCSrcCont;



wire [31:0] IF_ID_IR = DUT.riscv_datapath.IF_ID_IR;
wire [31:0] IF_ID_PC = DUT.riscv_datapath.IF_ID_PC;
wire IF_ID_branch_pred = DUT.riscv_datapath.IF_ID_branch_pred;
wire [4:0] IF_ID_rs1_loc = DUT.riscv_datapath.IF_ID_rs1_loc;
wire [4:0] IF_ID_rs2_loc = DUT.riscv_datapath.IF_ID_rs2_loc;
wire [4:0] IF_ID_rd_loc = DUT.riscv_datapath.IF_ID_rd_loc;
wire bht_update = DUT.riscv_datapath.bht_update;
wire bht_update_dir = DUT.riscv_datapath.bht_update_dir;
wire btb_update = DUT.riscv_datapath.btb_update;
wire [31:0] bpu_up_to = DUT.riscv_datapath.bpu_up_to;


wire [31:0] ID_BR_PC = DUT.riscv_datapath.ID_BR_PC;
wire ID_PCSrc = DUT.riscv_datapath.ID_PCSrc;

wire [31:0] BR_A = DUT.riscv_datapath.BR_A;
wire [31:0] BR_B = DUT.riscv_datapath.BR_B;
wire BR_Test = DUT.riscv_datapath.BR_Test;

wire [31:0] imm_gen_out = DUT.riscv_datapath.imm_gen_out;



wire [31:0] ID_EX_IR = DUT.riscv_datapath.ID_EX_IR;
wire [31:0] ID_EX_PC = DUT.riscv_datapath.ID_EX_PC;
wire [6:0] ID_EX_opcode = DUT.riscv_datapath.ID_EX_opcode;
wire [31:0] ID_EX_rs1 = DUT.riscv_datapath.ID_EX_rs1;
wire [31:0] ID_EX_rs2 = DUT.riscv_datapath.ID_EX_rs2;
wire [4:0] ID_EX_rs1_loc = DUT.riscv_datapath.ID_EX_rs1_loc;
wire [4:0] ID_EX_rs2_loc = DUT.riscv_datapath.ID_EX_rs2_loc;
wire [4:0] ID_EX_rd_loc = DUT.riscv_datapath.ID_EX_rd_loc;
wire [31:0] ID_EX_Imm = DUT.riscv_datapath.ID_EX_Imm;
wire ID_EX_RegWrite = DUT.riscv_datapath.ID_EX_RegWrite;
wire ID_EX_MemWrite = DUT.riscv_datapath.ID_EX_MemWrite;
wire ID_EX_MemRead = DUT.riscv_datapath.ID_EX_MemRead;
wire ID_EX_MemToReg = DUT.riscv_datapath.ID_EX_MemToReg;
wire ID_EX_ALUSrc = DUT.riscv_datapath.ID_EX_ALUSrc;
wire [4:0] ID_EX_ALUOp = DUT.riscv_datapath.ID_EX_ALUOp;
wire ID_EX_PCSrcCont = DUT.riscv_datapath.ID_EX_PCSrcCont;

wire [1:0] forwardA = DUT.riscv_datapath.ALU_Forward.forwardA;
wire [1:0] forwardB = DUT.riscv_datapath.ALU_Forward.forwardB;
wire [31:0] ALU_A = DUT.riscv_datapath.ALU_A;
wire [31:0] ALU_B = DUT.riscv_datapath.ALU_B;
wire [31:0] ALU_OUT = DUT.riscv_datapath.ex_mem_aluout;

wire [31:0] EX_MEM_IR = DUT.riscv_datapath.EX_MEM_IR;
wire [31:0] EX_MEM_ALUOut = DUT.riscv_datapath.EX_MEM_ALUOut;
wire [31:0] EX_MEM_rs2 = DUT.riscv_datapath.EX_MEM_rs2;
wire [4:0] EX_MEM_rs1_loc = DUT.riscv_datapath.EX_MEM_rs1_loc;
wire [4:0] EX_MEM_rs2_loc = DUT.riscv_datapath.EX_MEM_rs2_loc;
wire [4:0] EX_MEM_rd_loc = DUT.riscv_datapath.EX_MEM_rd_loc;
wire [31:0] EX_MEM_PC = DUT.riscv_datapath.EX_MEM_PC;
wire EX_MEM_RegWrite = DUT.riscv_datapath.EX_MEM_RegWrite;
wire EX_MEM_MemWrite = DUT.riscv_datapath.EX_MEM_MemWrite;
wire EX_MEM_MemRead = DUT.riscv_datapath.EX_MEM_MemRead;
wire EX_MEM_MemToReg = DUT.riscv_datapath.EX_MEM_MemToReg;
wire EX_MEM_PCSrcCont = DUT.riscv_datapath.EX_MEM_PCSrcCont;
wire [31:0] rs2_forw = DUT.riscv_datapath.rs2_forw;

wire [31:0] MEM_WB_IR = DUT.riscv_datapath.MEM_WB_IR;
wire [31:0] MEM_WB_ALUOut = DUT.riscv_datapath.MEM_WB_ALUOut;
wire [31:0] MEM_WB_ReadData = DUT.riscv_datapath.MEM_WB_ReadData;
wire [4:0] MEM_WB_rs1_loc = DUT.riscv_datapath.MEM_WB_rs1_loc;
wire [4:0] MEM_WB_rs2_loc = DUT.riscv_datapath.MEM_WB_rs2_loc;
wire [4:0] MEM_WB_rd_loc = DUT.riscv_datapath.MEM_WB_rd_loc;
wire MEM_WB_RegWrite = DUT.riscv_datapath.MEM_WB_RegWrite;
wire MEM_WB_MemToReg = DUT.riscv_datapath.MEM_WB_MemToReg;


initial
begin
    #10 clk = 1'b0;
    forever #1 clk = ~clk;
end

initial
begin
    DUT.riscv_instmem.Inst_Mem[0] = 8'h00;  // add x2,x1,x0
    DUT.riscv_instmem.Inst_Mem[1] = 8'h10;
    DUT.riscv_instmem.Inst_Mem[2] = 8'h01;
    DUT.riscv_instmem.Inst_Mem[3] = 8'h33;
    
    
    DUT.riscv_instmem.Inst_Mem[4] = 8'h40; //sub x3 x2 x1
    DUT.riscv_instmem.Inst_Mem[5] = 8'h20;
    DUT.riscv_instmem.Inst_Mem[6] = 8'h81;
    DUT.riscv_instmem.Inst_Mem[7] = 8'hB3;
    
    DUT.riscv_instmem.Inst_Mem[8] = 8'h00; //and x4 x2 x1
    DUT.riscv_instmem.Inst_Mem[9] = 8'h20;
    DUT.riscv_instmem.Inst_Mem[10] = 8'hF2;
    DUT.riscv_instmem.Inst_Mem[11] = 8'h33;
    
    DUT.riscv_instmem.Inst_Mem[12] = 8'h02; //jal to PC=76, link to x4
    DUT.riscv_instmem.Inst_Mem[13] = 8'h00;
    DUT.riscv_instmem.Inst_Mem[14] = 8'h02;
    DUT.riscv_instmem.Inst_Mem[15] = 8'h6F;
    
    DUT.riscv_instmem.Inst_Mem[16] = 8'h00; //will not be executed if execution is correct and jal works properly
    DUT.riscv_instmem.Inst_Mem[17] = 8'h10;
    DUT.riscv_instmem.Inst_Mem[18] = 8'h02;
    DUT.riscv_instmem.Inst_Mem[19] = 8'hB3;
    
    DUT.riscv_instmem.Inst_Mem[76] = 8'h00; //lw x6, x4(0)
    DUT.riscv_instmem.Inst_Mem[77] = 8'h02;
    DUT.riscv_instmem.Inst_Mem[78] = 8'h23;
    DUT.riscv_instmem.Inst_Mem[79] = 8'h03;
    
    DUT.riscv_instmem.Inst_Mem[80] = 8'h82; // beq x10,x9 to PC=0
    DUT.riscv_instmem.Inst_Mem[81] = 8'hA4;
    DUT.riscv_instmem.Inst_Mem[82] = 8'h84;
    DUT.riscv_instmem.Inst_Mem[83] = 8'h63;
    
    DUT.riscv_datapath.reg_file[0] = 32'h00000000;
    DUT.riscv_datapath.reg_file[1] = 32'h00000004;
    DUT.riscv_datapath.reg_file[9] = 32'h0000000F;
    DUT.riscv_datapath.reg_file[10] = 32'h0000000F;
    
    DUT.riscv_datapath.Data_Mem[16] = 32'h00000010;    
    
    #5.5 start = 1;
    #100 DUT.riscv_datapath.reg_file[10] = 32'h0000000C;
    #200 $finish;
end
endmodule
