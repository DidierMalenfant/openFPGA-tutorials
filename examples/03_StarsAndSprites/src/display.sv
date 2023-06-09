`default_nettype none

// -----------------------------------------------------------------------------------
// -- handles putting all the screen elements togegther
module display (

    // -- Inputs
    input wire reset_n,                 // -- reset on negative edge
    input wire pixel_clock,             // -- pixel clock
    
    // -- Outputs
    output logic [23:0] video_rgb,      // -- pixel rgb value
    output logic video_enable,          // -- video enable if high
    output logic vsync_start,           // -- vsync if high
    output logic hsync_start);          // -- hsync if high
    
    // -- Local parameters
    localparam COORD_WIDTH = 16;

    // -- With a ~12,288,000 hz pixel clock, we want our video mode of 400x360@50hz, this results in 245760 clocks per frame.
    // -- We need to add hblank and vblank times to this, so there will be a nondisplay area. It can be thought of as a border
    // -- around the visible area.
    //    
    // -- To make numbers simple, we can have 480 total clocks per line, and 400 visible. Dividing 204800 by 400 results in
    // -- 512 total lines per frame, and 400 visible. This pixel clock is fairly high for the relatively low resolution,
    // -- but that's fine. PLL output has a minimum output frequency anyway.
    
    localparam HORIZONTAL_TOTAL = 480;
    localparam VERTICAL_TOTAL = 512;

    localparam HORIZONTAL_RESOLUTION = 400;    
    localparam VERTICAL_RESOLUTION = 360;

    localparam SPRITES_Y_POSITION = 150;

    // -- Variables
    logic signed [COORD_WIDTH-1:0] x, y;
    
    wire [23:0] star_rgb;

    logic [23:0] copper_rgb;

    wire spr_pixel_on;

    // -- Combinational part
    always_comb begin
        // -- Inactive screen areas are black
        video_rgb = video_enable ? (spr_pixel_on ? copper_rgb : star_rgb) : { 8'd0, 8'd0, 8'd0 };
    end

    // -----------------------------------------------------------------------------------
    // -- Modules

    video_sync #(.COORD_WIDTH(COORD_WIDTH),
                 .HORIZONTAL_TOTAL(HORIZONTAL_TOTAL), .VERTICAL_TOTAL(VERTICAL_TOTAL),
                 .HORIZONTAL_RESOLUTION(HORIZONTAL_RESOLUTION), .VERTICAL_RESOLUTION(VERTICAL_RESOLUTION),
                 .HORIZONTAL_BACK_PORCH(10), .VERTICAL_BACK_PORCH(10)) vid (
       .reset_n(reset_n),
       .pixel_clock(pixel_clock),
       .x(x),
       .y(y),
       .video_enable(video_enable),
       .vsync_start(vsync_start),
       .hsync_start(hsync_start),
       /* verilator lint_off PINCONNECTEMPTY */
       .frame_count()
       /* verilator lint_on PINCONNECTEMPTY */
    );

    starfields #(.WIDTH(HORIZONTAL_TOTAL), .HEIGHT(VERTICAL_TOTAL)) stars (
        .reset_n(reset_n),
        .pixel_clock(pixel_clock),
        .pixel_rgb(star_rgb)
    );

    copper #(.COORD_WIDTH(COORD_WIDTH),
             .COLOR_A(24'h112255),
             .COLOR_B(24'h442211),
             .START_COLOR_A(SPRITES_Y_POSITION),
             .START_COLOR_B(SPRITES_Y_POSITION + 30),
             .LINE_INC(3)) cop (
        .reset_n(reset_n),
        .hsync(hsync_start),
        .y(y),
        .color_rgb(copper_rgb)
    );
    
    sprites #(.COORD_WIDTH(COORD_WIDTH), .SPR_X(80), .SPR_Y(SPRITES_Y_POSITION)) sprs (
        .reset_n(reset_n),
        .pixel_clock(pixel_clock),
        .hsync_start(hsync_start),
        .x(x),
        .y(y),
        .pixel_on(spr_pixel_on)
    );

endmodule
