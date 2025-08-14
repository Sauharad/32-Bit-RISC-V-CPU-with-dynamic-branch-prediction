`timescale 1ns / 1ps

/*Top level module connecting the control unit and the processor datapath

The datapath contains the 5 stage processor pipeline (IF,ID,EX,MEM,WB), hazard detection and forwarding units, and branch prediction unit

The control unit sends control signals for instruction execution after instruction has been fetched and is being decoded
It is also responsible for sending update signals to the branch prediction unit


*/

module riscv32(input wire clk,
               input wire start);

wire [31:0] PC; 
             
wire [6:0] opcode, funct7; wire [2:0] funct3;

wire [4:0] ALUOp, if_id_rdloc;

wire ALUSrc,MemToReg,RegWrite,MemRead,MemWrite,PCSrcCont, load_stall, IsStall;
wire [1:0] br_stall, br_stall_prev;
wire branch_flag, prediction_false_flag;

wire IF_ID_branch_pred,ID_PCSrc; 
              
wire bht_update,btb_update,bht_update_dir;
               
controlpath riscv_controlpath(.start(start),.clk(clk),
                              .opcode(opcode),.funct7(funct7),.funct3(funct3),
                              .if_id_rdloc(if_id_rdloc),.ALUOp(ALUOp),.ALUSrc(ALUSrc),
                              .MemWrite(MemWrite),.MemRead(MemRead),
                              .MemToReg(MemToReg),.RegWrite(RegWrite),
                              .PCSrcCont(PCSrcCont),.load_stall(load_stall),
                              .br_stall(br_stall),.br_stall_prev(br_stall_prev),
                              .IsStall(IsStall),.branch_flag(branch_flag),.prediction_false_flag(prediction_false_flag),
                              .IF_ID_branch_pred(IF_ID_branch_pred),.ID_PCSrc(ID_PCSrc),
                              .bht_update(bht_update),.btb_update(btb_update),.bht_update_dir(bht_update_dir));               

               
datapath riscv_datapath(.start(start),.clk(clk),.PC(PC),
                        .ALUSrc(ALUSrc),.ALUOp(ALUOp),
                        .PCSrcCont(PCSrcCont),.MemRead(MemRead),
                        .MemWrite(MemWrite),.MemToReg(MemToReg),
                        .RegWrite(RegWrite),
                        .bht_update(bht_update),.btb_update(btb_update),.bht_update_dir(bht_update_dir),
                        .opcode(opcode),.funct7(funct7),.funct3(funct3),.IF_ID_rd_loc(if_id_rdloc),
                        .load_stall(load_stall), .br_stall(br_stall),.br_stall_prev(br_stall_prev),
                        .IsStall(IsStall),.branch_flag(branch_flag),.prediction_false_flag(prediction_false_flag),
                        .IF_ID_branch_pred(IF_ID_branch_pred),.ID_PCSrc(ID_PCSrc));
endmodule
