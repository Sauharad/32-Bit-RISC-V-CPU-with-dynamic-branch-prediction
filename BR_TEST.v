`timescale 1ns / 1ps

/* This module tests whether the conditional branch is to be taken or not by evaluating the condition.
*/

module BR_Test_Unit(input wire A,
               input wire B,
               output wire BR_TAKE);
               
assign BR_TAKE = (A==B);

endmodule
