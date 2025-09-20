`timescale 1ns / 1ps

module tb;

    // Testbench signals
    reg clk;
    reg btnc;
    reg sw15;
    reg sw14;
    reg sw13;
    reg sw12;
    reg sw9;
    reg sw8;
    reg [7:0]sw;
    // Removed wire declarations for led, seg, an, and dp

    // Internal wires for monitoring
    wire [15:0] accum_value;
    wire overflow_flag;
    wire mac_enable;
    wire reset_flag;
    wire is_computing;
    // reg [7:0] A[3:0];
    // reg [7:0] B[3:0];

    // Instantiate the Unit Under Test (UUT)
    // The outputs for the displays and LEDs have been removed
    toplevel uut (
        .clk(clk),
        .btnc(btnc),
        .sw15(sw15),
        .sw14(sw14),
        .sw13(sw13),
        .sw12(sw12),
        .sw9(sw9),
        .sw8(sw8),
        .sw(sw)
    );

    // Connect internal wires for monitoring
    assign accum_value = uut.accum_value;
    assign overflow_flag = uut.overflow_flag;
    assign mac_enable = uut.mac_enable;
    assign reset_flag = uut.reset_flag;
    assign is_computing = uut.is_computing;
    // assign A = uut.A;
    // assign B = uut.B;

    // Clock Generation
    initial begin
        clk = 0;
    end

    always #5 clk = ~clk; // 100 MHz clock

    // Simulation Sequence
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0);
        // Initialize all inputs
        sw15 = 1'b0; sw14 = 1'b0; sw13 = 1'b0; sw12 = 1'b0;
        sw9 = 1'b0; sw8 = 1'b0; sw = 8'd0;
        btnc = 1'b1; // Reset is active low, so we set it to high to start


        // Wait for reset to be applied and for the display to show "-rSt"
        #100;
        btnc = 1'b0; // Push the reset button
        #100;
        btnc = 1'b1; // Release the reset button
        #100;
        btnc = 1'b0;


        // Write vectors A and B for a predictable result
        // Vector A = [10, 20, 30, 40]
        // Vector B = [5, 5, 5, 5]
        // Dot Product = (10*5) + (20*5) + (30*5) + (40*5) = 50 + 100 + 150 + 200 = 500 (16'h01F4)

        // Write the vectors
        for (integer i = 0; i < 4; i = i + 1) begin
            sw9 = (i >> 1) & 1'b1;
            sw8 = i & 1'b1;

            // Write to Vector A
            case (i)
                0: sw = 8'd10;
                1: sw = 8'd20;
                2: sw = 8'd30;
                3: sw = 8'd40;
                default: sw = 8'd0;
            endcase
            sw12 = 1'b1; sw13 = 1'b0;
            #100;
            sw12 = 1'b0;

            // Write to Vector B
            sw = 8'd5;
            sw13 = 1'b1;
            #100;
            sw13 = 1'b0;
        end


        // Wait for dot product to finish
//        while (!is_computing) #10;
//        while (is_computing) #10;


        // Reset the system for the next test
        btnc = 1'b0;
        #50;
        btnc = 1'b1;
        #50;
        btnc = 1'b0;

        // Write vectors that will cause an overflow
        // Vector A = [255, 255, 255, 255]
        // Vector B = [255, 255, 255, 255]
        // Dot Product = (255*255)*4 = 65025 * 4 = 260100. This is > 16 bits.
        for (integer i = 0; i < 4; i = i + 1) begin
            sw9 = (i >> 1) & 1'b1;
            sw8 = i & 1'b1;

            sw = 8'd255;
            sw12 = 1'b1; sw13 = 1'b1;
            #50;
            sw12 = 1'b0; sw13 = 1'b0;
        end


        // Wait for computation and overflow to occur
//        while (!is_computing) #10;
//        while (!overflow_flag) #10;
//        while (is_computing) #10;

        // End simulation
        #100;
        $finish;
    end
endmodule
