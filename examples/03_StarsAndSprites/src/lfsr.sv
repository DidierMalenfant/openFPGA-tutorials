`default_nettype none

// -----------------------------------------------------------------------------------
// -- Linear Feedback Shift Register
module lfsr #(

    // -- Parameters
    parameter LEN = 8,                  // -- shift register length
    parameter TAPS = 8'b10111000) (     // -- XOR taps
    
    // -- Inputs
    input wire clock,                   // -- clock
    input wire reset,                   // -- reset if high
    input wire [LEN-1:0] seed,          // -- seed (uses default seed if zero)
    
    // -- Outputs
    output logic [LEN-1:0] value);
    
    // -- Sequential part
    always_ff @(posedge clock) begin
        if (reset) begin
            value <= (seed != 0) ? seed : { LEN{1'b1} };
        end else begin
            value <= {1'b0, value[LEN-1:1]} ^ (value[0] ? TAPS : { LEN{1'b0} });
        end
    end

endmodule
