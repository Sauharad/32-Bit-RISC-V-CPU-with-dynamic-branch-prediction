`timescale 1ns / 1ps

/* The forwarding unit prevents stalls due to data hazards between instructions in successive pipeline stages.
   Without forwarding, if the operand of an instruction used the destination of the previous instruction, it would have to wait until Writeback of that instruction
   to read its operand register.
   With forarding, data output of EX or MEM stages gets forwarded to inputs of ALU and the stall is no longer needed
   
   There are two forwarding units in this design. One for the ALU, forwarding from EX_MEM or MEM_WB pipeline registers to ALU input
   The other is for the branch testing unit in the ID stage.
*/

module forwarding_unit(input wire [4:0] comp_loc_rs1,
                       input wire [4:0] comp_loc_rs2,
                       input wire [4:0] comp_loc_exmem,
                       input wire [4:0] comp_loc_memwb,
                       input wire [31:0] pc,
                       input wire [6:0] opc,
                       input wire cont_idex_alusrc,
                       input wire cont_idex_mw,
                       input wire cont_exmem_rw,
                       input wire cont_memwb_rw,
                       input wire cont_memwb_mtr,
                       input wire [31:0] memwb_readdata,
                       input wire [31:0] memwb_aluout,
                       input wire [31:0] exmem_aluout,
                       input wire [31:0] forw_rs1,
                       input wire [31:0] forw_rs2,
                       input wire [31:0] forw_imm,
                       input wire [2:0] pcsrc_counter,
                       output wire [31:0] out_A,
                       output wire [31:0] out_B,
                       output wire [31:0] out_rs2
                       );

localparam [6:0] OP_JAL = 7'b1101111;
                       
wire [1:0] forwardA,forwardB;

//If hazard between ID and EX stage
assign forwardA[0] = (comp_loc_exmem == comp_loc_rs1) && (cont_exmem_rw); 
assign forwardB[0] =  (comp_loc_exmem == comp_loc_rs2) && (cont_exmem_rw);

//If hazard between ID and MEM stage
assign forwardA[1] = (comp_loc_memwb == comp_loc_rs1) && (cont_memwb_rw) && (comp_loc_exmem != comp_loc_rs1);
assign forwardB[1] = (comp_loc_memwb == comp_loc_rs2) && (cont_memwb_rw) && (comp_loc_exmem != comp_loc_rs2);

//Forward EX_ALUOut or MEM_ALUOut or MEM_ReadData to A if needed
assign out_A = (opc == OP_JAL) ? pc : forwardA[1] ? (cont_memwb_mtr ? memwb_readdata : memwb_aluout) : forwardA[0] ? exmem_aluout : forw_rs1;

//Forward EX_ALUOut or MEM_ALUOut or MEM_ReadData to B if needed. Store instructions do not forward rs2
assign out_B = (opc == OP_JAL) ? 32'h00000004 : 
(forwardB[1] && !cont_idex_mw) ? (cont_memwb_mtr ? memwb_readdata : memwb_aluout) : (forwardB[0] && !cont_idex_mw) ? 
exmem_aluout : cont_idex_alusrc ? forw_imm : forw_rs2;

//Forward rs2 to EX stage from MEM stage when needed
assign out_rs2 = forwardB[1] ? (cont_memwb_mtr ? memwb_readdata : memwb_aluout) : forw_rs2;

endmodule
