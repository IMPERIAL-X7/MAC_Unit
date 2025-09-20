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


module toplevel(
    input wire clk,
    input wire btnc,
    input wire sw15,
    input wire sw14,
    input wire sw13,
    input wire sw12,
    input wire sw9,
    input wire sw8,
    input wire [7:0]sw,
    output wire [15:0]led,
    output wire [6:0] seg,
    output wire [3:0] an,
    output wire dp
);

wire reset_flag;
wire [15:0] product;
wire [15:0] accum_value;
wire overflow_flag;

// Vector storage
reg [7:0] A[3:0];
reg [7:0] B[3:0];

// Vector writing status. Each bit corresponds to an index.
reg [3:0] A_written;
reg [3:0] B_written;

// State machine for dot product computation
reg [2:0] dot_prod_counter; // Counter for vector elements
reg is_computing;
reg dot_product_done;

// Signals for the MAC unit
reg [7:0] mac_input_a;
reg [7:0] mac_input_b;
wire mac_enable;

// Signals for display control
wire reset_disp_flag;
wire oflo_disp_flag;


// The reset debouncer is instantiated correctly here.
debouncer_reset u_db_rst(
    .clk(clk),
    .btnc(btnc),
    .reset_value(reset_flag)
);


//initial begin
//    A[0] <= 8'd0; A[1] <= 8'd0; A[2] <= 8'd0; A[3] <= 8'd0;
//    B[0] <= 8'd0; B[1] <= 8'd0; B[2] <= 8'd0; B[3] <= 8'd0;
//    A_written <= 4'b0000;
//    B_written <= 4'b0000;
//    dot_prod_counter <= 3'd0;
//    is_computing <= 1'b0;
//    dot_product_done <= 1'b0;
//    end


// All registers are driven from this single always block.
always @(posedge clk) begin
    if (reset_flag) begin
        // Reset all registers to a known state.
        A[0] <= 8'd0; A[1] <= 8'd0; A[2] <= 8'd0; A[3] <= 8'd0;
        B[0] <= 8'd0; B[1] <= 8'd0; B[2] <= 8'd0; B[3] <= 8'd0;
        A_written <= 4'b0000;
        B_written <= 4'b0000;
        dot_prod_counter <= 3'd0;
        is_computing <= 1'b0;
        dot_product_done <= 1'b0;
        mac_input_a <= 8'd0;
        mac_input_b <= 8'd0;
    end else begin
        // Vector Write Logic
        if (sw12) begin
            A[2*(sw9) + sw8] <= sw[7:0];
            A_written[2*(sw9) + sw8] <= 1'b1;
        end
        if (sw13) begin
            B[2*(sw9) + sw8] <= sw[7:0];
            B_written[2*(sw9) + sw8] <= 1'b1;
        end

        if(is_computing) begin
            mac_input_a <= (dot_prod_counter < 3'd4) ? A[dot_prod_counter] : 8'd0;
            mac_input_b <= (dot_prod_counter < 3'd4) ? B[dot_prod_counter] : 8'd0;
            dot_prod_counter <= dot_prod_counter + 1;
            if (dot_prod_counter == 3'd4) begin
                is_computing <= 1'b0;
                dot_product_done <= 1'b1;
            end
        end
        // Dot Product State Machine and Controller
        else if ((A_written == 4'b1111) && (B_written == 4'b1111) && !is_computing && !dot_product_done) begin
            is_computing <= 1'b1;
            dot_prod_counter <= 3'd0;
//        end else if (is_computing) begin
//            dot_prod_counter <= dot_prod_counter + 1;
//            if (dot_prod_counter == 3'd3) begin
//                is_computing <= 1'b0;
//                dot_product_done <= 1'b1;
//            end
        end
    end
end


// Assign multiplier inputs based on the dot product counter
//assign mac_input_a = (dot_prod_counter < 3'd4) ? A[dot_prod_counter] : 8'd0;
//assign mac_input_b = (dot_prod_counter < 3'd4) ? B[dot_prod_counter] : 8'd0;

multiplier u_mult (
    .b(mac_input_a),
    .c(mac_input_b),
    .product(product)
);

// MAC enable signal is a single pulse for each step of the dot product
assign mac_enable = is_computing;

accumulator u_accu (
    .clk(clk),
    .reset_flag(reset_flag || (A_written != 4'b1111) || (B_written != 4'b1111)),
    .enable(mac_enable),
    .product(product),
    .accum_value(accum_value),
    .overflow_flag(overflow_flag)
);

assign led = accum_value;


wire [15:0] display_value;
wire [7:0] selected_element_A = A[2*(sw9) + sw8];
wire [7:0] selected_element_B = B[2*(sw9) + sw8];

// Multiplex the value to be displayed on the 7-segment display
assign display_value = (sw14 & sw15) ? accum_value : sw14 ? {8'hFF, selected_element_A} :
                       sw15 ? {8'hFF, selected_element_B} :
                       accum_value;

reset_display u_reset_dp (
    .clk(clk),
    .debounced_reset(reset_flag),
    .reset_display_flag(reset_disp_flag)
);

overflow_display u_oflo_dp (
    .clk(clk),
    .overflow_flag(overflow_flag),
    .reset_value(reset_flag),
    .oflo_disp_active(oflo_disp_flag)
);

seven_seg_display u_7seg (
    .clk(clk),
    .value(display_value),
    .reset_disp_active(reset_disp_flag),
    .oflo_disp_active(oflo_disp_flag),
    .seg(seg),
    .an(an),
    .dp(dp)
);

endmodule
