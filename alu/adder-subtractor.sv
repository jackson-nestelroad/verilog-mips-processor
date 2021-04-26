`include "full-adder.sv"

/*******************************************************************

    @module AdderSubtractor

    An adder-subtractor that adds or subtracts two binary integers.

********************************************************************/
module AdderSubtractor #(
    parameter BITS = 32                 // Number of bits
) (
    input [BITS-1:0] a,                 // First number
    input [BITS-1:0] b,                 // Second number
    input op,                           // Input operation (subtract = 1, add = 0)
    output [BITS-1:0] sum,              // a + b, or a - b
    output [BITS-1:0] carryOut          // Output carry bit
);

    logic [BITS-1:0] secondOperand;

    always_comb begin
        for (int i = 0; i < BITS; ++i) begin
            secondOperand[i] = b[i] ^ op;
        end
    end

    FullAdder #(.BITS(BITS)) adder (
        .a(a),
        .b(secondOperand),
        .carryIn(op),
        .sum(sum),
        .carryOut(carryOut)
    );

endmodule