/*******************************************************************

    @module Multiplier

    A multiplier that multiplies two binary integers.

********************************************************************/
module Multiplier #(
    parameter BITS = 32                 // Number of bits
) (
    input [BITS-1:0] a,                 // First number
    input [BITS-1:0] b,                 // Second number
    input unsign,                       // Unsigned operation?
    output [BITS-1:0] hi,               // High output
    output [BITS-1:0] lo                // Low output
);

    wire [2*BITS-1:0] signedResult = $signed(a) * $signed(b);
    wire [2*BITS-1:0] unsignedResult = $unsigned(a) * $unsigned(b);

    wire [2*BITS-1:0] result;

    Multiplexer #(.SIZE(2), .T(reg [2*BITS-1:0])) mux (
        .select(unsign),
        .in({ unsignedResult, signedResult }),
        .out(result)
    );

    assign hi = result[2*BITS-1:BITS];
    assign lo = result[BITS-1:0];

endmodule