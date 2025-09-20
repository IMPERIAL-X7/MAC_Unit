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


module seven_seg_display (
    input  wire        clk,
    input  wire [15:0] value,             // value to be displayed
    input  wire        reset_disp_active, // show -rSt if 1
    input  wire        oflo_disp_active,  // show OFLO if 1
    output reg  [6:0]  seg,
    output reg  [3:0]  an,
    output reg         dp
);

// Muxing counter for anodes
reg [16:0] counter;
reg [1:0] active_anode;

// Mapping of hex values to 7-segment segments
reg [6:0] seg_map[15:0];
initial begin
    seg_map[0] = 7'b1000000; // 0
    seg_map[1] = 7'b1111001; // 1
    seg_map[2] = 7'b0100100; // 2
    seg_map[3] = 7'b0110000; // 3
    seg_map[4] = 7'b0011001; // 4
    seg_map[5] = 7'b0010010; // 5
    seg_map[6] = 7'b0000010; // 6
    seg_map[7] = 7'b1111000; // 7
    seg_map[8] = 7'b0000000; // 8
    seg_map[9] = 7'b0010000; // 9
    seg_map[10] = 7'b0001000; // A
    seg_map[11] = 7'b0000011; // B
    seg_map[12] = 7'b1000110; // C
    seg_map[13] = 7'b0100001; // D
    seg_map[14] = 7'b0000110; // E
    seg_map[15] = 7'b0001110; // F
end

// All registered outputs are driven from this single synchronous block with a reset
always @(posedge clk) begin
    if (reset_disp_active) begin
        // When reset is active, show -rSt

        counter <= counter + 1;
        if (counter == 17'd99999) begin
            counter <= 17'd0;
            active_anode <= (active_anode == 2'd3) ? 2'd0 : active_anode + 1;
        end
        dp <= 1'b1;
        case (active_anode)
            2'd0: begin an <= 4'b1110; seg <= 7'b0111111; end // -
            2'd1: begin an <= 4'b1101; seg <= 7'b0101111; end // r
            2'd2: begin an <= 4'b1011; seg <= 7'b0010010; end // s
            2'd3: begin an <= 4'b0111; seg <= 7'b0000111; end // t
        endcase
    end else begin
        // Normal operation (muxing)
        counter <= counter + 1;
        if (counter == 17'd99999) begin
            counter <= 17'd0;
            active_anode <= (active_anode == 2'd3) ? 2'd0 : active_anode + 1;
        end
        // Drive outputs based on current anode and value
        dp <= 1'b1; // No decimal point for this display mode
        case (oflo_disp_active)
            1'b1: begin // Display OFLO
                case (active_anode)
                    2'd0: begin an <= 4'b1110; seg <= 7'b1000000; end // O
                    2'd1: begin an <= 4'b1101; seg <= 7'b0001110; end // F
                    2'd2: begin an <= 4'b1011; seg <= 7'b1000111; end // L
                    2'd3: begin an <= 4'b0111; seg <= 7'b1000000; end // O
                    default: begin an <= 4'b1111; seg <= 7'b1111111; end // blank
                endcase
            end
            default: begin // Display the value
                case (active_anode)
                    2'd0: begin an <= 4'b1110; seg <= seg_map[value[0] + 2*value[1] + 4*value[2] + 8*value[3]]; end
                    2'd1: begin an <= 4'b1101; seg <= seg_map[value[4] + 2*value[5] + 4*value[6] + 8*value[7]]; end
                    2'd2: begin an <= 4'b1111; seg <= seg_map[value[8] + 2*value[9] + 4*value[10] + 8*value[11]]; end
                    2'd3: begin an <= 4'b1111; seg <= seg_map[value[12] + 2*value[13] + 4*value[14] + 8*value[15]]; end
                    default: begin an <= 4'b1111; seg <= 7'b1111111; end // blank
                endcase
            end
        endcase
    end
end

endmodule
