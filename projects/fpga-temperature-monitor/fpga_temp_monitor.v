// ============================================================================
// Module Name:  fpga_temp_monitor
// Project:      Real-Time Temperature Monitoring System Using FPGA
// Institution:  UET Peshawar - Computer Systems Engineering (DSD Lab)
// Authors:      Faizan (22PWCSE2134), Anees, Waqas, Zeeshan
// Description:  Verilog HDL module for Spartan-6 FPGA. Interfacing with LM35
//               temperature sensor via MCP3008 SPI ADC, driving a 4-digit
//               7-segment display, and triggering threshold-based alerts.
// ============================================================================

`timescale 1ns / 1ps

module fpga_temp_monitor (
    input  wire        clk,           // Master 50 MHz Clock
    input  wire        reset,         // Active-high Reset
    input  wire        miso,          // SPI MISO from MCP3008 ADC
    output reg         mosi,          // SPI MOSI to MCP3008 ADC
    output reg         sclk,          // SPI Serial Clock (approx 1 MHz)
    output reg         cs_n,          // SPI Chip Select (Active Low)
    output reg  [3:0]  seg_anode,     // 7-segment Anode Selects (Active Low)
    output reg  [7:0]  seg_cathode,   // 7-segment Cathodes (a-g, dp) (Active Low)
    output reg         warn_led,      // Warning LED (Temp >= 45°C)
    output reg         alarm_led,     // Critical Alarm LED (Temp >= 75°C)
    output reg         buzzer         // Piezo Alarm Siren PWM
);

    // ------------------------------------------------------------------------
    // Parameters & Thresholds
    // ------------------------------------------------------------------------
    parameter WARN_THRESH  = 8'd45;   // 45°C Warning Threshold
    parameter ALARM_THRESH = 8'd75;   // 75°C Critical Threshold

    // Clock Dividers
    // 50 MHz to 1 MHz SCLK (div by 50 -> 25 cycles per edge)
    reg [5:0] clk_div = 6'd0;
    reg       spi_clk_tick = 1'b0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_div <= 6'd0;
            spi_clk_tick <= 1'b0;
        end else if (clk_div == 6'd24) begin
            clk_div <= 6'd0;
            spi_clk_tick <= 1'b1;
        end else begin
            clk_div <= clk_div + 1'b1;
            spi_clk_tick <= 1'b0;
        end
    end

    // ------------------------------------------------------------------------
    // SPI Master State Machine for MCP3008 Channel 0 (Single-Ended)
    // Send Start bit (1), Single mode bit (1), Channel D2 D1 D0 (0 0 0)
    // ------------------------------------------------------------------------
    localparam IDLE      = 3'd0;
    localparam START     = 3'd1;
    localparam TRANSMIT  = 3'd2;
    localparam SAMPLE    = 3'd3;
    localparam LATCH     = 3'd4;

    reg [2:0]  state = IDLE;
    reg [4:0]  bit_cnt = 5'd0;
    reg [4:0]  tx_data = 5'b11000; // Start=1, SGL=1, CH0=000
    reg [9:0]  adc_raw = 10'd0;
    reg [9:0]  adc_shift = 10'd0;
    reg [7:0]  temp_celsius = 8'd0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state        <= IDLE;
            cs_n         <= 1'b1;
            sclk         <= 1'b0;
            mosi         <= 1'b0;
            bit_cnt      <= 5'd0;
            adc_raw      <= 10'd0;
            adc_shift    <= 10'd0;
            temp_celsius <= 8'd0;
        end else if (spi_clk_tick) begin
            case (state)
                IDLE: begin
                    cs_n    <= 1'b1;
                    sclk    <= 1'b0;
                    bit_cnt <= 5'd0;
                    state   <= START;
                end

                START: begin
                    cs_n    <= 1'b0; // Lower CS
                    sclk    <= 1'b0;
                    mosi    <= tx_data[4];
                    bit_cnt <= 5'd4;
                    state   <= TRANSMIT;
                end

                TRANSMIT: begin
                    sclk <= ~sclk;
                    if (sclk == 1'b1) begin // Falling edge: update MOSI
                        if (bit_cnt > 0) begin
                            bit_cnt <= bit_cnt - 1'b1;
                            mosi    <= tx_data[bit_cnt - 1];
                        end else begin
                            bit_cnt <= 5'd11; // 1 null bit + 10 data bits
                            state   <= SAMPLE;
                        end
                    end
                end

                SAMPLE: begin
                    sclk <= ~sclk;
                    if (sclk == 1'b0) begin // Rising edge: sample MISO
                        if (bit_cnt > 0) begin
                            adc_shift <= {adc_shift[8:0], miso};
                            bit_cnt   <= bit_cnt - 1'b1;
                        end else begin
                            state <= LATCH;
                        end
                    end
                end

                LATCH: begin
                    cs_n      <= 1'b1;
                    adc_raw   <= adc_shift;
                    // MCP3008 10-bit Vref=3.3V -> LM35 10mV/°C
                    // Temp = (ADC * 3300) / (1024 * 10) = (ADC * 330) / 1024 approx ADC * 0.322
                    temp_celsius <= (adc_shift * 10'd322) / 1000;
                    state        <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

    // ------------------------------------------------------------------------
    // Alert & Siren Logic
    // ------------------------------------------------------------------------
    reg [15:0] buzzer_cnt = 16'd0;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            warn_led   <= 1'b0;
            alarm_led  <= 1'b0;
            buzzer     <= 1'b0;
            buzzer_cnt <= 16'd0;
        end else begin
            warn_led  <= (temp_celsius >= WARN_THRESH);
            alarm_led <= (temp_celsius >= ALARM_THRESH);

            if (temp_celsius >= ALARM_THRESH) begin
                buzzer_cnt <= buzzer_cnt + 1'b1;
                // Generate 2 kHz tone from 50 MHz clock (12,500 cycles per half period)
                if (buzzer_cnt >= 16'd12500) begin
                    buzzer     <= ~buzzer;
                    buzzer_cnt <= 16'd0;
                end
            end else begin
                buzzer     <= 1'b0;
                buzzer_cnt <= 16'd0;
            end
        end
    end

    // ------------------------------------------------------------------------
    // BCD Conversion & 4-Digit 7-Segment Multiplexer
    // Display format: [ Tens ] [ Ones ] [ ° ] [ C ]
    // ------------------------------------------------------------------------
    reg [3:0] tens_digit;
    reg [3:0] ones_digit;

    always @(*) begin
        tens_digit = (temp_celsius / 10) % 10;
        ones_digit = temp_celsius % 10;
    end

    reg [16:0] refresh_cnt = 17'd0;
    reg [1:0]  digit_select = 2'd0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            refresh_cnt  <= 17'd0;
            digit_select <= 2'd0;
        end else begin
            refresh_cnt <= refresh_cnt + 1'b1;
            digit_select <= refresh_cnt[16:15]; // Refresh rate ~380 Hz
        end
    end

    // 7-Segment Cathode Decoder (Active Low)
    function [7:0] decode_7seg(input [3:0] val);
        case (val)
            4'h0: decode_7seg = 8'b1100_0000; // 0
            4'h1: decode_7seg = 8'b1111_1001; // 1
            4'h2: decode_7seg = 8'b1010_0100; // 2
            4'h3: decode_7seg = 8'b1011_0000; // 3
            4'h4: decode_7seg = 8'b1001_1001; // 4
            4'h5: decode_7seg = 8'b1001_0010; // 5
            4'h6: decode_7seg = 8'b1000_0010; // 6
            4'h7: decode_7seg = 8'b1111_1000; // 7
            4'h8: decode_7seg = 8'b1000_0000; // 8
            4'h9: decode_7seg = 8'b1001_0000; // 9
            4'hA: decode_7seg = 8'b1001_1100; // Degree symbol °
            4'hC: decode_7seg = 8'b1100_0110; // 'C'
            default: decode_7seg = 8'b1111_1111;
        endcase
    endfunction

    always @(*) begin
        case (digit_select)
            2'b00: begin
                seg_anode   = 4'b1110; // Digit 0 (Tens)
                seg_cathode = decode_7seg(tens_digit);
            end
            2'b01: begin
                seg_anode   = 4'b1101; // Digit 1 (Ones)
                seg_cathode = decode_7seg(ones_digit);
            end
            2'b10: begin
                seg_anode   = 4'b1011; // Digit 2 (°)
                seg_cathode = decode_7seg(4'hA);
            end
            2'b11: begin
                seg_anode   = 4'b0111; // Digit 3 (C)
                seg_cathode = decode_7seg(4'hC);
            end
        endcase
    end

endmodule
