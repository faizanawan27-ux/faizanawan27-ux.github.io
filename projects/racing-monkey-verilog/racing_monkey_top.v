// ============================================================================
// Module Name:  racing_monkey_top
// Project:      Racing Monkey Endless Runner (Verilog FPGA Arcade Game)
// Institution:  UET Peshawar - Computer Systems Engineering
// Author:       Faizan (22PWCSE2134)
// Description:  Top-level FPGA module linking 25MHz VGA clock divider,
//               640x480 VGA controller, player control FSM, collision engine,
//               and RGB color rendering outputs.
// ============================================================================

`timescale 1ns / 1ps

module racing_monkey_top (
    input  wire       clk_50MHz,    // 50 MHz Master Clock input
    input  wire       reset,        // Reset button (Active High)
    input  wire       btn_jump,     // Jump button input
    input  wire       btn_duck,     // Duck/Crouch button input
    input  wire       btn_start,    // Start/Restart button input
    output wire       vga_hsync,    // Horizontal Sync
    output wire       vga_vsync,    // Vertical Sync
    output wire [3:0] vga_red,      // Red 4-bit DAC
    output wire [3:0] vga_green,    // Green 4-bit DAC
    output wire [3:0] vga_blue,     // Blue 4-bit DAC
    output wire [3:0] score_anode,  // 7-segment score anode select
    output wire [7:0] score_cathode // 7-segment score cathodes
);

    // ------------------------------------------------------------------------
    // Clock Divider: 50 MHz to 25 MHz Pixel Clock
    // ------------------------------------------------------------------------
    reg clk_25MHz = 1'b0;
    always @(posedge clk_50MHz or posedge reset) begin
        if (reset)
            clk_25MHz <= 1'b0;
        else
            clk_25MHz <= ~clk_25MHz;
    end

    // ------------------------------------------------------------------------
    // VGA Controller Signals
    // ------------------------------------------------------------------------
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;
    wire       video_on;

    vga_controller vga_inst (
        .clk_25MHz(clk_25MHz),
        .reset(reset),
        .hsync(vga_hsync),
        .vsync(vga_vsync),
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    // ------------------------------------------------------------------------
    // Game Logic & Renderer Instance
    // ------------------------------------------------------------------------
    monkey_game_logic game_inst (
        .clk_25MHz(clk_25MHz),
        .reset(reset),
        .btn_jump(btn_jump),
        .btn_duck(btn_duck),
        .btn_start(btn_start),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .video_on(video_on),
        .red(vga_red),
        .green(vga_green),
        .blue(vga_blue),
        .score_anode(score_anode),
        .score_cathode(score_cathode)
    );

endmodule
