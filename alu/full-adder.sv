/*******************************************************************

    @module FullAdder

    A full adder that returns the sum and carry bit of two binary 
    integers and a carry bit.

********************************************************************/
module FullAdder #(
    parameter BITS = 32                 // Number of bits
) (
    input [BITS-1:0] a,                 // First number
    input [BITS-1:0] b,                 // Second number
    input carryIn,                      // Input carry bit
    output [BITS-1:0] sum,              // a + b
    output [BITS-1:0] carryOut          // Output carry bit
);

    wire [BITS:0] result = $unsigned(a) + $unsigned(b) + carryIn;
    assign sum = result[BITS-1:0];
    assign carryOut = result[BITS];

endmodule