`timescale 1ns / 1ps

module uart_tx #(parameter len=8)(input wire baud_tick,
               input wire clk,
               input wire reset,
               input wire en,
               input wire [len-1:0] tx_in,
               output wire tx,
               output reg tx_done_tick);
               
reg [len-1:0] store_shift,store_shift_next;
reg start_tx;
reg reg_out, reg_out_next;
reg [3:0] baud_counter, baud_counter_next;
reg [len-1:0] bit_counter, bit_counter_next;

localparam [1:0] idle = 2'b00, start=2'b01, data = 2'b10, stop = 2'b11;
reg [1:0] PS, NS;           


assign tx = reg_out;           
           
always @(posedge clk)
    begin
        if (reset)
            begin
                NS <= 2'b00;
                baud_counter_next <= 4'b0000;
                reg_out_next <= 1'b1;
                start_tx <= 1'b0;
            end
        if (en)
            begin
                store_shift_next <= tx_in;
                start_tx <= 1'b1;
            end
        if (start_tx && PS != idle)
            start_tx <= 1'b0;
        
        PS <= NS;
        baud_counter <= baud_counter_next;
        reg_out <= reg_out_next;
        store_shift <= store_shift_next;
        bit_counter <= bit_counter_next;
    end

always @(*)
    begin
        tx_done_tick = 1'b0;
        case (PS)
            idle : begin
                        reg_out_next = 1'b1;
                        if (start_tx)
                            begin
                                NS = start;
                                baud_counter_next = 4'b0000;
                            end
                     end
           start: begin
                        reg_out_next = 1'b0;
                        if (baud_tick)
                            begin
                                if (baud_counter == 4'b1111)
                                    begin
                                        baud_counter_next = 4'b0000;
                                        NS = data;
                                        bit_counter_next = 0;
                                    end
                                if (baud_counter != 4'b1111)
                                    baud_counter_next = baud_counter + 1;
                            end
                    end
            data: begin
                        reg_out_next = store_shift[0];
                        if (baud_tick)
                            begin
                                if (baud_counter == 4'b1111)
                                    begin
                                        baud_counter_next = 4'b0000;
                                        store_shift_next = {1'b0,store_shift[7:1]};
                                        bit_counter_next = bit_counter + 1;
                                        if (bit_counter == len-1)
                                            NS = stop;
                                    end
                                if (baud_counter != 4'b1111)
                                    begin
                                        baud_counter_next = baud_counter + 1;
                                    end
                            end
                        
                    end
             stop: begin
                        reg_out_next = 1'b1;
                        if (baud_tick)
                            begin
                                if (baud_counter == 4'b1111)
                                    begin
                                        NS = idle;
                                        tx_done_tick = 1'b1;
                                    end
                                if (baud_counter != 4'b1111)
                                    baud_counter_next = baud_counter + 1;
                            end
                    end
        endcase
    end


endmodule
