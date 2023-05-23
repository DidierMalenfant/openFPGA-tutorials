`default_nettype none

// -----------------------------------------------------------------------------------
// -- Starfields
module starfields #(

    // -- Parameters
    parameter WIDTH = 400,
    parameter HEIGHT = 512) (

    // -- Inputs
    input wire logic reset_n,               // -- reset on negative edge
    input wire logic pixel_clock,           // -- pixel clock
    
    // -- Outputs
    output wire logic [23:0] pixel_rgb);    // -- pixel rgb value
    
    // -- Variables
    wire logic sf1_on, sf2_on, sf3_on;
    wire logic [7:0] sf1_star, sf2_star, sf3_star;
    wire logic [7:0] starlight;
    
    // -- Combinatorial part
    assign starlight = (sf1_on) ? sf1_star[7:0] :
                       (sf2_on) ? sf2_star[7:0] :
                       (sf3_on) ? sf3_star[7:0] : 8'h0;
    assign pixel_rgb = { starlight, starlight, starlight };
    
    // -- Modules
    starfield #(.WIDTH(WIDTH), .HEIGHT(HEIGHT), .INC(-1), .SEED(21'h9A9A9)) sf1 (
        .reset_n(reset_n),
        .pixel_clock(pixel_clock),
        .onoff(sf1_on),
        .brightness(sf1_star)
    );
    starfield #(.WIDTH(WIDTH), .HEIGHT(HEIGHT), .INC(-2), .SEED(21'hA9A9A)) sf2 (
        .reset_n(reset_n),
        .pixel_clock(pixel_clock),
        .onoff(sf2_on),
        .brightness(sf2_star)
    );
    starfield #(.WIDTH(WIDTH), .HEIGHT(HEIGHT), .INC(-4), .MASK(21'h7FF)) sf3 (
        .reset_n(reset_n),
        .pixel_clock(pixel_clock),
        .onoff(sf3_on),
        .brightness(sf3_star)
    );

endmodule
