// ============================================================================
// Module Name:  vga_controller
// Project:      Racing Monkey VGA Timing Generator
// Author:       Faizan (22PWCSE2134)
// Description:  Standard 640x480 @ 60Hz VGA Sync Generator (25 MHz pixel clock).
// ============================================================================

`timescale 1ns / 1ps

module vga_controller (
    input  wire       clk_25MHz,  // 25 MHz Pixel Clock
    input  wire       reset,      // Active High Reset
    output wire       hsync,      // Horizontal Sync
    output wire       vsync,      // Vertical Sync
    output wire       video_on,   // Active Video Region Flag
    output reg  [9:0] pixel_x,    // Current Pixel X coordinate (0-639)
    output reg  [9:0] pixel_y     // Current Pixel Y coordinate (0-479)
);

    // VGA 640x480 @ 60Hz Timing Constants
    parameter HD = 640; // Horizontal Display Width
    parameter HF = 16;  // Horizontal Front Porch
    parameter HR = 96;  // Horizontal Retrace Pulse Width
    parameter HB = 48;  // Horizontal Back Porch
    parameter HT = 800; // Total Horizontal Pixels

    parameter VD = 480; // Vertical Display Height
    parameter VF = 10;  // Vertical Front Porch
    parameter VR = 2;   // Vertical Retrace Pulse Width
    parameter VB = 33;  // Vertical Back Porch
    parameter VT = 525; // Total Vertical Lines

    // Counters
    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    always @(posedge clk_25MHz or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == HT - 1) begin
                h_count <= 0;
                if (v_count == VT - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    // Sync Pulses (Active Low)
    assign hsync = ~((h_count >= (HD + HF)) && (h_count < (HD + HF + HR)));
    assign vsync = ~((v_count >= (VD + VF)) && (v_count < (VD + VF + VR)));

    // Active Video Area
    assign video_on = (h_count < HD) && (v_count < VD);

    always @(*) begin
        pixel_x = (h_count < HD) ? h_count : 10'd0;
        pixel_y = (v_count < VD) ? v_count : 10'd0;
    end

endmodule
