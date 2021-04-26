/*******************************************************************

    @module Decoder

    Converts the input bit-string to a one-hot output by selecting
    a single bit corresponding to the input read as a binary number.

********************************************************************/
module Decoder #(
    parameter SIZE                  // Number of bits to use for input
) (
    input [SIZE-1:0] in,            // Binary number of SIZE bits
    output reg [2**SIZE-1:0] out    // One-hot output
);

    always_comb begin
        for (int i = 0; i < 2 ** SIZE; ++i) begin
            out[i] = in == i;
        end
    end
        
endmodule