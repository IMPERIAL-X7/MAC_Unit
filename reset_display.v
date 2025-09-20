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



module reset_display(
    input wire clk,
    input wire debounced_reset,
    output reg reset_display_flag
);

reg [28:0] counter;

always @(posedge clk) begin
    if(debounced_reset == 1)begin
        reset_display_flag <= 1'b1;
        counter <= 29'd5;
    end else if(counter > 0) begin
        counter <= (counter - 1);
        reset_display_flag <= 1'b1;
    end else begin
        reset_display_flag <= 1'b0;
    end
end

endmodule
