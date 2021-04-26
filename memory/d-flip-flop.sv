/*******************************************************************

    @module DFlipFlop

    A modular memory unit that saves one bit over time.

********************************************************************/
module DFlipFlop (
    input d,            // Next input
    input clk,          // Clock signal
    input reset,        // Reset signal
    output reg q        // Current value
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            q <= 0;
        else
            q <= d;
    end
        
endmodule