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



module accumulator (
    input  wire        clk,
    input  wire        reset_flag,    // active-high reset (from debouncer)
    input  wire        enable,        // one-pulse enable (from debouncer_accumulator)
    input  wire [15:0] product,       // product from multiplier
    output reg  [15:0] accum_value,   // accumulated value (to LEDs/display)
    output reg         overflow_flag  // goes high if overflow occurs
);

    // reg [16:0] temp_sum;  // one extra bit for overflow detection

    always @(posedge clk) begin
        if (reset_flag) begin
            accum_value   <= 16'd0;
            overflow_flag <= 1'b0;
            // temp_sum      <= 0;
        end
        else if (enable && ~overflow_flag) begin
            // temp_sum <= accum_value + product;
            if (accum_value > 16'b1111111111111111 - product) begin
                // overflow occurred
                accum_value   <= 16'd0;   // reset accumulator
                overflow_flag <= 1'b1;    // latch overflow

            end else begin
                // normal accumulation
                accum_value   <= accum_value + product;
                // overflow_flag <= 1'b0;
            end
        end
    end

endmodule
