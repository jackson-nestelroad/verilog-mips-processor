/*******************************************************************

    @module Divider

    A divider that divides two binary integers.

********************************************************************/
module Divider #(
    parameter BITS = 32                 // Number of bits
) (
    input [BITS-1:0] a,                 // First number
    input [BITS-1:0] b,                 // Second number
    input unsign,                       // Unsigned operation?
    output [BITS-1:0] div,              // a / b
    output [BITS-1:0] mod,              // a % b
    output divideByZero                 // b == 0
);

    assign divideByZero = b == 0;

    wire [BITS-1:0] signedDiv = $signed(a) / $signed(b);
    wire [BITS-1:0] signedMod = $signed(a) % $signed(b);
    wire [BITS-1:0] unsignedDiv = $unsigned(a) / $unsigned(b);
    wire [BITS-1:0] unsignedMod = $unsigned(a) % $unsigned(b);

    wire [2*BITS-1:0] result;

    Multiplexer #(.SIZE(2), .T(reg [2*BITS-1:0])) mux (
        .select(unsign),
        .in({ { unsignedDiv, unsignedMod }, { signedDiv, signedMod } }),
        .out(result)
    );

    assign div = result[2*BITS-1:BITS];
    assign mod = result[BITS-1:0];

endmodule