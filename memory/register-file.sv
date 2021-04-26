`include "register.sv"
`include "../util/multiplexer.sv"
`include "../util/decoder.sv"

/*******************************************************************

    @module RegisterFile

    A collection of registers. Two registers can be read from and
    one register can be written to at one time.

********************************************************************/
module RegisterFile #(
    parameter REG_SIZE = 32,                            // Size of a single register
    parameter FILE_SIZE = 32                            // Number of registers
) (
    input [$clog2(FILE_SIZE)-1:0] readRegister1,        // First register to read
    input [$clog2(FILE_SIZE)-1:0] readRegister2,        // Second register to read
    input [$clog2(FILE_SIZE)-1:0] writeRegister,        // Register to write
    input [REG_SIZE-1:0] writeData,                     // Data to write
    input clk,                                          // Clock signal
    input reset,                                        // Reset signal
    input enableWrite,                                  // Enable bit for writing
    output [REG_SIZE-1:0] readData1,                    // First register data
    output [REG_SIZE-1:0] readData2                     // Second register data
);

    // Connects to each register's input
    wire [REG_SIZE-1:0] inputConnections [FILE_SIZE-1:0];

    // Connects to each register's output
    wire [REG_SIZE-1:0] outputConnections [FILE_SIZE-1:0];

    // Output of the writeRegister decoder
    wire [FILE_SIZE-1:0] decoderOutput;

    // A single bit saying if a given register is selected for writing
    logic isRegisterSelectedToWrite [FILE_SIZE-1:0];

    generate
        // Turn write register number into a one-hot output
        Decoder #(.SIZE(5)) decoder (
            .in(writeRegister),
            .out(decoderOutput)
        );
        
        // Select first register to read
        Multiplexer #(.SIZE(FILE_SIZE), .T(reg [REG_SIZE-1:0])) readMux1 (
            .select(readRegister1),
            .in(outputConnections),
            .out(readData1)
        );

        // Select second register to read
        Multiplexer #(.SIZE(FILE_SIZE), .T(reg [REG_SIZE-1:0])) readMux2 (
            .select(readRegister2),
            .in(outputConnections),
            .out(readData2)
        );

        // Generate all registers in the file
        for (genvar i = 0; i < FILE_SIZE; ++i) begin
            Register #(.SIZE(REG_SIZE)) register (
                .in(inputConnections[i]),
                .clk(clk),
                .reset(reset),
                .out(outputConnections[i])
            );

            // Selects the next input for the register
            // If the register is selected to be written, writeData is used
            // If not, the last output from the register file is used (no change)
            Multiplexer #(.SIZE(2), .T(reg [REG_SIZE-1:0])) inputMux (
                .select(isRegisterSelectedToWrite[i]),
                .in({ writeData, outputConnections[i] }),
                .out(inputConnections[i])
            );
        end
    endgenerate

    always_comb begin
        // Register 0 cannot be written to
        isRegisterSelectedToWrite[0] = 0;
        
        for (int i = 1; i < FILE_SIZE; ++i) begin
            // Decoder output bit AND enableWrite
            isRegisterSelectedToWrite[i] = decoderOutput[i] & enableWrite;
        end
    end
    
endmodule