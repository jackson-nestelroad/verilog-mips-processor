/*******************************************************************

    @module Simulation

    A module that provides helper functions for running one or more
    instructions on a processor with the proper clock cycle delays.

********************************************************************/
module Simulation #(
    parameter CYCLE                         // Time for one clock cycle
) (
    output reg [31:0] nextInstruction       // The next instruction, to be plugged into the processor
);

    // Waits one clock cycle
    task waitCycle();
        #(CYCLE);
    endtask

    // Executes the given instruction
    task execute(reg [31:0] instruction);
        nextInstruction = instruction;
        #(CYCLE);
    endtask

    // Executes multiple instructions
    task executeMultiple(reg [31:0] instructions []);
        foreach (instructions[i]) begin
            nextInstruction = instructions[i];
            #(CYCLE);
        end
    endtask

    // Asserts the condition is true with a printed message
    task assertCondition(bit condition, string message);
        assert (condition) begin
            $display("[PASSED]: %s", message);
        end
        else begin
            $error("[FAILED]: %s", message);
            $finish;
        end
    endtask

endmodule