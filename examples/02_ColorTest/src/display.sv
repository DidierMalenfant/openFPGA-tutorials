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

    // -- With a ~12,288,000 hz pixel clock, we want our video mode of 400x360@50hz, this results in 245760 clocks per frame.
    // -- We need to add hblank and vblank times to this, so there will be a nondisplay area. It can be thought of as a border
    // -- around the visible area.
    //    
    // -- To make numbers simple, we can have 480 total clocks per line, and 400 visible. Dividing 204800 by 400 results in
    // -- 512 total lines per frame, and 400 visible. This pixel clock is fairly high for the relatively low resolution,
    // -- but that's fine. PLL output has a minimum output frequency anyway.
    
    localparam signed HORIZONTAL_TOTAL = COORD_WIDTH'(480);
    localparam signed VERTICAL_TOTAL = COORD_WIDTH'(512);
    
    localparam signed HORIZONTAL_RESOLUTION = COORD_WIDTH'(400);
    localparam signed VERTICAL_RESOLUTION = COORD_WIDTH'(360);

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
