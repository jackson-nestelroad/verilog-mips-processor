/*******************************************************************

    @module Divider

    A shifter that shifts a binary integer a given number of bits
    left or right.

********************************************************************/
module Shifter #(
    parameter BITS = 32                 // Number of bits
) (
    input [BITS-1:0] in,                // Input string
    input [$clog2(BITS)-1:0] shamt,     // Amount to shift by
    input right,                        // Right shift if 1, left shift if 0
    input sign,                         // Signed shift if 1, unsigned if 0
    output [BITS-1:0] out               // Shifted result
);

    wire [BITS-1:0] signedLeft = $signed(in) <<< $signed(shamt);
    wire [BITS-1:0] signedRight = $signed(in) >>> $signed(shamt);
    wire [BITS-1:0] unsignedLeft = $unsigned(in) << $unsigned(shamt);
    wire [BITS-1:0] unsignedRight = $signed(in) >> $signed(shamt);

    Multiplexer #(.SIZE(4), .T(reg [BITS-1:0])) mux (
        .select({ right, sign }),
        .in({ signedRight, unsignedRight, signedLeft, unsignedLeft }),
        .out(out)
    );

endmodule