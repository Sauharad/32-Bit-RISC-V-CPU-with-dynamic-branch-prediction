`timescale 1ns / 1ps

/* The datapath contains the execution pipeline consisting of 
   Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Read/Write (MEM) and Register Writeback (WB) stages.
   
   Data is passed between stages through the IF_ID, ID_EX, EX_MEM and MEM_WB pipeline registers.
   
   The branch history table and branch target buffer provide dynamic branch prediction.
   
   Data forwarding units forward data from later pipeline stages to earlier ones to remove most data hazards.
   
   Hazard detection unit detects hazards related to memory read operations and branches.
   
   
   
*/

module datapath(input wire start,
                input wire clk,
                input wire [31:0] icache_fetch,
                input wire icache_read_again,
                input wire ALUSrc,
                input wire [4:0] ALUOp,
                input wire PCSrcCont,
                input wire MemWrite,
                input wire MemRead,
                input wire MemToReg,
                input wire RegWrite,
                input wire IsStall,
                input wire bht_update,
                input wire btb_update,
                input wire bht_update_dir,
                output reg [31:0] PC,
                output reg send_cache_read,
                output wire [6:0] opcode,
                output wire [2:0] funct3,
                output wire [6:0] funct7,
                output wire [4:0] IF_ID_rd_loc,
                output wire load_stall,
                output wire [1:0] br_stall,
                output reg branch_flag,
                output reg prediction_false_flag,
                output reg [1:0] br_stall_prev,
                output reg IF_ID_branch_pred,
                output wire ID_PCSrc);

localparam [6:0] OP_REG = 7'b0110011,OP_LW = 7'b0000011,OP_SW = 7'b0100011,OP_B = 7'b1100011, OP_JAL = 7'b1101111;


wire [31:0] PPC;
reg [31:0] Data_Mem [0:16383];
reg [31:0] reg_file [0:31];

wire bht_hit,btb_hit,branch_pred;
reg [31:0] bpu_up_to,bpu_up_target;

reg [31:0] IF_ID_IR, IF_ID_PC;
wire [31:0] ID_BR_PC;
wire [4:0] IF_ID_rs1_loc, IF_ID_rs2_loc;
wire [31:0] IF_ID_rs1, IF_ID_rs2;


reg [31:0] ID_EX_IR, ID_EX_PC, ID_EX_rs1, ID_EX_rs2, ID_EX_Imm;
reg [4:0] ID_EX_rs1_loc,ID_EX_rs2_loc,ID_EX_rd_loc;
reg [6:0] ID_EX_opcode;
reg ID_EX_RegWrite,ID_EX_ALUSrc,ID_EX_MemWrite,ID_EX_MemRead,ID_EX_PCSrcCont,ID_EX_MemToReg;
reg [4:0] ID_EX_ALUOp;

wire signed [31:0] imm_gen_out;
wire [31:0] ALU_A,ALU_B,rs2_forw;
wire [31:0] BR_A,BR_B,BR_verify_A,BR_verify_B;
wire BR_Test,BR_verify_test;


reg [31:0] EX_MEM_IR,EX_MEM_PC,EX_MEM_ALUOut,EX_MEM_rs2; wire [31:0] ex_mem_aluout;
reg [4:0] EX_MEM_rs1_loc,EX_MEM_rs2_loc,EX_MEM_rd_loc;
reg EX_MEM_MemWrite,EX_MEM_MemRead,EX_MEM_RegWrite,EX_MEM_MemToReg,EX_MEM_PCSrcCont; 


reg [31:0] MEM_WB_IR,MEM_WB_ReadData,MEM_WB_ALUOut;
reg [4:0] MEM_WB_rs1_loc,MEM_WB_rs2_loc,MEM_WB_rd_loc;
reg MEM_WB_RegWrite,MEM_WB_MemToReg;

Imm_Gen riscv_immgen(.if_id_ir(IF_ID_IR),.Imm(imm_gen_out));


forwarding_unit ALU_Forward(.comp_loc_rs1(ID_EX_rs1_loc),.comp_loc_rs2(ID_EX_rs2_loc),.pc(ID_EX_PC),.opc(ID_EX_opcode),.comp_loc_exmem(EX_MEM_rd_loc),
.comp_loc_memwb(MEM_WB_rd_loc),.cont_idex_alusrc(ID_EX_ALUSrc),.cont_idex_mw(ID_EX_MemWrite),.cont_exmem_rw(EX_MEM_RegWrite),.cont_memwb_rw(MEM_WB_RegWrite),
.cont_memwb_mtr(MEM_WB_MemToReg),.memwb_readdata(MEM_WB_ReadData),.memwb_aluout(MEM_WB_ALUOut),.exmem_aluout(EX_MEM_ALUOut),
.forw_rs1(ID_EX_rs1),.forw_rs2(ID_EX_rs2),.forw_imm(ID_EX_Imm),
.out_A(ALU_A),.out_B(ALU_B),.out_rs2(rs2_forw));

/* Forwarding unit for branch checking unit does not need all the operands that the one for ALU needs or has some fixed connection, 
   so some are 0 or not connected
*/
forwarding_unit BR_Forward(.comp_loc_rs1(IF_ID_rs1_loc),.comp_loc_rs2(IF_ID_rs2_loc),.comp_loc_exmem(EX_MEM_rd_loc),.comp_loc_memwb(MEM_WB_rd_loc),
.opc(7'b0000000),
.cont_idex_alusrc(1'b0),.cont_exmem_rw(EX_MEM_RegWrite),.cont_memwb_rw(MEM_WB_RegWrite),.cont_memwb_mtr(MEM_WB_MemToReg),
.memwb_readdata(MEM_WB_ReadData),.memwb_aluout(MEM_WB_ALUOut),.exmem_aluout(EX_MEM_ALUOut),
.forw_rs1(IF_ID_rs1),.forw_rs2(IF_ID_rs2),.forw_imm(32'b0),
.out_A(BR_A),.out_B(BR_B));


BR_Test_Unit riscv_BR_test(BR_A,BR_B,BR_Test);

// ALU gets its operands from data forwarding unit. The forwarding unit provides the operands when hazards aren't there as well
ALU riscvALU(.ALUOp(ID_EX_ALUOp),.A(ALU_A),.B(ALU_B),.ALUOut(ex_mem_aluout));

//Checks for load and branch related hazards
hazard_detect riscv_hazard_detect(.idex_rdloc(ID_EX_rd_loc),
.ifid_rs1loc(IF_ID_rs1_loc),.ifid_rs2loc(IF_ID_rs2_loc),.opcode(opcode),
.idex_regwrite(ID_EX_RegWrite),.idex_memread(ID_EX_MemRead),
.load_stall(load_stall),.br_stall(br_stall));


BHT riscv_bht(.PC_lower_predict(PC[6:2]),.PC_lower_update(bpu_up_to[6:2]),.update(bht_update),
.update_direction(bht_update_dir),.start(start),.bht_hit(bht_hit));


BTB riscv_btb(.PC_predict_from(PC),.PC_update_for(bpu_up_to),.start(start),.update(btb_update),
.target_address_update(bpu_up_target),.predicted_PC(PPC),.btb_hit(btb_hit));


assign branch_pred = bht_hit && btb_hit;

assign IF_ID_rs1_loc =  IF_ID_IR[19:15];
assign IF_ID_rs2_loc = IF_ID_IR[24:20];
assign IF_ID_rd_loc = IF_ID_IR[11:7];
assign IF_ID_rs1 = reg_file[IF_ID_rs1_loc];
assign IF_ID_rs2 = reg_file[IF_ID_rs2_loc];

assign opcode = IF_ID_IR[6:0];
assign funct3 = IF_ID_IR[14:12];
assign funct7 = IF_ID_IR[31:25];


assign ID_PCSrc = PCSrcCont && ((opcode == OP_JAL) || BR_Test);
assign ID_BR_PC = imm_gen_out[31] ? IF_ID_PC - imm_gen_out[11:0] : IF_ID_PC + imm_gen_out;

always @(*)
    begin
        if (start)
            begin    
                PC = 32'h00000000;
                branch_flag = 1'b0;
                prediction_false_flag = 1'b0;
            end
    end
    

always @(posedge clk)
    begin
        
        br_stall_prev <= br_stall;
        
        if (IsStall)
            begin
                PC <= PC;
                if (icache_read_again)
                    send_cache_read <= 1'b1;
                else
                    send_cache_read <= 1'b0;
            end
        if (!IsStall)
            begin
                send_cache_read <= 1'b1;
                if (ID_PCSrc)
                    begin
                        if (!IF_ID_branch_pred)
                            begin
                                PC <= ID_BR_PC;
                                branch_flag <= 1'b1;
                                prediction_false_flag <= 1'b0;
                            end
                        if (IF_ID_branch_pred)
                            begin
                                if (!branch_pred)
                                    PC <= PC + 4;
                                if (branch_pred)
                                    PC <= PPC;
                                branch_flag <= 1'b0;
                                prediction_false_flag <= 1'b0;
                            end
                    end
                if (!ID_PCSrc)
                    begin
                        if (!IF_ID_branch_pred)
                            begin
                                if (branch_pred)
                                    PC <= PPC;
                                if (!branch_pred)
                                    PC <= PC + 4;
                                branch_flag <= 1'b0;
                                prediction_false_flag <= 1'b0;
                            end
                        if (IF_ID_branch_pred)
                            begin
                                PC <= IF_ID_PC + 4;
                                prediction_false_flag <= 1'b1;
                                branch_flag <= 1'b0;
                            end
                        
                    end
            end
        
        IF_ID_branch_pred <= branch_pred;
        
        
        if (IsStall)
            begin
                IF_ID_IR <= IF_ID_IR;
                IF_ID_PC <= IF_ID_PC;
            end
        if (!IsStall)
            begin
                IF_ID_IR <= icache_fetch;
                IF_ID_PC <= PC;
            end
        
        
        if (!IsStall)
            begin
                bpu_up_to <= IF_ID_PC;
                bpu_up_target <= ID_BR_PC;
            end
        
        ID_EX_IR <=  IF_ID_IR;
        ID_EX_PC <= IF_ID_PC;
        ID_EX_opcode <= opcode;
        ID_EX_rs1 <= reg_file[IF_ID_rs1_loc];
        ID_EX_rs2 <= reg_file[IF_ID_rs2_loc];
        ID_EX_rs1_loc <= IF_ID_rs1_loc;
        ID_EX_rs2_loc <= IF_ID_rs2_loc;
        ID_EX_rd_loc <= IF_ID_rd_loc;
        ID_EX_Imm <= imm_gen_out;
        ID_EX_ALUSrc <= ALUSrc;
        ID_EX_ALUOp <= ALUOp;
        ID_EX_PCSrcCont <= PCSrcCont;
        ID_EX_MemWrite <= MemWrite;
        ID_EX_MemRead <= MemRead;
        ID_EX_RegWrite <= RegWrite;
        ID_EX_MemToReg <= MemToReg;
        
        
        EX_MEM_IR <= ID_EX_IR;
        EX_MEM_PC <= ID_EX_PC;
        EX_MEM_rs2 <= rs2_forw;
        EX_MEM_rs1_loc <= ID_EX_rs1_loc;
        EX_MEM_rs2_loc <= ID_EX_rs2_loc;
        EX_MEM_rd_loc <= ID_EX_rd_loc;
        EX_MEM_ALUOut <= ex_mem_aluout;
        EX_MEM_MemWrite <= ID_EX_MemWrite;
        EX_MEM_MemRead <= ID_EX_MemRead;
        EX_MEM_RegWrite <= ID_EX_RegWrite;
        EX_MEM_MemToReg <= ID_EX_MemToReg;
        EX_MEM_PCSrcCont <= ID_EX_PCSrcCont;
        
        
        if (EX_MEM_MemWrite)
            Data_Mem[EX_MEM_ALUOut] <= EX_MEM_rs2; 
        if (EX_MEM_MemRead)
            MEM_WB_ReadData <= Data_Mem[EX_MEM_ALUOut];
        MEM_WB_IR <= EX_MEM_IR;    
        MEM_WB_RegWrite <= EX_MEM_RegWrite;
        MEM_WB_MemToReg <= EX_MEM_MemToReg;
        MEM_WB_ALUOut <= EX_MEM_ALUOut;
        MEM_WB_rs1_loc <= EX_MEM_rs1_loc;
        MEM_WB_rs2_loc <= EX_MEM_rs2_loc;
        MEM_WB_rd_loc <= EX_MEM_rd_loc;
        
        
        if (MEM_WB_RegWrite)
            begin
                if (MEM_WB_MemToReg)
                    reg_file[MEM_WB_rd_loc] <= MEM_WB_ReadData;
                if (!MEM_WB_MemToReg)
                    reg_file[MEM_WB_rd_loc] <= MEM_WB_ALUOut;
            end
        
    end
    
endmodule
