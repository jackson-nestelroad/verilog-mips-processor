`include "time/clock-generator.sv"
`include "memory/register-file.sv"
`include "memory/data-memory-unit.sv"
`include "util/sign-extend-unit.sv"
`include "alu/alu.sv"
`include "control/control-logic.sv"

/*******************************************************************

    @module Processor

    A module that implements a 32-bit, single-cycle MIPS processor
    with a small subset of support instructions.

********************************************************************/
module Processor #(
    parameter CLOCK
) (
    input [1:0] operation,              // Processor operation to perform
    input [31:0] nextInstruction,       // Next instruction to execute
    output [31:0] syscallOut            // Exposed output on syscall
);

    // Use built-in gate functions
    
    // Reset the processor
    wire reset;
    and(reset, operation[1], operation[0]);

    // Execute next instruction
    wire execute;
    xor(execute, operation[1], operation[0]);

    // Enable the clock forever
    wire clkEnable = 1;

    // Clock output
    wire clk;

    // Next instruction to execute
    wire [31:0] instruction;

    // Control signals generated for the current instruction
    wire regDestControlSignal;
    wire regWriteControlSignal;
    wire signExtendControlSignal;
    wire memReadControlSignal;
    wire memWriteControlSignal;
    wire memToRegControlSignal;
    wire aluSrcControlSignal;
    wire aluShamtSrcControlSignal;
    wire aluFunctSrcControlSignal;
    wire [4:0] aluShamtControlSignal;
    wire [5:0] aluFunctControlSignal;

    // Wire from MUX selecting write register number to register file
    wire [4:0] writeRegisterMuxToRegisterFile;

    // Data read immediately from the register file
    wire [31:0] registerFileReadData1;
    wire [31:0] registerFileReadData2;

    // Output of sign extension unit for immediate value
    wire [31:0] signExtendImmediateOutput;

    // Selected extended immediate, either sign-extended or zero-extended
    wire [31:0] extendedImmediate;

    // The second input to the ALU, chosen by a MUX
    wire [31:0] aluInput2;

    // The shamt to give to the ALU
    wire [4:0] aluShamt;

    // The function to perform in the ALU, chosen by a MUX
    wire [5:0] aluFunct;

    // The result of the ALU operation
    wire [31:0] aluResult;

    // The output of the data memory unit
    wire [31:0] dataMemoryOutput;

    // Data to write back to the register file
    wire [31:0] writeBackToRegisterFile;

    // Generate the clock signal
    ClockGenerator #(.PERIOD(CLOCK), .PHASE(180)) clock (
        .enable(clkEnable),
        .clk(clk)
    );

    // Select the next instruction to execute
    // Force a no-op if needed
    Multiplexer #(.SIZE(2), .T(reg [31:0])) nextInstructionMux (
        .select(execute),
        .in({ nextInstruction, 32'b0 }),
        .out(instruction)
    );

    // Control logic unit for creating control signals that tell
    // different parts of the datapath to perform as intended based
    // on the current instruction
    ControlLogic controlLogic (
        .opcode(instruction[31:26]),
        .regDest(regDestControlSignal),
        .regWrite(regWriteControlSignal),
        .signExtend(signExtendControlSignal),
        .memRead(memReadControlSignal),
        .memWrite(memWriteControlSignal),
        .memToReg(memToRegControlSignal),
        .aluSrc(aluSrcControlSignal),
        .aluShamtSrc(aluShamtSrcControlSignal),
        .aluFunctSrc(aluFunctSrcControlSignal),
        .aluShamt(aluShamtControlSignal),
        .aluFunct(aluFunctControlSignal)
    );

    // Selects which part of the instruction to use for write register number
    Multiplexer #(.SIZE(2), .T(reg [4:0])) writeRegisterMux (
        .select(regDestControlSignal),
        .in({ instruction[15:11], instruction[20:16] }),
        .out(writeRegisterMuxToRegisterFile)
    );

    // Register file for reading and writing data being operated on
    RegisterFile #(.REG_SIZE(32), .FILE_SIZE(32)) regFile (
        .readRegister1(instruction[25:21]),
        .readRegister2(instruction[20:16]),
        .writeRegister(writeRegisterMuxToRegisterFile),
        .writeData(writeBackToRegisterFile),
        .clk(clk),
        .reset(reset),
        .enableWrite(regWriteControlSignal),
        .readData1(registerFileReadData1),
        .readData2(registerFileReadData2)
    );

    // Sign extends the immediate value
    SignExtendUnit #(.FROM(16), .TO(32)) signExtend (
        .in(instruction[15:0]),
        .out(signExtendImmediateOutput)
    );

    // Selects how to extend the immediate value
    Multiplexer #(.SIZE(2), .T(reg [31:0])) extendedImmediateMux (
        .select(signExtendControlSignal),
        .in({ signExtendImmediateOutput, { 16'b0, instruction[15:0] } }),
        .out(extendedImmediate)
    );

    // Selects the second input to the ALU
    Multiplexer #(.SIZE(2), .T(reg [31:0])) aluSrcMux (
        .select(aluSrcControlSignal),
        .in({ extendedImmediate, registerFileReadData2 }),
        .out(aluInput2)
    );

    // Selects which bits to use for the ALU function
    Multiplexer #(.SIZE(2), .T(reg [5:0])) aluFunctMux (
        .select(aluFunctSrcControlSignal),
        .in({ aluFunctControlSignal, instruction[5:0] }),
        .out(aluFunct)
    );

    // Selects which bits to use for the ALU shift amount
    Multiplexer #(.SIZE(2), .T(reg [4:0])) aluShamtMux (
        .select(aluShamtSrcControlSignal),
        .in({ aluShamtControlSignal, instruction[10:6] }),
        .out(aluShamt)
    );

    // The ALU that performs an operation on two values
    ArithmeticLogicUnit #(.BITS(32)) alu (
        .input1(registerFileReadData1),
        .input2(aluInput2),
        .shamt(aluShamt),
        .funct(aluFunct),
        .clk(clk),
        .reset(reset),
        .zero(),
        .result(aluResult),
        .syscallOut(syscallOut)
    );

    // The data memory unit for storing data over long periods of time
    DataMemoryUnit #(.SIZE(256)) dataMemory (
        .address(aluResult),
        .writeData(registerFileReadData2),
        .clk(clk),
        .reset(reset),
        .enableRead(memReadControlSignal),
        .enableWrite(memWriteControlSignal),
        .readData(dataMemoryOutput)
    );

    // Select which data to write to the register file
    // Either the ALU result or the data read from memory
    Multiplexer #(.SIZE(2), .T(reg [31:0])) writeBackMux (
        .select(memToRegControlSignal),
        .in({ dataMemoryOutput, aluResult }),
        .out(writeBackToRegisterFile)
    );

endmodule