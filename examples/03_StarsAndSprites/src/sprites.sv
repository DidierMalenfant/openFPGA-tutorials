`default_nettype none

// -----------------------------------------------------------------------------------
// -- Sprites
module sprites #(

    // -- Parameters
    parameter COORD_WIDTH = 16,
    parameter signed SPR_X = 10,      // -- sprites' coordinates
    parameter signed SPR_Y = 10) (    

    // -- Inputs
    input wire logic reset_n,                       // -- reset on negative edge
    input wire logic pixel_clock,                   // -- pixel clock
    input wire logic hsync_start,                   // -- hsync if high

    input wire logic signed [COORD_WIDTH-1:0] x,
    input wire logic signed [COORD_WIDTH-1:0] y,

    // -- Outputs
    output wire logic pixel_on);
    
    // -- Local Parameters
    localparam SPR_CNT = 4;                         // -- number of sprites
    localparam SPR_SCALE_X = 8;                     // -- enlarge sprite width by this factor
    localparam SPR_SCALE_Y = 8;                     // -- enlarge sprite height by this factor
    localparam SPR_DMA = 0 - (2 * SPR_CNT);         // -- start sprite DMA in h-blanking

    localparam integer SPR_XS[SPR_CNT] = '{
        SPR_X,
        SPR_X + 1 * 60,
        SPR_X + 2 * 60,
        SPR_X + 3 * 60
    };

    localparam integer SPR_CP_NORM[SPR_CNT] = '{ 
        // -- Subtract 0x20 from code points as font starts at U+0020
        'h26,  // -- U+0046 (F)
        'h30,  // -- U+0050 (P)
        'h27,  // -- U+0047 (G)
        'h21   // -- U+002D (A)
    };

    // -- Variables
    wire logic spr_start;                                       // -- signal to start sprite drawing
   
    logic [FONT_ROM_ADDR_WIDTH-1:0] spr_glyph_line[SPR_CNT];    // -- font ROM address
    logic [SPR_CNT-1:0] spr_fdma;                               // -- font ROM DMA slots
    
    wire logic [SPR_CNT-1:0] pixels_on;                         // -- sprites pixel on or off

    integer i;                                                  // -- for looping over sprite signals

    // -- Combinatorial part
    assign spr_start = (hsync_start && y == SPR_Y);
    assign pixel_on = (pixels_on != 0);

    always_comb begin
        font_rom_addr = 0;
        
        for (i = 0; i < SPR_CNT; i = i + 1) begin
             // -- DMA in blanking
            spr_fdma[i] = (x == COORD_WIDTH'(SPR_DMA + i));

            if (spr_fdma[i]) begin
                font_rom_addr = FONT_ROM_ADDR_WIDTH'(FONT_HEIGHT) * FONT_ROM_ADDR_WIDTH'(SPR_CP_NORM[i]) + spr_glyph_line[i];
            end
        end
    end

    genvar m;
    generate for (m = 0; m < SPR_CNT; m = m + 1) begin : sprite_gen
        sprite #(.WIDTH(FONT_WIDTH), .HEIGHT(FONT_HEIGHT), .SCALE_X(SPR_SCALE_X), .SCALE_Y(SPR_SCALE_Y), .LSB(0), .COORD_WIDTH(COORD_WIDTH), .ADDR_WIDTH(FONT_ROM_ADDR_WIDTH)) spr0 (
            .reset_n(reset_n),
            .pixel_clock(pixel_clock),
            .start(spr_start),
            .dma_avail(spr_fdma[m]),
            .sx(x),
            .spr_x(COORD_WIDTH'(SPR_XS[m])),
            .data(font_rom_data),
            .pos(spr_glyph_line[m]),
            .pixel_on(pixels_on[m]),
            /* verilator lint_off PINCONNECTEMPTY */
            .drawing(),
            .done()
            /* verilator lint_on PINCONNECTEMPTY */
        );
    end endgenerate

    // -----------------------------------------------------------------------------------
    // -- Font glyph ROM
    
    // -- Local Parameters
    localparam FONT_WIDTH = 8;                              // -- width in pixels (also ROM width)
    localparam FONT_HEIGHT = 8;                             // -- height in pixels
    localparam FONT_GLYPHS = 64;                            // -- number of glyphs
    localparam FONT_ROM_DEPTH = FONT_GLYPHS * FONT_HEIGHT;
    localparam FONT_ROM_ADDR_WIDTH = $clog2(FONT_ROM_DEPTH);
    localparam FONT_FILE = "assets/font_unscii_8x8_latin_uc.txt";
    
    // -- Variables
    logic [FONT_ROM_ADDR_WIDTH-1:0] font_rom_addr;
    wire logic [FONT_WIDTH-1:0] font_rom_data;              // -- line of glyph pixels
    
    // -- Modules
    rom_sync #(.WIDTH(FONT_WIDTH), .DEPTH(FONT_ROM_DEPTH), .INIT_FILE(FONT_FILE)) font_rom (
        .clock(pixel_clock),
        .addr(font_rom_addr),
        .data(font_rom_data)
    );
    
endmodule
