`timescale 1ns / 1ps

/* The Branch History Table (BHT) stores the likelihood of a branch being taken as a counter.
   It is indexed by the lower 5 bits of the PC, and holds a 2 bit saturating counter at each location.
   Counter = 00 -> Strongly not taken
   Counter = 01 -> Weakly not taken
   Counter = 10 -> Weakly taken
   Counter = 11 -> Strongly taken
   
   When a new branch occurs or an existing prediction gets verified/falsified, the table gets updated by incrementing/decrementing the counter.
*/

module BHT(input wire [4:0] PC_lower_predict,
           input wire [4:0] PC_lower_update,
           input wire update,
           input wire update_direction,
           input wire start,
           output wire bht_hit);
           
reg [1:0] BHTable [0:31];

reg hit;
assign bht_hit = hit;

//Initialization
integer i;
always @(*)
    if (start)
        for (i=0;i<32;i=i+1)
            begin
                BHTable[i] = 2'b01;
            end
    
always @(*)
    begin
        hit = (BHTable[PC_lower_predict] == 2'b10 || BHTable[PC_lower_predict] == 2'b11);
        if (update)
            begin
                if (update_direction == 1'b1 && BHTable[PC_lower_update] != 2'b11)
                    BHTable[PC_lower_update] = BHTable[PC_lower_update] + 1;
                if (update_direction == 1'b0 && BHTable[PC_lower_update] != 2'b00)
                    BHTable[PC_lower_update] = BHTable[PC_lower_update] - 1;    
            end
    end   

    
endmodule
