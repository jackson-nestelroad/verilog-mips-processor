`include "d-flip-flop.sv"

/*******************************************************************

    @module Register

    A modular memory unit that saves one or more input bits over
    time.

********************************************************************/
module Register #(
    parameter SIZE = 32         // Number of bits
) (
    input [SIZE-1:0] in,        // Next input to use
    input clk,                  // Clock signal
    input reset,                // Reset signal
    output [SIZE-1:0] out       // Current value
);

    generate
        for (genvar i = 0; i < SIZE; ++i) begin
            DFlipFlop flipFlop (
                .d(in[i]),
                .clk(clk),
                .reset(reset),
                .q(out[i])
            );
        end
    endgenerate
        
endmodule