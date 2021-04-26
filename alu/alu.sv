`include "adder-subtractor.sv"
`include "comparator.sv"
`include "divider.sv"
`include "multiplier.sv"
`include "shifter.sv"

/*******************************************************************

    @module ArithmeticLogicUnit

    An arithmetic logic unit with several supported operations:
        Addition
        Subtraction
        Multiplication
        Division
        Logical Comparison
        Bit Operations (AND, OR, NOR, XOR, Shift Left, Shift Right)

********************************************************************/
module ArithmeticLogicUnit #(
    parameter BITS = 32                 // Number of bits
) (
    input [BITS-1:0] input1,            // First input
    input [BITS-1:0] input2,            // Second input
    input [4:0] shamt,                  // Amount to shift second input by
    input [5:0] funct,                  // Function bits
    input clk,                          // Clock signal
    input reset,                        // Reset signal
    output zero,                        // Is the result zero?
    output reg [BITS-1:0] result,       // Result of the operation
    output [BITS-1:0] syscallOut        // Exposed output on syscall
);

    assign zero = result == 0;

    // Output options for the result port
    logic [BITS-1:0] noResult = 0;
    logic [BITS-1:0] sum;
    logic [BITS-1:0] div;
    logic [BITS-1:0] mod;
    logic [BITS-1:0] productHi;
    logic [BITS-1:0] productLo;
    logic [BITS-1:0] shifted;
    logic lessThan;
    logic equal;

    // Shamt for the shifter
    wire [4:0] selectedShamt;

    wire [2*BITS-1:0] divMod = { div, mod };
    wire [2*BITS-1:0] product = { productHi, productLo };
    
    // Give correct output when writing to lo/hi registers
    wire [2*BITS-1:0] lohiWriteInput;
    Multiplexer #(.SIZE(2), .T(reg [2*BITS-1:0])) lohiMux (
        .select(funct[1]),
        .in({ divMod, product }),
        .out(lohiWriteInput)
    );

    // Wires for internal hi and lo registers
    wire [BITS-1:0] loIn;
    wire [BITS-1:0] loOut;
    wire [BITS-1:0] hiIn;
    wire [BITS-1:0] hiOut;

    // div, divu, mult, multu
    wire lohiUseALUResult = ~funct[5] & funct[4] & funct[3] & ~funct[2];

    // mthi, mtlo
    wire lohiUseALUInput1 = ~funct[5] & funct[4] & ~funct[3] & ~funct[2] & funct[0];
    wire loUseALUInput1 = lohiUseALUInput1 & funct[1];
    wire hiUseALUInput1 = lohiUseALUInput1 & ~funct[1];

    // Is the function performing a syscall?
    wire isSyscall = ~funct[5] & ~funct[4] & funct[3] & funct[2] & ~funct[1] & ~funct[0];

    // Wire for internal syscall register
    wire [BITS-1:0] syscallIn;

    // Lo register
    Register #(.SIZE(BITS)) loRegister (
        .in(loIn),
        .clk(clk),
        .reset(reset),
        .out(loOut)
    );

    // Provides next input for the lo register
    Multiplexer #(.SIZE(3), .T(reg [BITS-1:0])) loMux (
        .select({ loUseALUInput1, lohiUseALUResult }),
        .in({ input1, lohiWriteInput[BITS-1:0], loOut }),
        .out(loIn)
    );

    // Hi register
    Register #(.SIZE(BITS)) hiRegister (
        .in(hiIn),
        .clk(clk),
        .reset(reset),
        .out(hiOut)
    );

    // Provides next input for the lo hi register
    Multiplexer #(.SIZE(3), .T(reg [BITS-1:0])) hiMux (
        .select({ hiUseALUInput1, lohiUseALUResult }),
        .in({ input1, lohiWriteInput[2*BITS-1:BITS], hiOut }),
        .out(hiIn)
    );

    // Value updated when syscall is performed
    Register #(.SIZE(BITS)) syscallRegister (
        .in(syscallIn),
        .clk(clk),
        .reset(reset),
        .out(syscallOut)
    );

    // Provides the next input for the syscall register
    Multiplexer #(.SIZE(2), .T(reg [BITS-1:0])) syscallMux (
        .select(isSyscall),
        .in({ input1, syscallOut }),
        .out(syscallIn)
    );

    // Adds or subtracts the inputs
    AdderSubtractor #(.BITS(BITS)) adderSubtractor (
        .a(input1),
        .b(input2),
        .op(funct[1]),
        .sum(sum),
        .carryOut()
    );

    // Multiplies the inputs
    Multiplier #(.BITS(BITS)) multiplier (
        .a(input1),
        .b(input2),
        .unsign(funct[0]),
        .hi(productHi),
        .lo(productLo)
    );

    // Divides the first input by the second input
    Divider #(.BITS(BITS)) divider (
        .a(input1),
        .b(input2),
        .unsign(funct[0]),
        .div(div),
        .mod(mod),
        .divideByZero()
    );

    // Selects whether to use the lower bits of input1 or shamt to shift input 2 by
    Multiplexer #(.SIZE(2), .T(reg [4:0])) shamtMux (
        .select(funct[2]),
        .in({ input1[4:0], shamt }),
        .out(selectedShamt)
    );

    // Shifts the input a given number of bits
    // The shifter, oddly enough, shifts the second input by the amount in the first
    // This is based on the MIPS instruction encoding
    Shifter #(.BITS(BITS)) shifter (
        .in(input2),
        .shamt(selectedShamt),
        .right(funct[1]),
        .sign(funct[0]),
        .out(shifted)
    );

    // Compares the two inputs logically
    Comparator #(.BITS(BITS)) comparator (
        .a(input1),
        .b(input2),
        .unsign(funct[0]),
        .lessThan(lessThan),
        .equal(equal)
    );

    // Due to complexity, express this part more symbolically rather than using a MUX
    always_comb begin
        case (funct)
            6'b100001: result = sum;                    // addu
            6'b100100: result = input1 & input2;        // and
            6'b011010: result = noResult;               // div
            6'b011011: result = noResult;               // divu
            6'b010000: result = hiOut;                  // mfhi
            6'b010010: result = loOut;                  // mflo
            6'b010001: result = noResult;               // mthi
            6'b010011: result = noResult;               // mtlo
            6'b011000: result = noResult;               // mult
            6'b011001: result = noResult;               // multu
            6'b100111: result = ~(input1 | input2);     // nor
            6'b100101: result = input1 | input2;        // or
            6'b101110: result = equal;                  // seq (my instruction)
            6'b000000: result = shifted;                // sll (also implements lui)
            6'b000100: result = shifted;                // sllv
            6'b101010: result = lessThan;               // slt
            6'b101011: result = lessThan;               // sltu
            6'b000011: result = shifted;                // sra
            6'b000111: result = shifted;                // srav
            6'b000010: result = shifted;                // srl
            6'b000110: result = shifted;                // srlv
            6'b100011: result = sum;                    // subu
            6'b100110: result = input1 ^ input2;        // xor
            6'b001100: begin                            // syscall (used to print a register value)
                // Only print when clock is high
                // There is not really a great way to assure we only print once
                if (clk) begin
                    $display("%0d (signed: %0d) (binary: %32b)", input1, $signed(input1), input1);
                end
                result = noResult;
            end
            default: result = noResult;                 // Invalid funct
        endcase
    end

endmodule