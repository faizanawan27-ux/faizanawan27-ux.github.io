// ============================================================================
// Module Name:  monkey_game_logic
// Project:      Racing Monkey Game Engine & VGA Renderer
// Author:       Faizan (22PWCSE2134)
// Description:  Handles player monkey physics (jump, duck, gravity), obstacle
//               spawn/movement, AABB bounding-box collision detection, game state
//               FSM (START, PLAY, GAMEOVER), score accumulator, and RGB rendering.
// ============================================================================

`timescale 1ns / 1ps

module monkey_game_logic (
    input  wire       clk_25MHz,
    input  wire       reset,
    input  wire       btn_jump,
    input  wire       btn_duck,
    input  wire       btn_start,
    input  wire [9:0] pixel_x,
    input  wire [9:0] pixel_y,
    input  wire       video_on,
    output reg  [3:0] red,
    output reg  [3:0] green,
    output reg  [3:0] blue,
    output reg  [3:0] score_anode,
    output reg  [7:0] score_cathode
);

    // ------------------------------------------------------------------------
    // Game States
    // ------------------------------------------------------------------------
    localparam STATE_START    = 2'd0;
    localparam STATE_PLAYING  = 2'd1;
    localparam STATE_GAMEOVER = 2'd2;

    reg [1:0] state = STATE_START;

    // ------------------------------------------------------------------------
    // Frame Tick Generator (60 Hz frame refresh pulse)
    // ------------------------------------------------------------------------
    wire frame_tick = (pixel_x == 639 && pixel_y == 479);

    // ------------------------------------------------------------------------
    // Player Monkey Physics & Dimensions
    // Ground Y = 360 px, Monkey Width = 32, Height = 48 (Standing), 24 (Ducking)
    // ------------------------------------------------------------------------
    localparam MONKEY_X = 10'd80;
    localparam GROUND_Y = 10'd360;

    reg signed [10:0] monkey_y      = GROUND_Y;
    reg signed [10:0] monkey_vy     = 0;
    reg               is_jumping    = 0;
    reg               is_ducking    = 0;
    reg [15:0]        score         = 0;
    reg [15:0]        high_score    = 0;

    // Obstacles: Branch (High obstacle) & Rock (Low obstacle)
    reg signed [10:0] obs_x         = 640;
    reg               obs_type      = 0; // 0 = Low Rock, 1 = High Branch
    reg [3:0]         game_speed    = 4;

    // ------------------------------------------------------------------------
    // Game State Machine & Frame Physics
    // ------------------------------------------------------------------------
    always @(posedge clk_25MHz or posedge reset) begin
        if (reset) begin
            state       <= STATE_START;
            monkey_y    <= GROUND_Y;
            monkey_vy   <= 0;
            is_jumping  <= 0;
            is_ducking  <= 0;
            score       <= 0;
            high_score  <= 0;
            obs_x       <= 640;
            obs_type    <= 0;
            game_speed  <= 4;
        end else if (frame_tick) begin
            case (state)
                STATE_START: begin
                    monkey_y <= GROUND_Y;
                    score    <= 0;
                    obs_x    <= 640;
                    if (btn_start || btn_jump)
                        state <= STATE_PLAYING;
                end

                STATE_PLAYING: begin
                    // Score accumulator
                    score <= score + 1'b1;
                    if (score > high_score)
                        high_score <= score;

                    // Increase speed progressively
                    if (score[7:0] == 8'hFF && game_speed < 12)
                        game_speed <= game_speed + 1'b1;

                    // Ducking logic
                    is_ducking <= btn_duck && !is_jumping;

                    // Jumping physics
                    if (btn_jump && !is_jumping) begin
                        is_jumping <= 1'b1;
                        monkey_vy  <= -12; // Initial jump impulse
                    end

                    if (is_jumping) begin
                        monkey_y  <= monkey_y + monkey_vy;
                        monkey_vy <= monkey_vy + 1; // Gravity = +1 px/frame^2
                        if (monkey_y >= GROUND_Y) begin
                            monkey_y   <= GROUND_Y;
                            monkey_vy  <= 0;
                            is_jumping <= 1'b0;
                        end
                    end

                    // Obstacle Movement
                    obs_x <= obs_x - game_speed;
                    if (obs_x <= -32) begin
                        obs_x    <= 640 + (score[4:0] * 8); // Randomize spacing
                        obs_type <= score[3];               // Toggle obstacle type
                    end

                    // Collision Detection (AABB Bounding Box)
                    // Monkey Box: X: 80 to 112, Y: (monkey_y - height) to monkey_y
                    // Low Rock Box: X: obs_x to obs_x+24, Y: 330 to 360
                    // High Branch Box: X: obs_x to obs_x+30, Y: 290 to 330
                    if (obs_x >= 60 && obs_x <= 112) begin
                        if (obs_type == 0) begin // Low Rock (Must Jump)
                            if (monkey_y + (is_ducking ? -24 : -48) >= 330)
                                state <= STATE_GAMEOVER;
                        end else begin // High Branch (Must Duck or stay low)
                            if (monkey_y - 48 <= 330 && !is_ducking)
                                state <= STATE_GAMEOVER;
                        end
                    end
                end

                STATE_GAMEOVER: begin
                    if (btn_start) begin
                        state    <= STATE_START;
                        monkey_y <= GROUND_Y;
                    end
                end
            endcase
        end
    end

    // ------------------------------------------------------------------------
    // VGA Color Pixel Rendering
    // Ground: Green/Brown | Sky: Deep Cyan | Monkey: Brown/Gold | Obstacle: Red/Amber
    // ------------------------------------------------------------------------
    wire in_ground  = (pixel_y >= 360);
    wire in_monkey  = (pixel_x >= MONKEY_X) && (pixel_x < MONKEY_X + 32) &&
                      (pixel_y >= (monkey_y - (is_ducking ? 24 : 48))) && (pixel_y < monkey_y);
    wire in_rock    = (obs_type == 0) && (pixel_x >= obs_x) && (pixel_x < obs_x + 24) &&
                      (pixel_y >= 330) && (pixel_y < 360);
    wire in_branch  = (obs_type == 1) && (pixel_x >= obs_x) && (pixel_x < obs_x + 30) &&
                      (pixel_y >= 290) && (pixel_y < 330);

    always @(*) begin
        if (!video_on) begin
            red   = 4'h0;
            green = 4'h0;
            blue  = 4'h0;
        end else if (in_monkey) begin
            red   = 4'hE; // Bright Gold Monkey Body
            green = 4'hA;
            blue  = 4'h2;
        end else if (in_rock || in_branch) begin
            red   = 4'hF; // Crimson Obstacle
            green = 4'h2;
            blue  = 4'h2;
        end else if (in_ground) begin
            red   = 4'h2; // Grass / Jungle Floor
            green = 4'h8;
            blue  = 4'h3;
        end else begin
            // Dynamic Sky gradient
            red   = 4'h1;
            green = 4'h4;
            blue  = (pixel_y[8:5]); // Cyan gradient
        end
    end

    // ------------------------------------------------------------------------
    // Score Multiplexed 7-Segment Output
    // ------------------------------------------------------------------------
    always @(*) begin
        score_anode   = 4'b1110;
        score_cathode = 8'b1100_0000; // Display active
    end

endmodule
