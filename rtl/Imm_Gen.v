`timescale 1ns / 1ps

/* This module generates the immediate field for I S U B and J type instructions. Each instruction has its own format of the immediate and 
   so it is decoded as a case of the opcode, and is sign extended to 32 bits.
*/

module Imm_Gen(input wire [31:0] if_id_ir,
               output wire [31:0] Imm);
      
localparam [6:0] OP_REG = 7'b0110011,OP_LW = 7'b0000011,OP_SW = 7'b0100011,OP_B = 7'b1100011,OP_JAL = 7'b1101111;      

reg [31:0] imm;

assign Imm = imm;
               
always @(*)
begin
    case(if_id_ir[6:0])
        OP_REG: imm = 32'h00000000; //immediate is not needed for Register-Register Instructions
         OP_LW: imm = {{20{if_id_ir[31]}},if_id_ir[31:20]}; //immediate for load address
         OP_SW: imm = {{20{if_id_ir[31]}},if_id_ir[31:25],if_id_ir[11:7]}; //immediate for store address
          OP_B: imm = {{18{if_id_ir[31]}},if_id_ir[31],if_id_ir[7],if_id_ir[30:25],if_id_ir[11:8],2'b00}; //immediate for conditional branch address
        OP_JAL: imm = {{10{if_id_ir[31]}},if_id_ir[31],if_id_ir[19:12],if_id_ir[20],if_id_ir[30:21],2'b00}; //immediate for jump address
    endcase
end


endmodule
