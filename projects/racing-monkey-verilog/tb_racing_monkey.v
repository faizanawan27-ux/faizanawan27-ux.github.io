// ============================================================================
// Module Name:  tb_racing_monkey
// Project:      Racing Monkey Verilog Simulation Testbench
// Author:       Faizan (22PWCSE2134)
// Description:  Simulates 50MHz clock input and monitors VGA hsync/vsync timing.
// ============================================================================

`timescale 1ns / 1ps

module tb_racing_monkey;

    reg        clk_50MHz;
    reg        reset;
    reg        btn_jump;
    reg        btn_duck;
    reg        btn_start;
    wire       vga_hsync;
    wire       vga_vsync;
    wire [3:0] vga_red;
    wire [3:0] vga_green;
    wire [3:0] vga_blue;
    wire [3:0] score_anode;
    wire [7:0] score_cathode;

    // Instantiate Top Module
    racing_monkey_top uut (
        .clk_50MHz(clk_50MHz),
        .reset(reset),
        .btn_jump(btn_jump),
        .btn_duck(btn_duck),
        .btn_start(btn_start),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync),
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue),
        .score_anode(score_anode),
        .score_cathode(score_cathode)
    );

    // 50 MHz clock generation (20ns period)
    always #10 clk_50MHz = ~clk_50MHz;

    initial begin
        $display("=== Starting Racing Monkey Verilog Testbench ===");
        clk_50MHz = 0;
        reset = 1;
        btn_jump = 0;
        btn_duck = 0;
        btn_start = 0;

        #100;
        reset = 0;
        #100;
        btn_start = 1;
        #20;
        btn_start = 0;

        // Simulate jump button press
        #50000;
        btn_jump = 1;
        #1000;
        btn_jump = 0;

        // Run simulation for 1 full VGA frame (~16.6 ms)
        #16600000;
        $display("Frame Complete - HSYNC: %b, VSYNC: %b", vga_hsync, vga_vsync);
        $finish;
    end

endmodule
