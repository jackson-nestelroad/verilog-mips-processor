# Verilog MIPS Processor

This repository features my final project for CS 4341: Digital Logic and Computer Design. I implemented a single-cycle processor that executes a small subset of 32-bit MIPS instructions.

Instructions are not stored and fetched in an instruciton memory unit. Instead, they are continuously fed to the processor through an input port. Thus, no branching instructions are supported.

This processor supports several R-format instructions, arithmetic I-format instructions, and memory word instructions.

## Running in ModelSim

I simulated this project using ModelSim. I have documented the process for running this project below.

1. Open a command-line terminal at the base directory of the project, which is where "test-bench.sv" is located.
2. Run `vsim` to start ModelSim. The following commands take place inside ModelSim.
3. Run `vlib work` to create a work library.
4. Run `vlog test-bench.sv` to compile the project.
5. Run `vsim work.TestBench` to begin a simulation.
6. Run `run -all` inside the simulation to run the entire simulation.
7. If compiled and run correctly, all tests should be displayed as passing.