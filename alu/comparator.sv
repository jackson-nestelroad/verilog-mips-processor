/*******************************************************************

    @module Comparator

    A comparator that compares two binary integers.

********************************************************************/
module Comparator #(
    parameter BITS = 32                 // Number of bits
) (
    input [BITS-1:0] a,                 // First number
    input [BITS-1:0] b,                 // Second number
    input unsign,                       // Unsigned comparison?
    output lessThan,                    // a < b
    output equal                        // a == b
);

    wire signedLessThan = $signed(a) < $signed(b);
    wire signedEqual = $signed(a) == $signed(b);
    wire unsignedLessThan = $unsigned(a) < $unsigned(b);
    wire unsignedEqual = $unsigned(a) == $unsigned(b);

    Multiplexer #(.SIZE(2), .T(reg [1:0])) mux (
        .select(unsign),
        .in({ { unsignedLessThan, unsignedEqual }, { signedLessThan, signedEqual } }),
        .out({ lessThan, equal })
    );

endmodule