`default_nettype none

// -----------------------------------------------------------------------------------
// -- Starfield generator using LFSRs
module starfield #(

    // -- Parameters
    parameter WIDTH = 400,
    parameter HEIGHT = 512,
    parameter INC = -1,
    parameter SEED = 21'h1FFFFF,
    parameter MASK = 21'hFFF) (
    
    // -- Inputs
    input wire logic reset_n,                                   // -- reset on negative edge
    input wire logic pixel_clock,                               // -- pixel clock
    
    // -- Outputs
    output wire logic onoff,                                    // -- star on
    output wire logic [7:0] brightness);                        // -- star brightness
    
    // -- Local parameters
    localparam COUNTER_END = 21'(WIDTH * HEIGHT + INC - 1);     // -- counter starts at zero, so sub 1
    
    // -- Variables
    logic [20:0] value, counter;
    
    // -- Combinatorial part
    assign onoff = &{value | MASK};                             // -- select some bits to form stars
    assign brightness = value[7:0];
    
    // -- Sequential part
    always_ff @(posedge pixel_clock or negedge reset_n) begin
        if(~reset_n) begin
            counter <= 0;
        end else begin
            counter <= counter + 21'd1;
    
            if (counter == COUNTER_END) begin
                counter <= 0;
            end
        end
    end
    
    // -- Modules
    lfsr #(.LEN(21), .TAPS(21'b101000000000000000000)) lsfr_sf (
        .clock(pixel_clock),
        .reset(counter == 21'b0),
        .seed(SEED),
        .value(value)
    );

endmodule
