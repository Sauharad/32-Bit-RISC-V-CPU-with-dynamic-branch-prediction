`timescale 1ns / 1ps

/*Top level module connecting the memory, cache, control unit and the processor datapath

The datapath contains the 5 stage processor pipeline (IF,ID,EX,MEM,WB), hazard detection and forwarding units, and branch prediction unit

The control unit sends control signals for instruction execution after instruction has been fetched and is being decoded
It also sends read requests to instruction memory when a cache miss occurs
It is also responsible for sending update signals to the branch prediction unit

The instruction cache is a 4-way set associative cache. 64 set with each set having 4 blocks of cache lines. 
Every blocks has 8 instruction words.
The cache follows the Least Recently Used (LRU) policy for updation in case of a conflict of indexes.

The instruction memory is written as a byte-adddresable register file which simulates a delay of 8 clock cycles on a read request

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
              
wire datapath_to_icache_read;

wire [31:0] icache_fetch;
wire imem_valid,imem_read;
wire [31:0] imem0,imem1,imem2,imem3,imem4,imem5,imem6,imem7;
wire icache_hit, icache_update_occured, icache_read_again;
wire icache_miss = !icache_hit;


wire bht_update,btb_update,bht_update_dir;

Inst_Mem riscv_instmem(.start(start),.clk(clk),.read(imem_read),.PC(PC),.instr_0(imem0),
.instr_1(imem1),.instr_2(imem2),.instr_3(imem3),.instr_4(imem4),
.instr_5(imem5),.instr_6(imem6),.instr_7(imem7),
.instr_valid(imem_valid));


I_cache riscv_icache(.start(start),.PC(PC),.read_request(datapath_to_icache_read),.update(imem_valid),
.update_cache_0(imem0),.update_cache_1(imem1),.update_cache_2(imem2),.update_cache_3(imem3),
.update_cache_4(imem4),.update_cache_5(imem5),.update_cache_6(imem6),.update_cache_7(imem7),
.read_hit(icache_hit),.instr(icache_fetch),.cache_update_occured(icache_update_occured));

               
controlpath riscv_controlpath(.start(start),.clk(clk),.cache_hit(icache_hit),.cache_update_occured(icache_update_occured),
                              .imem_read(imem_read),.icache_read_again(icache_read_again),
                              .opcode(opcode),.funct7(funct7),.funct3(funct3),
                              .if_id_rdloc(if_id_rdloc),.ALUOp(ALUOp),.ALUSrc(ALUSrc),
                              .MemWrite(MemWrite),.MemRead(MemRead),
                              .MemToReg(MemToReg),.RegWrite(RegWrite),
                              .PCSrcCont(PCSrcCont),.load_stall(load_stall),
                              .br_stall(br_stall),.br_stall_prev(br_stall_prev),
                              .IsStall(IsStall),.branch_flag(branch_flag),.prediction_false_flag(prediction_false_flag),
                              .IF_ID_branch_pred(IF_ID_branch_pred),.ID_PCSrc(ID_PCSrc),
                              .bht_update(bht_update),.btb_update(btb_update),.bht_update_dir(bht_update_dir));               

               
datapath riscv_datapath(.start(start),.clk(clk),.PC(PC),.icache_read_again(icache_read_again),
                        .icache_fetch(icache_fetch),.send_cache_read(datapath_to_icache_read),
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
