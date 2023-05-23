`default_nettype none

// -----------------------------------------------------------------------------------
// -- Synchronous ROM controller
module rom_sync #(

    // -- Parameters
    parameter WIDTH = 8,
    parameter DEPTH = 256,
    parameter INIT_FILE = "") (

    // -- Inputs
    input wire logic clock,
    input wire logic [$clog2(DEPTH)-1:0] addr,

    // -- Outputs
    output wire logic [WIDTH-1:0] data);

    // -- Variables
    logic [WIDTH-1:0] memory[DEPTH];

    // -- Initial part
    initial begin
        $readmemh(INIT_FILE, memory);
    end

    // -- Sequential part
    always_ff @(posedge clock) begin
        data <= memory[addr];
    end

endmodule
