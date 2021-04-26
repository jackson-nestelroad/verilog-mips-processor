/*******************************************************************

    @module DataMemoryUnit

    A data memory unit used to store data in a random-access format.
    Expressed much more symbolically than any of the other units 
    for simplicity.

********************************************************************/
module DataMemoryUnit #(
    parameter BITS = 32,                    // Number of data bits per address
    parameter SIZE = 2 ** BITS              // Number of data memory slots
) (
    input [BITS-1:0] address,               // Address to read/write
    input [BITS-1:0] writeData,             // Data to write
    input clk,                              // Clock signal
    input reset,                            // Reset signal
    input enableRead,                       // Enables reading
    input enableWrite,                      // Enables writing
    output [BITS-1:0] readData              // Data read from memory
);

    reg [BITS-1:0] ram [SIZE-1:0];

    // Output data at address
    assign readData = enableRead ? ram[address] : 0;

    always_ff @(posedge clk, posedge reset) begin
        // Reset everything to 0
        if (reset) begin
            foreach (ram[i]) begin
                ram[i] <= 0;
            end
        end
        else begin
            // Write to memory
            if (enableWrite) begin
                // Ignore overflow errors
                // A real processor would have more complex memory safety rules
                if (address < SIZE) begin
                    ram[address] <= writeData;
                end
            end
        end
    end

endmodule