`include "processor.sv"
`include "instructions.sv"
`include "simulation.sv"

`define NO_OP 2'b00         // No operation
`define RESET 2'b11         // Reset datapath
`define EXECUTE 2'b01       // Execute next instruction

`define CYCLE 10            // Clock period

module TestBench ();

    reg [1:0] operation;
    wire [31:0] nextInstruction;
    reg [31:0] syscallOut;

    Processor #(.CLOCK(`CYCLE)) processor (
        .operation(operation),
        .nextInstruction(nextInstruction),
        .syscallOut(syscallOut)
    );


    Simulation #(.CYCLE(`CYCLE)) simulation (
        .nextInstruction(nextInstruction)
    );

    // Values to run all tests against
    reg [31:0] first = -5512513;
    reg [31:0] second = 16;

    // Variables used for testing
    reg [63:0] product;

    initial begin
        // Reset the processor
        operation = `RESET;
        simulation.waitCycle();

        // Begin executing
        operation = `EXECUTE;

        // Load test values into registers
        simulation.executeMultiple(Assembler::_li(8, first));
        simulation.executeMultiple(Assembler::_li(9, second));
        simulation.executeMultiple(Assembler::_li(10, 2));

        // Test loaded values
        simulation.execute(Instructions::_syscall(8));
        simulation.assertCondition(syscallOut == first, "Register 8 contains first value");

        simulation.execute(Instructions::_syscall(9));
        simulation.assertCondition(syscallOut == second, "Register 9 contains second value");

        simulation.execute(Instructions::_syscall(10));
        simulation.assertCondition(syscallOut == 2, "Register 10 contains 2");

        // Test all R-format instructions, which operate on two registers

        simulation.execute(Instructions::_addu(11, 8, 9));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == first + second, "Register 11 contains sum");

        simulation.execute(Instructions::_and(11, 8, 9));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == (first & second), "Register 11 contains AND");

        simulation.execute(Instructions::_div(8, 9));
        simulation.execute(Instructions::_mfhi(11));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition($signed(syscallOut) == $signed(first) / $signed(second), "Register 11 contains signed quotient");
        simulation.execute(Instructions::_mflo(11));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition($signed(syscallOut) == $signed(first) % $signed(second), "Register 11 contains signed remainder");

        simulation.execute(Instructions::_divu(8, 9));
        simulation.execute(Instructions::_mfhi(11));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition($unsigned(syscallOut) == $unsigned(first) / $unsigned(second), "Register 11 contains unsigned quotient");
        simulation.execute(Instructions::_mflo(11));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition($unsigned(syscallOut) == $unsigned(first) % $unsigned(second), "Register 11 contains unsigned remainder");

        simulation.execute(Instructions::_mthi(8));
        simulation.execute(Instructions::_mfhi(11));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == first, "mthi moves first value into hi register");

        simulation.execute(Instructions::_mtlo(9));
        simulation.execute(Instructions::_mflo(11));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == second, "mtlo moves second value into hi register");

        product = $signed(first) * $signed(second);
        simulation.execute(Instructions::_mult(8, 9));
        simulation.execute(Instructions::_mfhi(11));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition($signed(syscallOut) == $signed(product[63:32]), "Register 11 contains upper 32-bits of signed product");
        simulation.execute(Instructions::_mflo(11));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition($signed(syscallOut) == $signed(product[31:0]), "Register 11 contains lower 32-bits of signed product");

        product = $unsigned(first) * $unsigned(second);
        simulation.execute(Instructions::_multu(8, 9));
        simulation.execute(Instructions::_mfhi(11));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition($signed(syscallOut) == $unsigned(product[63:32]), "Register 11 contains upper 32-bits of unsigned product");
        simulation.execute(Instructions::_mflo(11));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition($signed(syscallOut) == $unsigned(product[31:0]), "Register 11 contains lower 32-bits of unsigned product");

        simulation.execute(Instructions::_nor(11, 8, 9));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == ~(first | second), "Register 11 contains NOR");

        simulation.execute(Instructions::_or(11, 8, 9));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == (first | second), "Register 11 contains OR");

        simulation.execute(Instructions::_seq(11, 8, 9));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == (first == second), "Register 11 contains equality");

        simulation.execute(Instructions::_seq(11, 8, 8));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut, "Register is equal to itself");

        simulation.execute(Instructions::_sll(11, 8, 4));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == (first << 4), "Register 11 contains left shift using shamt");

        simulation.execute(Instructions::_sllv(11, 8, 10));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == (first << 2), "Register 11 containts left shift using register");

        simulation.execute(Instructions::_slt(11, 8, 9));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == ($signed(first) < $signed(second)), "Register 11 contains signed less than");

        simulation.execute(Instructions::_sltu(11, 8, 9));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == ($unsigned(first) < $unsigned(second)), "Register 11 contains unsigned less than");

        simulation.execute(Instructions::_sra(11, 8, 4));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition($signed(syscallOut) == ($signed(first) >>> 4), "Register 11 contains arithmetic right shift using shamt");

        simulation.execute(Instructions::_srav(11, 8, 10));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition($signed(syscallOut) == ($signed(first) >>> 2), "Register 11 contains arithmetic right shift using register");

        simulation.execute(Instructions::_srl(11, 8, 4));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition($signed(syscallOut) == ($unsigned(first) >> 4), "Register 11 contains logical right shift using shamt");

        simulation.execute(Instructions::_srlv(11, 8, 10));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition($signed(syscallOut) == ($unsigned(first) >> 2), "Register 11 contains logical right shift using register");

        simulation.execute(Instructions::_subu(11, 8, 9));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition($signed(syscallOut) == first - second, "Register 11 contains difference");
        
        simulation.execute(Instructions::_xor(11, 8, 9));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == (first ^ second), "Register 11 contains XOR");

        // Test all I-format ALU instructions, which operate on one register and an immediate value

        simulation.executeMultiple(Assembler::_addiu(11, 8, 1));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == first + 1, "Register 11 contains first number incremented by 1");

        simulation.executeMultiple(Assembler::_addiu(11, 8, -100));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == first - 100, "Register 11 contains first number decremented by 100");

        simulation.executeMultiple(Assembler::_addiu(11, 8, 500000));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == first + 500000, "Register 11 contains first number incremented by 500,000");

        simulation.executeMultiple(Assembler::_slti(11, 8, 100));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == ($signed(first) < 'sd100), "Register 11 contains signed immediate less than");

        simulation.executeMultiple(Assembler::_sltiu(11, 8, 100));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == ($unsigned(first) < 'd100), "Register 11 contains unsigned immediate less than");

        simulation.executeMultiple(Assembler::_andi(11, 8, 100));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == (first & 100), "Register 11 contains AND immediate");

        simulation.executeMultiple(Assembler::_ori(11, 8, 100));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == (first | 100), "Register 11 contains OR immediate");

        simulation.executeMultiple(Assembler::_xori(11, 8, 100));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == (first ^ 100), "Register 11 contains XOR immediate");

        simulation.execute(Instructions::_lui(11, 100));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == (100 << 16), "Register 11 contains 100 in upper bits");

        // Test all I-format memory instructions, which works with the data memory unit

        simulation.executeMultiple(Assembler::_li(12, 100));

        simulation.executeMultiple(Assembler::_sw(8, 12, 0));
        simulation.executeMultiple(Assembler::_lw(11, 12, 0));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == first, "Register 11 contains first number after storing/loading from memory");

        simulation.executeMultiple(Assembler::_sw(9, 12, 16));
        simulation.executeMultiple(Assembler::_lw(11, 12, 16));
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == second, "Register 11 contains second number after storing/loading from memory with offset");

        simulation.execute(Instructions::_addu(0, 0, 8));
        simulation.execute(Instructions::_syscall(0));
        simulation.assertCondition(syscallOut == 0, "Register 0 cannot be written to");

        // Test high-level opcodes

        simulation.execute(Instructions::_addu(11, 0, 8));
        simulation.execute(Instructions::_addu(11, 11, 9));
        simulation.waitCycle();
        simulation.waitCycle();
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == first + second * 3, "EXECUTE executes nextInstruction multiple times over multiple cycles");

        simulation.execute(Instructions::_addu(11, 0, 0));
        operation = `NO_OP;
        simulation.execute(Instructions::_addu(11, 0, 8));
        operation = `EXECUTE;
        simulation.execute(Instructions::_syscall(11));
        simulation.assertCondition(syscallOut == 0, "NO_OP ignores nextInstruction");

        operation = `RESET;
        simulation.waitCycle();
        operation = `EXECUTE;
        simulation.execute(Instructions::_syscall(8));
        simulation.assertCondition(syscallOut == 0, "Registers are cleared by RESET");

        simulation.assertCondition(1, "All tests passed");

        $finish;
    end

endmodule