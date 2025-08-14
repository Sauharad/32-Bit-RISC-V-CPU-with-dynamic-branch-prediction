`timescale 1ns / 1ps

/* As this design possesses data forwarding units, the only data hazards that occur are when an instruction reads from the destination of a load instruction before
   of it, as the loaded data becomes available after the MEM stage executes, but the next instruction will already be in EX by then.
   So, 1 cycle of stall is needed, and the load_stall flag signal is sent to control unit so that IsStall control signal can be asserted.
   
   A stall is also needed by branch instructions if the previous instructions are writing to its operands. The branch execution is occuring in the ID stage,
   but if the operands become available after EX or MEM stage, 1 or 2 cycles of stall will be required respectively.
*/

module hazard_detect(input wire [2:0] pcsrc_counter,
                     input wire [4:0] idex_rdloc,
                     input wire [4:0] ifid_rs1loc,
                     input wire [4:0] ifid_rs2loc,
                     input wire [6:0] opcode,
                     input wire idex_regwrite,
                     input wire idex_memread,
                     output wire load_stall,
                     output wire [1:0] br_stall);
                     
localparam [6:0] OP_B = 7'b1100011;

assign br_stall[0] =  (((idex_rdloc == ifid_rs1loc) || (idex_rdloc == ifid_rs2loc)) && (idex_regwrite)) && (opcode == OP_B);

assign br_stall[1] =  (((idex_rdloc == ifid_rs1loc) || (idex_rdloc == ifid_rs2loc)) && (idex_memread)) && (opcode == OP_B);

assign load_stall = ((idex_memread) && ((idex_rdloc == ifid_rs1loc) || (idex_rdloc == ifid_rs2loc)));


endmodule
