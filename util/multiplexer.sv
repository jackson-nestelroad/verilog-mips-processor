/*******************************************************************

    @module Multiplexer

    Selects one input channel based on the selection bits, read as
    a binary number.

********************************************************************/
module Multiplexer #(
    parameter SIZE = 2,                         // Number of channels
    parameter type T = logic                    // Data type of channel
) (
    input wire [$clog2(SIZE)-1:0] select,       // Selection bits
    input wire T in [SIZE-1:0],                 // Input chanels
    output T out                                // Output channel
);

    assign out = in[select];

endmodule