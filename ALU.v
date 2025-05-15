`timescale 1ns / 1ps

/* ALU receives ALUOp opcode from control unit and performs the arithmetic, logical, shifting etc operations accordingly.
*/

module ALU(input wire [4:0] ALUOp,
           input wire signed [31:0] A,
           input wire signed [31:0] B,
           output wire signed [31:0] ALUOut);

reg [31:0] aluout;

assign ALUOut = aluout;

always @(*)
    begin
        case (ALUOp)
            5'b00000: aluout = A+B;
            5'b00001: aluout = A-B;
            5'b00010: aluout = A&B;
            5'b00011: aluout = A|B;
            5'b00100: aluout = {32{(A==B)}};
        endcase
    end
    
    
endmodule
