`default_nettype none

// -----------------------------------------------------------------------------------
// -- Display module - generate sync and rgb signals based on pixel clock.
module display (

    // -- Inputs
    input wire reset_n,                 // -- reset on negative edge
    input wire pixel_clock,             // -- pixel clock

    // -- Outputs
    output logic [23:0] video_rgb,      // -- pixel rgb value
    output logic video_enable,          // -- video enable if high
    output logic video_vsync,           // -- vsync if high
    output logic video_hsync);          // -- hsync if high

    // -- Local parameters
    localparam COORD_WIDTH = 16;

    // -- With a ~44,280,000 hz pixel clock, we want our video mode of 800x720 @ 60hz.
    // -- At 60 frames per second this results in 738,000 clocks per frame (44,280,000 / 60).
    // --
    // -- We need to add hblank and vblank times to this, so there will be a nondisplay area. It can be thought of as a border
    // -- around the visible area.
    // --    
    // -- To make numbers simple, We can have 900 total clocks per line, and 800 visible, which gives us 820 lines 720 visible.

    localparam signed HORIZONTAL_TOTAL = COORD_WIDTH'(900);
    localparam signed VERTICAL_TOTAL = COORD_WIDTH'(820);
    
    localparam signed HORIZONTAL_RESOLUTION = COORD_WIDTH'(800);
    localparam signed VERTICAL_RESOLUTION = COORD_WIDTH'(720);

    localparam signed HORIZONTAL_BACK_PORCH = COORD_WIDTH'(10);
    localparam signed HORIZONTAL_START = -HORIZONTAL_BACK_PORCH;
    localparam signed HORIZONTAL_END = HORIZONTAL_START + HORIZONTAL_TOTAL - 1;

    localparam signed VERTICAL_BACK_PORCH = COORD_WIDTH'(10);
    localparam signed VERTICAL_START = -VERTICAL_BACK_PORCH;
    localparam signed VERTICAL_END = VERTICAL_START + VERTICAL_TOTAL - 1;
    
    // -- Variables
    logic signed [COORD_WIDTH-1:0] x, y;
    logic [15:0] frame_count;

    // -- Sequential part
    always_ff @(posedge pixel_clock or negedge reset_n) begin
        if (~reset_n) begin
            x <= HORIZONTAL_START;
            y <= VERTICAL_START;
        
            video_enable <= 0;
            video_vsync <= 0;
            video_hsync <= 0;
        
            video_rgb <= { 8'd0, 8'd0, 8'd0 };
        end else begin
            video_enable <= 0;
            video_vsync <= 0;
            video_hsync <= 0;
            
            // -- inactive screen areas are black
            video_rgb <= { 8'd0, 8'd0, 8'd0 };
                
            x <= x + 1'b1;
            if (x == HORIZONTAL_END) begin
                x <= HORIZONTAL_START;
        
                y <= y + 1'b1;
                if (y == VERTICAL_END) begin
                    y <= VERTICAL_START;
        
                    // -- generate Vsync signal in back porch
                    video_vsync <= 1;
        
                    // -- new frame
                    frame_count <= frame_count + 1'b1;
                end
            end else begin
                // -- generate HSync to occur a bit after VS, not on the same cycle
                if (x == (HORIZONTAL_START + 3)) begin
                    video_hsync <= 1;
                end
            end
            
            // -- generate active video
            if (x >= 0 && x < HORIZONTAL_RESOLUTION) begin
                if (y >= 0 && y < VERTICAL_RESOLUTION) begin
                    // -- video enable. this is the active region of the line
                    video_enable <= 1;

                    if (x < 256 && y < 256) begin
                        video_rgb <= { { x[7:4], 4'd0 }, { y[7:4], 4'd0 }, 8'd64 };
                    end else begin
                        // -- background colour
                        video_rgb <= { 8'd0, 8'd16, 8'd48 };
                    end
                end
            end
        end
    end

endmodule
