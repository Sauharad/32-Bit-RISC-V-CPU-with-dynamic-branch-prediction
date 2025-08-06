`timescale 1ns / 1ps


module baud_generator(input wire clk,
                      input wire reset,
                      output wire baud_tick);

reg [7:0] counter;

always @(posedge clk)
    begin
        if (reset)
            counter <= 0;
        if (!reset)
            begin
                if (counter == 100)
                    counter <= 0;
                if (counter != 100)
                    counter <= counter + 1;
            end
     end

assign baud_tick = counter == 100;


endmodule
