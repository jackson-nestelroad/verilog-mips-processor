/*******************************************************************

    @module SignExtendUnit

    Module for extending a binary string represented in two's
    complement form.

********************************************************************/
module SignExtendUnit #(
    parameter FROM = 16,        // Input size
    parameter TO = 32           // Output size
) (
    input [FROM-1:0] in,        // Input
    output [TO-1:0] out         // Output
);

    if (TO < FROM) begin
        $error($sformatf("TO parameter (%0d) must be larger than FROM parameter (%0d)", TO, FROM));
    end

    assign out = { { TO - FROM { in[FROM-1] } }, in[FROM-1:0] };

endmodule