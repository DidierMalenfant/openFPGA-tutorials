`default_nettype none

// -----------------------------------------------------------------------------------
// -- Video syncing signals generator
module video_sync #(

    // -- Parameters
    parameter COORD_WIDTH = 16,                       // -- screen coordinate width in bits

    parameter HORIZONTAL_TOTAL = 400,
    parameter VERTICAL_TOTAL = 512,

    parameter HORIZONTAL_RESOLUTION = 320,
    parameter VERTICAL_RESOLUTION = 240,

    parameter HORIZONTAL_BACK_PORCH = 15,
    parameter VERTICAL_BACK_PORCH = 15) (

    // -- Inputs
    input wire reset_n,                               // -- reset on negative edge
    input wire pixel_clock,                           // -- pixel clock
    
    // -- Outputs
    output logic signed [COORD_WIDTH-1:0] x, y,
    output logic [15:0] frame_count,

    output logic video_enable,                        // -- video enable if high
    output logic vsync_start,                         // -- vsync if high
    output logic hsync_start);                        // -- hsync if high
    
    // -- Local parameters
    localparam signed HORIZONTAL_START = -HORIZONTAL_BACK_PORCH;
    localparam signed HORIZONTAL_END = HORIZONTAL_START + HORIZONTAL_TOTAL - 1;

    localparam signed VERTICAL_START = -VERTICAL_BACK_PORCH;
    localparam signed VERTICAL_END = VERTICAL_START + VERTICAL_TOTAL - 1;
    
    // -- Sequential part
    always_ff @(posedge pixel_clock or negedge reset_n) begin
        if (~reset_n) begin
            x <= HORIZONTAL_START;
            y <= VERTICAL_START;
    
            video_enable <= 0;
            vsync_start <= 0;
            hsync_start <= 0;
        end else begin
            video_enable <= 0;
            vsync_start <= 0;
            hsync_start <= 0;
            
            x <= x + 1'b1;
            if (x == HORIZONTAL_END) begin
                x <= HORIZONTAL_START;
    
                y <= y + 1'b1;
                if (y == VERTICAL_END) begin
                    y <= VERTICAL_START;
    
                    // -- generate Vsync signal in back porch
                    vsync_start <= 1;
    
                    // -- new frame
                    frame_count <= frame_count + 1'b1;
                end
            end else begin
                // -- generate HSync to occur a bit after VS, not on the same cycle
                if (x == (HORIZONTAL_START + 3)) begin
                    hsync_start <= 1;
                end
            end

            // -- generate active video
            if (x >= 0 && x < HORIZONTAL_RESOLUTION) begin
                if (y >= 0 && y < VERTICAL_RESOLUTION) begin
                    // -- video enable. this is the active region of the line
                    video_enable <= 1;
                end 
            end
        end
    end

endmodule
