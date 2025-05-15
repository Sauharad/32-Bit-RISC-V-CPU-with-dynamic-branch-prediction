`timescale 1ns / 1ps

/* The Branch Target Buffer (BTB) is 4-way set associative with 32 sets, using the lower 5 PC bits as an index to store the target of each branch instruction.
   The upper bits 16 are used as a tag. All bits of PC are not used as a tag to reduce memory requirements, and because predictions are verified,
   a wrong tag match will not lead to incorrect instruction execution, just delay.
   
   The buffer stores the valid bit for each line in a set, the tag, the branch target and the priority for LRU replacement.
   The branch target is provided as the predicted pc (ppc) signal to the datapath when a hit occurs.
   
   Updation is performed when a new branch is executed or a prediction is verified/falsified.
*/

module BTB(input wire [31:0] PC_predict_from,
           input wire [31:0] PC_update_for,
           input wire update,
           input wire [31:0] target_address_update,
           input wire start,
           output wire [31:0] predicted_PC,
           output wire btb_hit);

//BTBuffer Format - Tag | Valid | Target | LRU Priority 
reg [0:50] BTBuffer [0:31][0:3];
reg [31:0] ppc;
reg hit;

assign predicted_PC = ppc;
assign btb_hit = hit;

integer i,j,k,l,m,n,o,p;
reg [15:0] id;
always @(*)
    if (start)
        for (i=0;i<32;i=i+1)
            for (j=0;j<4;j=j+1)
                begin
                    id = i*4 + j;
                    BTBuffer[i][j][0:15] = id;
                    BTBuffer[i][j][16] = 1'b0;
                    BTBuffer[i][j][17:48] = 32'h00000000;
                    BTBuffer[i][j][49:50] = j;
                end

always @(*)
    begin
        for (k=0;k<4;k=k+1)
            if ({BTBuffer[PC_predict_from[6:2]][k][0:16]} == {PC_predict_from[22:7],1'b1})
                begin
                    hit = 1'b1;
                    ppc = BTBuffer[PC_predict_from[6:2]][k][17:48];
                    BTBuffer[PC_predict_from[6:2]][k][49:50] = 2'b11;
                    for (o=0;o<4;o=o+1)
                        if (BTBuffer[PC_predict_from[6:2]][o][49:50] > BTBuffer[PC_predict_from[6:2]][k][49:50])
                            BTBuffer[PC_predict_from[6:2]][o][49:50] = BTBuffer[PC_predict_from[6:2]][o][49:50] - 1;
                end
        if ({BTBuffer[PC_predict_from[6:2]][0][0:16]} != {PC_predict_from[22:7],1'b1} &&
            {BTBuffer[PC_predict_from[6:2]][1][0:16]} != {PC_predict_from[22:7],1'b1} &&
            {BTBuffer[PC_predict_from[6:2]][2][0:16]} != {PC_predict_from[22:7],1'b1} &&
            {BTBuffer[PC_predict_from[6:2]][3][0:16]} != {PC_predict_from[22:7],1'b1})
            hit = 1'b0;
            
    end

always @(*)
    begin
        if (update)
            begin
                for (l=0;l<4;l=l+1)
                    if (BTBuffer[PC_update_for[6:2]][l][0:15] == PC_update_for[22:7])
                        begin
                            BTBuffer[PC_update_for[6:2]][l][16:50] = {1'b1,target_address_update,2'b11};
                            for (m=0;m<4;m=m+1)
                                if (BTBuffer[PC_update_for[6:2]][m][49:50] > BTBuffer[PC_update_for[6:2]][l][49:50])
                                    BTBuffer[PC_update_for[6:2]][m][49:50] = BTBuffer[PC_update_for[6:2]][m][49:50] - 1;
                        end
                if(BTBuffer[PC_update_for[6:2]][0][0:15] != PC_update_for[22:7] &&
                   BTBuffer[PC_update_for[6:2]][1][0:15] != PC_update_for[22:7] &&
                   BTBuffer[PC_update_for[6:2]][2][0:15] != PC_update_for[22:7] &&
                   BTBuffer[PC_update_for[6:2]][3][0:15] != PC_update_for[22:7])
                   begin
                        for (i=0;i<4;i=i+1)
                            begin
                                if (BTBuffer[PC_update_for[6:2]][i][49:50] == 2'b00)
                                    begin
                                        BTBuffer[PC_update_for[6:2]][i] = {PC_update_for[22:7],1'b1,target_address_update,2'b11};
                                        for (j=0;j<4;j=j+1)
                                            if (j != i)
                                                BTBuffer[PC_update_for[6:2]][j][49:50] = BTBuffer[PC_update_for[6:2]][j][49:50] - 1;
                                    end
                            end
                        
                   end
            end
    end
    
endmodule
