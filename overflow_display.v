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


module overflow_display (
    input  wire clk,
    input  wire overflow_flag,   // from accumulator
    input  wire reset_value,      // to clear overflow, debounced reset value
    output reg  oflo_disp_active // stays high until reset
);

    always @(posedge clk) begin
        if (reset_value) begin
            oflo_disp_active <= 1'b0;
        end else if (overflow_flag) begin
            oflo_disp_active <= 1'b1;
        end
    end

endmodule
