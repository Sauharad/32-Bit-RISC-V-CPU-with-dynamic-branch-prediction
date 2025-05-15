`timescale 1ns / 1ps

/* This is a 4-way set associative instruction cache that holds 64 sets indexed by the PC[10:5] , 
   each set having 4 blocks (hence 4 way) and each block having 8 words (instructions) with offset within block given by PC[4:2].
   It receives a fetch request from datapath during IF stage, and sends the instruction if there is a hit.
   In case of a miss, the miss signal is received by the control unit, which sends a read request on behalf of the cache to the main memory.
   The memory's data valid signal is received as the update signal by the cache, which then loads the block, and raises a cache_updated signal,
   so that the instruction can be requested again.
   
   For replacement of blocks, the Least Recently Used (LRU) policy is followed.
   
   The cache has been divided into two parts, the Valid Tag Priority (VTP) of each block, and the cache line of each block.
   Valid bit indicates whether the block is valid for reading
   Tag is the upper 21 bits of the PC.
   2 bit Priority indicates how recently the block has been used or updated, and the block with lowest priority is replaced if needed
   
*/

module I_cache(input wire start,
               input wire [31:0] PC,
               input wire read_request,
               input wire update,
               input wire [31:0] update_cache_0,
               input wire [31:0] update_cache_1,
               input wire [31:0] update_cache_2,
               input wire [31:0] update_cache_3,
               input wire [31:0] update_cache_4,
               input wire [31:0] update_cache_5,
               input wire [31:0] update_cache_6,
               input wire [31:0] update_cache_7,
               output wire read_hit,
               output reg [31:0] instr,
               output wire cache_update_occured);

//V - Valid, T - Tag, P - Priority
reg [0:23] ICache_VTP [0:63] [0:3];
reg [0:31] ICache_Data [0:63] [0:3] [0:7];
reg hit;
reg [31:0] ins;
reg up_occur;
assign read_hit = hit;
assign cache_update_occured = up_occur;

integer i,j,k,l,m,n;

reg [0:20] init_tag;
reg [0:31] init_data;


//Initlializing the cache
always @(*)
    begin
        if (start)
            for (i=0;i<64;i=i+1)
                for (j=0;j<4;j=j+1)
                    for (k=0;k<8;k=k+1)
                        begin
                            init_data = i*4 + j + k;
                            ICache_Data[i][j][k] = init_data;
                        end
        up_occur = 1'b0;
    end

always @(*)
    begin
        if (start)
            for (m=0;m<64;m=m+1)
                for (n=0;n<4;n=n+1)
                    begin
                        init_tag = m*4 + n;
                        ICache_VTP[m][n][0] = 1'b0;
                        ICache_VTP[m][n][1:21] = init_tag;
                        ICache_VTP[m][n][22:23] = n;
                    end
    end


//On read request, check for hit. If hit, provide instruction and update priority. If miss, set cache_hit = 0
always @(*)
    begin
        if (read_request)
            begin
                for (i=0;i<4;i=i+1)
                    if (ICache_VTP[PC[10:5]][i][1:21] == PC[31:11])
                        begin
                            if (ICache_VTP[PC[10:5]][i][0])
                                begin
                                    hit = 1'b1;
                                    instr = ICache_Data[PC[10:5]][i][PC[4:2]][0:31];
                                    ICache_VTP[PC[10:5]][i][22:23] = 2'b11;
                                    for (j=0;j<4;j=j+1)
                                        if (ICache_VTP[PC[10:5]][j][22:23] > ICache_VTP[PC[10:5]][i][22:23])
                                            ICache_VTP[PC[10:5]][j][22:23] = ICache_VTP[PC[10:5]][j][22:23] - 1;
                                end
                            if (!ICache_VTP[PC[10:5]][i][0])
                                hit <= 1'b0;
                        end                    
                if (ICache_VTP[PC[10:5]][0][1:21] != PC[31:11] &&
                    ICache_VTP[PC[10:5]][1][1:21] != PC[31:11] &&
                    ICache_VTP[PC[10:5]][2][1:21] != PC[31:11] &&
                    ICache_VTP[PC[10:5]][3][1:21] != PC[31:11])
                    hit = 1'b0;
            end
    end

//When memory raises valid signal, update the cache with the new block
always @(*)
    begin
        if (update)
            begin
                up_occur = 1'b1;
                for (k=0;k<4;k=k+1)
                    begin
                        if (ICache_VTP[PC[10:5]][k][22:23] == 2'b00)
                            begin
                                ICache_VTP[PC[10:5]][k] = {1'b1,PC[31:11],2'b11};
                                ICache_Data[PC[10:5]][k][PC[4:2]] = update_cache_0;
                                ICache_Data[PC[10:5]][k][PC[4:2]+1] = update_cache_1;
                                ICache_Data[PC[10:5]][k][PC[4:2]+2] = update_cache_2;
                                ICache_Data[PC[10:5]][k][PC[4:2]+3] = update_cache_3;
                                ICache_Data[PC[10:5]][k][PC[4:2]+4] = update_cache_4;
                                ICache_Data[PC[10:5]][k][PC[4:2]+5] = update_cache_5;
                                ICache_Data[PC[10:5]][k][PC[4:2]+6] = update_cache_6;
                                ICache_Data[PC[10:5]][k][PC[4:2]+7] = update_cache_7;
                                for (l=0;l<4;l=l+1)
                                    if (ICache_VTP[PC[10:5]][l][22:23] > ICache_VTP[PC[10:5]][k][22:23])
                                        ICache_VTP[PC[10:5]][l][22:23] = ICache_VTP[PC[10:5]][l][22:23] - 1;
                            end
                    end
            end
        if (!update)
            up_occur = 1'b0;
    end

endmodule
