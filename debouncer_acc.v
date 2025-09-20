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




module debouncer_acc(
    input wire clk,
    input wire sw12,
    output reg debounced_accu
);

reg [16:0] counter;
reg possible;

always @(posedge clk) begin
    // Synchronous reset of internal state when the input is not pressed
    if (sw12 == 1'b0) begin
        possible <= 1'b0;
        counter <= 17'd0;
        debounced_accu <= 1'b0;
    end
    else if(possible == sw12) begin
        // The input has been stable for a while, increment the counter
        counter <= counter+1;
        if(counter == 17'd1) begin
            // Input has been stable long enough, latch the value
            debounced_accu <= possible;
            counter <= 17'd0;
        end
    end else begin
        // The input has changed, start a new debounce count
        possible <= sw12;
        counter <= 17'd0;
        debounced_accu <= 1'b0;
    end
end

endmodule
