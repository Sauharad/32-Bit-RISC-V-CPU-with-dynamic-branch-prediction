`timescale 1ns / 1ps

/* The instruction memory is byte-addressable and has a latency of 8 cycles whenever it receives a read request.
   Upon receiving the read request, it sends a block of 8 words to the cache and raises a valid signal to tell the cache to read.
*/

module Inst_Mem(input wire start,
                input wire clk,
                input wire read,
                input wire [31:0] PC,
                output wire [31:0] instr_0,
                output wire [31:0] instr_1,
                output wire [31:0] instr_2,
                output wire [31:0] instr_3,
                output wire [31:0] instr_4,
                output wire [31:0] instr_5,
                output wire [31:0] instr_6,
                output wire [31:0] instr_7,
                output wire instr_valid);

reg [7:0] Inst_Mem [0:255];

reg [2:0] mem_delay_count,mem_delay_count_next;
reg counting,counting_next;
reg [31:0] instr_next;

reg valid, valid_next;
assign instr_valid = valid;

reg [31:0] i0,i1,i2,i3,i4,i5,i6,i7,i0n,i1n,i2n,i3n,i4n,i5n,i6n,i7n;
assign instr_0 = i0,instr_1 = i1,instr_2 = i2,instr_3 = i3,instr_4 = i4,instr_5 = i5,instr_6 = i6,instr_7 = i7;

always @(*)
    if (start)
        valid_next = 1'b0;

always @(posedge clk)
    begin
        mem_delay_count <= mem_delay_count_next;
        valid <= valid_next;
        counting <= counting_next;
        i0 <= i0n; i1 <= i1n; i2 <= i2n; i3 <= i3n; i4 <= i4n; i5 <= i5n; i6 <= i6n; i7 <= i7n;
    end

reg mem_count_parity;
    
always @(*)
    begin
        if (read)
            begin
                mem_delay_count_next = 0;
                counting_next = 1'b1;
                mem_count_parity = 1'b0;
            end
        if (!read)
            begin
                if (!mem_count_parity)
                    mem_delay_count_next = mem_delay_count + 1;
                if ((mem_delay_count == 3'b111) & counting)
                    begin
                        i0n = {Inst_Mem[PC],Inst_Mem[PC+1],Inst_Mem[PC+2],Inst_Mem[PC+3]};
                        i1n = {Inst_Mem[PC+4],Inst_Mem[PC+5],Inst_Mem[PC+6],Inst_Mem[PC+7]};
                        i2n = {Inst_Mem[PC+8],Inst_Mem[PC+9],Inst_Mem[PC+10],Inst_Mem[PC+11]};
                        i3n = {Inst_Mem[PC+12],Inst_Mem[PC+13],Inst_Mem[PC+14],Inst_Mem[PC+15]};
                        i4n = {Inst_Mem[PC+16],Inst_Mem[PC+17],Inst_Mem[PC+18],Inst_Mem[PC+19]};
                        i5n = {Inst_Mem[PC+20],Inst_Mem[PC+21],Inst_Mem[PC+22],Inst_Mem[PC+23]};
                        i6n = {Inst_Mem[PC+24],Inst_Mem[PC+25],Inst_Mem[PC+26],Inst_Mem[PC+27]};
                        i7n = {Inst_Mem[PC+28],Inst_Mem[PC+29],Inst_Mem[PC+30],Inst_Mem[PC+31]};
                        valid_next = 1'b1;
                        counting_next = 1'b0;
                        mem_delay_count_next = 3'b000;
                        mem_count_parity = 1'b1;
                    end
                else
                    begin
                        valid_next = 1'b0;
                        counting_next = 1'b1;
                    end
            end
    end

endmodule
