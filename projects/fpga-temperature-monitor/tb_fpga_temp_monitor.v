// ============================================================================
// Module Name:  tb_fpga_temp_monitor
// Project:      Real-Time Temperature Monitoring System Testbench
// Institution:  UET Peshawar - Computer Systems Engineering
// Author:       Faizan (22PWCSE2134)
// Description:  Testbench simulating MCP3008 ADC response to LM35 voltages.
// ============================================================================

`timescale 1ns / 1ps

module tb_fpga_temp_monitor;

    reg        clk;
    reg        reset;
    reg        miso;
    wire       mosi;
    wire       sclk;
    wire       cs_n;
    wire [3:0] seg_anode;
    wire [7:0] seg_cathode;
    wire       warn_led;
    wire       alarm_led;
    wire       buzzer;

    // Instantiate DUT (Device Under Test)
    fpga_temp_monitor dut (
        .clk(clk),
        .reset(reset),
        .miso(miso),
        .mosi(mosi),
        .sclk(sclk),
        .cs_n(cs_n),
        .seg_anode(seg_anode),
        .seg_cathode(seg_cathode),
        .warn_led(warn_led),
        .alarm_led(alarm_led),
        .buzzer(buzzer)
    );

    // 50 MHz clock generation (20 ns period)
    always #10 clk = ~clk;

    // Simulated SPI MISO Data Shift Register
    reg [9:0] sim_adc_val = 10'd150; // Initial ~48°C

    always @(negedge sclk or posedge cs_n) begin
        if (cs_n) begin
            miso <= 1'b0;
        end else begin
            miso <= sim_adc_val[9];
            sim_adc_val <= {sim_adc_val[8:0], 1'b0};
        end
    end

    initial begin
        $display("=== Starting FPGA Temperature Monitor Testbench ===");
        clk = 0;
        reset = 1;
        miso = 0;
        #100;
        reset = 0;

        // Test normal temperature (~30°C -> ADC val 93)
        sim_adc_val = 10'd93;
        #200000;
        $display("Test 1: Temp 30°C - Warn LED: %b, Alarm LED: %b", warn_led, alarm_led);

        // Test warning threshold (~50°C -> ADC val 155)
        sim_adc_val = 10'd155;
        #200000;
        $display("Test 2: Temp 50°C - Warn LED: %b, Alarm LED: %b", warn_led, alarm_led);

        // Test critical alarm threshold (~80°C -> ADC val 248)
        sim_adc_val = 10'd248;
        #200000;
        $display("Test 3: Temp 80°C - Warn LED: %b, Alarm LED: %b, Buzzer: %b", warn_led, alarm_led, buzzer);

        $display("=== Testbench Complete ===");
        $finish;
    end

endmodule
