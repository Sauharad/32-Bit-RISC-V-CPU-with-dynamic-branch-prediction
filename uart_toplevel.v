`timescale 1ns / 1ps


module uart_toplevel #(parameter len=8)
                    (input wire SYSCLK_P,
                     input wire SYSCLK_N,
                     input wire reset,
                     input wire en,
                     input wire [len-1:0] tx_in,
                     output wire [len-1:0] rx_out);

wire clk;
IBUFDS #(.DIFF_TERM("TRUE"),.IBUF_LOW_PWR("FALSE"),.IOSTANDARD("LVDS_25")) 
myibufds (.O(clk),.I(SYSCLK_P),.IB(SYSCLK_N));

wire baud_tick;

baud_generator my_baud_generator(.clk(clk),.baud_tick(baud_tick),.reset(reset));


wire tx,tx_done_tick;

uart_tx TX(.tx(tx),.clk(clk),.baud_tick(baud_tick),.reset(reset),.tx_done_tick(tx_done_tick),.en(en),.tx_in(tx_in));


wire rx_done_tick;

uart_rx RX(.rx(tx),.clk(clk),.baud_tick(baud_tick),.reset(reset),.rx_out(rx_out),.rx_done_tick(rx_done_tick));


endmodule
