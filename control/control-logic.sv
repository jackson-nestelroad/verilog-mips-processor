/*******************************************************************

    @module ControlLogic

    A module that implements all of the logic for the control
    signals that tell the datapath how to operate for the
    given instruction.

********************************************************************/
module ControlLogic (
    input [5:0] opcode,     // The instruction's opcode
    output regDest,         // 1 == rd, 0 == rs
    output regWrite,        // 1 == write to register file
    output signExtend,      // 1 == sign extend immediate, 0 == zero extend immediate
    output memRead,         // 1 == read from memory
    output memWrite,        // 1 == write to memory
    output memToReg,        // 1 == load from memory to register file
    output aluSrc,          // 1 == immediate, 0 == register file output
    output aluShamtSrc,     // 1 == control shamt, 0 == instruction shamt
    output aluFunctSrc,     // 1 == control funct, 0 == instruction funct
    output [4:0] aluShamt,  // Generated ALU shamt for instruction (R-format), also used for lui
    output [5:0] aluFunct   // Generated ALU funct for instruction (I-format)
);

    // Is the opcode load upper immediate?
    // lui works a bit differently than the other instructions, so it requires some special logic
    wire isLui = ~opcode[5] & ~opcode[4] & opcode[3] & opcode[2] & opcode[1] & opcode[0];

    // Only use rd for R-format instructions, which all have an opcode of 0
    assign regDest = ~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] & ~opcode[1] & ~opcode[0];

    // Write to register whenever we are not writing to memory
    // This may not be true for ALL MIPS instructions, but it is for the subset we implement
    assign regWrite = ~memWrite;

    // Sign extend for non-bitwise operations and memory operations (anything based on arithmetic)
    assign signExtend = (~opcode[5] & ~opcode[4] & opcode[3] & ~opcode[2]) | (opcode[5] & ~opcode[4]);

    // Read and write from memory indicated by opcode bits
    assign memRead = opcode[5] & ~opcode[3];
    assign memWrite = opcode[5] & opcode[3];

    // Value read from memory is being written to a register every time
    assign memToReg = memRead;

    // Use immediate whenever we are not doing an R-format instruction
    assign aluSrc = ~regDest;

    // Use generated samt whenever we are not doing an R-format instruction
    assign aluShamtSrc = ~regDest;

    // Use generated funct whenever we are not doing an R-format instruction
    assign aluFunctSrc = ~regDest;

    // When the first two bits of the opcode are 00,
    // the funct for the ALU can easily be derived from the lower 3 opcode bits
    // The bit at index 3, however, is a bit strange and uses this logic
    wire thirdFunctBitForIFormat = ~opcode[2] & opcode[1];

    // Select which shamt to use, which only matters for I-format instructions
    // shamt is used to implement lui in the ALU
    Multiplexer #(.SIZE(2), .T(reg [4:0])) aluShamtMux (
        .select(isLui),
        .in({ 5'b10000, 5'b00000 }),
        .out(aluShamt)
    );

    // Selected funct output for ALU when opcode begins with 00
    wire [5:0] aluFunct00Output;

    // Select which funct to use when opcode begins with 00
    Multiplexer #(.SIZE(2), .T(reg [5:0])) aluFunct00Mux (
        .select(isLui),
        .in({ 6'b000000, { 2'b10, thirdFunctBitForIFormat, opcode[2:0] } }),
        .out(aluFunct00Output)
    );

    // Select which funct to use, which only matters for I-format instructions
    // 00 => generate funct from opcode
    // 01 => unused
    // 10 => memory read/write, always add immediate to register value to get address
    Multiplexer #(.SIZE(3), .T(reg [5:0])) aluFunctMux (
        .select(opcode[5:4]),
        .in({ 6'b100001, 6'b000000, aluFunct00Output }),
        .out(aluFunct)
    );
    
endmodule