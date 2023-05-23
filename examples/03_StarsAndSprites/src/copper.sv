`default_nettype none

// -----------------------------------------------------------------------------------
// -- Simple copper
module copper #(

    // -- Parameters
    parameter COORD_WIDTH = 16,                     // -- screen coordinate width in bits

    parameter COLOR_A = 24'h112255,                 // -- initial color A
    parameter COLOR_B = 24'h442211,                 // -- initial color B

    parameter START_COLOR_A = 0,                    // -- 1st line of color A
    parameter START_COLOR_B = 80,                    // -- 1st line of color B

    parameter LINE_INC = 2) (                       // -- lines of each color

    // -- Inputs
    input wire logic reset_n,                       // -- reset on negative edge
    input wire logic hsync,                         // -- horizontal sync if high
    input wire logic signed [COORD_WIDTH-1:0] y,    // -- current vertical screen position
    
    // -- Outputs
    output logic [23:0] color_rgb);                 // -- 24 bit color (8-bit per channel)
       
    // -- Local parameters
    localparam LINE_INC_WIDTH = $clog2(LINE_INC);
    
    // -- Variables
    logic [LINE_INC_WIDTH-1:0] line_counter;

    // -- Sequential part
    always_ff @(posedge hsync or negedge reset_n) begin
        if (~reset_n) begin
            line_counter <= 0;
            
            color_rgb <= COLOR_A;
        end else begin
            if (y == START_COLOR_A) begin
                line_counter <= 0;
                
                color_rgb <= COLOR_A;
            end else if (y == START_COLOR_B) begin
                line_counter <= 0;
                
                color_rgb <= COLOR_B;
            end else begin
                line_counter <= line_counter + 1;

                if (line_counter == LINE_INC_WIDTH'(LINE_INC-1)) begin
                    line_counter <= 0;
                    
                    color_rgb <= color_rgb + 24'h111111;
                end
            end
        end
    end

endmodule
