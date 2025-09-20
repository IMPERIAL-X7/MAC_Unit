`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02.09.2025 13:25:54
// Design Name:
// Module Name: overflow_display
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module debouncer_reset (
    input wire clk,
    input wire btnc,      // active-low reset from push button
    output reg reset_value
);

reg [16:0] counter;
reg possible;

always @(posedge clk) begin
    if (btnc == 1) begin // This is to reset the internal state when BTNC is high
    possible <= 1;
        if(possible == btnc) begin
            counter <= counter+1;
            if(counter == 17'd1) begin
                reset_value <= possible;
                counter <= 0;
            end
        end else begin
            counter <= 0;
        end

//        reset_value <= 0;
    end else begin
        possible <= btnc;
        counter <= 0;
        reset_value <= 0;
    end

end

endmodule
