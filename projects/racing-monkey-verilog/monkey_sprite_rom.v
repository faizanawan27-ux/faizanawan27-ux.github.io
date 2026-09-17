// ============================================================================
// Module Name:  monkey_sprite_rom
// Project:      Racing Monkey Sprite Pattern ROM
// Author:       Faizan (22PWCSE2134)
// Description:  Bitwise ROM storing 16x16 pixel matrix patterns for player
//               monkey, jungle rock, and overhead branch obstacles.
// ============================================================================

`timescale 1ns / 1ps

module monkey_sprite_rom (
    input  wire [3:0] sprite_row, // Row 0-15
    input  wire [3:0] sprite_col, // Col 0-15
    input  wire [1:0] sprite_sel, // 00=Monkey, 01=Rock, 10=Branch
    output reg        pixel_bit
);

    // 16x16 Bitmaps
    reg [15:0] monkey_bitmap [0:15];
    reg [15:0] rock_bitmap   [0:15];
    reg [15:0] branch_bitmap [0:15];

    initial begin
        // Monkey Character Bitmap (16x16)
        monkey_bitmap[0]  = 16'b0000_0111_1100_0000;
        monkey_bitmap[1]  = 16'b0000_1111_1110_0000;
        monkey_bitmap[2]  = 16'b0001_1001_1001_0000;
        monkey_bitmap[3]  = 16'b0001_1111_1111_0000;
        monkey_bitmap[4]  = 16'b0000_0111_1100_0000;
        monkey_bitmap[5]  = 16'b0011_1111_1111_1000;
        monkey_bitmap[6]  = 16'b0111_1111_1111_1100;
        monkey_bitmap[7]  = 16'b0111_1111_1111_1100;
        monkey_bitmap[8]  = 16'b0111_1111_1111_1100;
        monkey_bitmap[9]  = 16'b0011_1111_1111_1000;
        monkey_bitmap[10] = 16'b0000_1111_1100_0000;
        monkey_bitmap[11] = 16'b0001_1000_0110_0000;
        monkey_bitmap[12] = 16'b0001_1000_0110_0000;
        monkey_bitmap[13] = 16'b0011_0000_0011_0000;
        monkey_bitmap[14] = 16'b0011_0000_0011_0000;
        monkey_bitmap[15] = 16'b0111_0000_0011_1000;

        // Rock Obstacle Bitmap (16x16)
        rock_bitmap[0]   = 16'b0000_0000_0000_0000;
        rock_bitmap[1]   = 16'b0000_0000_0000_0000;
        rock_bitmap[2]   = 16'b0000_0000_0000_0000;
        rock_bitmap[3]   = 16'b0000_0000_0000_0000;
        rock_bitmap[4]   = 16'b0000_0011_1100_0000;
        rock_bitmap[5]   = 16'b0000_0111_1110_0000;
        rock_bitmap[6]   = 16'b0000_1111_1111_0000;
        rock_bitmap[7]   = 16'b0001_1111_1111_1000;
        rock_bitmap[8]   = 16'b0011_1111_1111_1100;
        rock_bitmap[9]   = 16'b0111_1111_1111_1110;
        rock_bitmap[10]  = 16'b1111_1111_1111_1111;
        rock_bitmap[11]  = 16'b1111_1111_1111_1111;
        rock_bitmap[12]  = 16'b1111_1111_1111_1111;
        rock_bitmap[13]  = 16'b1111_1111_1111_1111;
        rock_bitmap[14]  = 16'b1111_1111_1111_1111;
        rock_bitmap[15]  = 16'b1111_1111_1111_1111;

        // Branch Obstacle Bitmap (16x16)
        branch_bitmap[0]  = 16'b1111_1111_1111_1111;
        branch_bitmap[1]  = 16'b1111_1111_1111_1111;
        branch_bitmap[2]  = 16'b0111_1111_1111_1110;
        branch_bitmap[3]  = 16'b0011_1100_0011_1100;
        branch_bitmap[4]  = 16'b0001_1000_0001_1000;
        branch_bitmap[5]  = 16'b0001_1000_0001_1000;
        branch_bitmap[6]  = 16'b0011_1100_0011_1100;
        branch_bitmap[7]  = 16'b0111_1110_0111_1110;
        branch_bitmap[8]  = 16'b0000_0000_0000_0000;
        branch_bitmap[9]  = 16'b0000_0000_0000_0000;
        branch_bitmap[10] = 16'b0000_0000_0000_0000;
        branch_bitmap[11] = 16'b0000_0000_0000_0000;
        branch_bitmap[12] = 16'b0000_0000_0000_0000;
        branch_bitmap[13] = 16'b0000_0000_0000_0000;
        branch_bitmap[14] = 16'b0000_0000_0000_0000;
        branch_bitmap[15] = 16'b0000_0000_0000_0000;
    end

    always @(*) begin
        case (sprite_sel)
            2'b00: pixel_bit = monkey_bitmap[sprite_row][15 - sprite_col];
            2'b01: pixel_bit = rock_bitmap[sprite_row][15 - sprite_col];
            2'b10: pixel_bit = branch_bitmap[sprite_row][15 - sprite_col];
            default: pixel_bit = 1'b0;
        endcase
    end

endmodule
