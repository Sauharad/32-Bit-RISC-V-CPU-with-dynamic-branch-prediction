`timescale 1ns / 1ps

module uart_rx #(parameter len=8)(input wire rx,
               input wire clk,
               input wire reset,
               input wire baud_tick,
               output reg rx_done_tick,
               output wire [7:0] rx_out);
               
localparam [1:0] idle = 2'b00, start = 2'b01, data = 2'b10, stop = 2'b11;
reg [1:0] PS, NS;
reg [3:0] baud_counter, baud_counter_next;
reg [len-1:0] bit_counter,bit_counter_next;
reg [len-1:0] store, store_next;
reg start_received, stop_received;

assign rx_out = store;

always @(posedge clk)
    begin
        if (reset)
            begin
                bit_counter_next <= 0;
                baud_counter_next <= 4'b0000;
                NS = idle;
            end
        if (!reset)
            begin
                PS <= NS;
                store <= store_next;
                bit_counter <= bit_counter_next;
                baud_counter <= baud_counter_next;
            end
    end

always @(*)
    begin
        case (PS)
            idle: begin
                        rx_done_tick = 1'b0;
                        if (rx == 0)
                            begin
                                NS = start;
                                baud_counter_next = 4'b0000;
                            end
                    end
           start: begin
                        if (baud_tick)
                            begin
                                baud_counter_next = baud_counter + 1;
                                if (baud_counter == 4'b0111)
                                    begin
                                        start_received = ~rx;
                                    end
                                if (baud_counter == 4'b1111 && start_received)
                                    begin
                                        NS = data;
                                        bit_counter_next = 0;
                                        baud_counter_next = 0;
                                    end
                            end
                    end
            data: begin
                        if (baud_tick)
                            begin
                                baud_counter_next = baud_counter + 1;
                                if (baud_counter == 4'b0111)
                                    begin
                                        store_next = {rx, store[7:1]};
                                        bit_counter_next = bit_counter + 1;
                                        if (bit_counter == len-1)
                                            NS = stop;
                                    end
                                if (baud_counter == 4'b1111)
                                    baud_counter_next = 4'b0000;
                                
                            end
                    end 
            stop: begin
                        if (baud_tick)
                            begin
                                baud_counter_next = baud_counter + 1;
                                if (baud_counter == 4'b0111)
                                    begin
                                        stop_received = rx;
                                    end
                                if (baud_counter == 4'b1111)
                                    begin
                                        if (stop_received)
                                            begin
                                                baud_counter_next = 4'b0000;
                                                NS = idle;
                                                rx_done_tick = 1'b1;
                                            end
                                    end
                            end
                    end
        endcase
    end


endmodule
