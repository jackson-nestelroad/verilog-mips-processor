`define MAKE_R_FORMAT_THREE_REG(name, funct) \
function Instruction _``name``(Register rd, Register rs, Register rt); \
    automatic reg [31:0] encoded = rFormat(rs, rt, rd, 0, funct); \
    $display("Instruction: %s $%0d, $%0d, $%0d  (%32b) (0x%8x)", `"name`", rd, rs, rt, encoded, encoded); \
    return encoded; \
endfunction

`define MAKE_R_FORMAT_THREE_REG_SHIFT(name, funct) \
function Instruction _``name``(Register rd, Register rt, Register rs); \
    automatic reg [31:0] encoded = rFormat(rs, rt, rd, 0, funct); \
    $display("Instruction: %s $%0d, $%0d, $%0d  (%32b) (0x%8x)", `"name`", rd, rt, rs, encoded, encoded); \
    return encoded; \
endfunction

`define MAKE_R_FORMAT_TWO_REG_NO_WRITE(name, funct) \
function Instruction _``name``(Register rs, Register rt); \
    automatic reg [31:0] encoded = rFormat(rs, rt, 0, 0, funct); \
    $display("Instruction: %s $%0d, $%0d  (%32b) (0x%8x)", `"name`", rs, rt, encoded, encoded); \
    return encoded; \
endfunction

`define MAKE_R_FORMAT_TWO_REG_SHIFT(name, funct) \
function Instruction _``name``(Register rd, Register rt, Register shamt); \
    automatic reg [31:0] encoded = rFormat(0, rt, rd, shamt, funct); \
    $display("Instruction: %s $%0d, $%0d, %0d  (%32b) (0x%8x)", `"name`", rd, rt, shamt, encoded, encoded); \
    return encoded; \
endfunction

`define MAKE_R_FORMAT_ONE_REG_READ(name, funct) \
function Instruction _``name``(Register rs); \
    automatic reg [31:0] encoded = rFormat(rs, 0, 0, 0, funct); \
    $display("Instruction: %s $%0d  (%32b) (0x%8x)", `"name`", rs, encoded, encoded); \
    return encoded; \
endfunction

`define MAKE_R_FORMAT_ONE_REG_WRITE(name, funct) \
function Instruction _``name``(Register rd); \
    automatic reg [31:0] encoded = rFormat(0, 0, rd, 0, funct); \
    $display("Instruction: %s $%0d  (%32b) (0x%8x)", `"name`", rd, encoded, encoded); \
    return encoded; \
endfunction

`define MAKE_I_FORMAT_TWO_REG(name, opcode) \
function Instruction _``name``(Register rt, Register rs, Immediate immed); \
    automatic reg [31:0] encoded = iFormat(opcode, rs, rt, immed); \
    $display("Instruction: %s $%0d, $%0d, %0d  (%32b) (0x%8x)", `"name`", rt, rs, immed, encoded, encoded); \
    return encoded; \
endfunction

`define MAKE_I_FORMAT_ONE_REG(name, opcode) \
function Instruction _``name``(Register rt, Immediate immed); \
    automatic reg [31:0] encoded = iFormat(opcode, 0, rt, immed); \
    $display("Instruction: %s $%0d, %0d  (%32b) (0x%8x)", `"name`", rt, immed, encoded, encoded); \
    return encoded; \
endfunction

`define MAKE_I_FORMAT_MEM(name, opcode) \
function Instruction _``name``(Register rt, Register rs, Immediate immed); \
    automatic reg [31:0] encoded = iFormat(opcode, rs, rt, immed); \
    $display("Instruction: %s $%0d, %0d($%0d)  (%32b) (0x%8x)", `"name`", rt, immed, rs, encoded, encoded); \
    return encoded; \
endfunction

`define MAKE_I_FORMAT_ASSEMBLER_TWO_REG(name, base) \
function MultipleInstructions _``name``(Register rt, Register rs, OverflowingImmediate immed); \
    if ((immed < -32'sd32768) || (immed > 32'sd32767)) begin \
        return { \
            Instructions::_lui(1, immed >>> 16), \
            Instructions::_ori(1, 1, immed[15:0]), \
            Instructions::_``base``(rt, rs, 1) \
        }; \
    end \
    else begin \
        return { \
            Instructions::_``name``(rt, rs, immed[15:0]) \
        }; \
    end \
endfunction

`define MAKE_I_FORMAT_ASSEMBLER_MEM(name, base) \
function MultipleInstructions _``name``(Register rt, Register rs, OverflowingImmediate immed); \
    if ((immed < -32'sd32768) || (immed > 32'sd65535)) begin \
        return { \
            Instructions::_lui(1, immed >>> 16), \
            Instructions::_addu(1, 1, rs), \
            Instructions::_``base``(rt, 1, immed[15:0]) \
        }; \
    end \
    else if (immed > 32'sd32767) begin \
        return { \
            Instructions::_ori(1, 0, immed[15:0]), \
            Instructions::_addu(1, 1, rs), \
            Instructions::_``base``(rt, 1, 0) \
        }; \
    end \
    else begin \
        return { \
            Instructions::_``base``(rt, rs, immed[15:0]) \
        }; \
    end \
endfunction

// Helper functions for encoding supported MIPS instructions
package Instructions;

    typedef reg [31:0] Instruction;
    typedef reg [4:0] Register;
    typedef reg [5:0] Opcode;
    typedef reg [15:0] Immediate;

    typedef Instruction MultipleInstructions [];
    typedef reg signed [31:0] OverflowingImmediate;

    function Instruction rFormat(Register rs, Register rt, Register rd, Register shamt, Opcode funct);
        return { 6'b000000, rs, rt, rd, shamt, funct };
    endfunction

    function Instruction iFormat(Opcode opcode, Register rs, Register rt, Immediate immed);
        return { opcode, rs, rt, immed };
    endfunction

    `MAKE_R_FORMAT_THREE_REG(addu, 6'b100001)
    `MAKE_R_FORMAT_THREE_REG(and, 6'b100100)
    `MAKE_R_FORMAT_TWO_REG_NO_WRITE(div, 6'b011010)
    `MAKE_R_FORMAT_TWO_REG_NO_WRITE(divu, 6'b011011)
    `MAKE_R_FORMAT_ONE_REG_WRITE(mfhi, 6'b010000)
    `MAKE_R_FORMAT_ONE_REG_WRITE(mflo, 6'b010010)
    `MAKE_R_FORMAT_ONE_REG_READ(mthi, 6'b010001)
    `MAKE_R_FORMAT_ONE_REG_READ(mtlo, 6'b010011)
    `MAKE_R_FORMAT_TWO_REG_NO_WRITE(mult, 6'b011000)
    `MAKE_R_FORMAT_TWO_REG_NO_WRITE(multu, 6'b011001)
    `MAKE_R_FORMAT_THREE_REG(nor, 6'b100111)
    `MAKE_R_FORMAT_THREE_REG(or, 6'b100101)
    `MAKE_R_FORMAT_TWO_REG_SHIFT(sll, 6'b000000)
    `MAKE_R_FORMAT_THREE_REG_SHIFT(sllv, 6'b000100)
    `MAKE_R_FORMAT_THREE_REG(slt, 6'b101010)
    `MAKE_R_FORMAT_THREE_REG(sltu, 6'b101011)
    `MAKE_R_FORMAT_TWO_REG_SHIFT(sra, 6'b000011)
    `MAKE_R_FORMAT_THREE_REG_SHIFT(srav, 6'b000111)
    `MAKE_R_FORMAT_TWO_REG_SHIFT(srl, 6'b000010)
    `MAKE_R_FORMAT_THREE_REG_SHIFT(srlv, 6'b000110)
    `MAKE_R_FORMAT_THREE_REG(subu, 6'b100011)
    `MAKE_R_FORMAT_THREE_REG(xor, 6'b100110)
    `MAKE_R_FORMAT_ONE_REG_READ(syscall, 6'b001100)

    `MAKE_R_FORMAT_THREE_REG(seq, 6'b101110)

    `MAKE_I_FORMAT_TWO_REG(addiu, 6'b001001)
    `MAKE_I_FORMAT_TWO_REG(slti, 6'b001010)
    `MAKE_I_FORMAT_TWO_REG(sltiu, 6'b001011)
    `MAKE_I_FORMAT_TWO_REG(andi, 6'b001100)
    `MAKE_I_FORMAT_TWO_REG(ori, 6'b001101)
    `MAKE_I_FORMAT_TWO_REG(xori, 6'b001110)

    `MAKE_I_FORMAT_ONE_REG(lui, 6'b001111)

    `MAKE_I_FORMAT_MEM(lw, 6'b100011)
    `MAKE_I_FORMAT_MEM(sw, 6'b101011)

endpackage

    // Immediate values can be odd when working with two's complement
    // This assembler package assures the immediate value sent to the
    // instruction function is encoded properly
    // This may require multiple instructions to be executed
    package Assembler;

    import Instructions::*;

    `MAKE_I_FORMAT_ASSEMBLER_TWO_REG(addiu, addu)
    `MAKE_I_FORMAT_ASSEMBLER_TWO_REG(slti, slt)
    `MAKE_I_FORMAT_ASSEMBLER_TWO_REG(sltiu, sltu)
    `MAKE_I_FORMAT_ASSEMBLER_TWO_REG(andi, and)
    `MAKE_I_FORMAT_ASSEMBLER_TWO_REG(ori, or)
    `MAKE_I_FORMAT_ASSEMBLER_TWO_REG(xori, xor)

    `MAKE_I_FORMAT_ASSEMBLER_MEM(lw, lw)
    `MAKE_I_FORMAT_ASSEMBLER_MEM(sw, sw)

    function MultipleInstructions _li(Register rt, OverflowingImmediate immed);
        if ((immed < -32'sd32768) || (immed > 32'sd32767)) begin
            return {
                Instructions::_lui(1, immed >>> 16),
                Instructions::_ori(rt, 1, immed[15:0])
            };
        end
        else begin
            return {
                Instructions::_addiu(rt, 0, immed[15:0])
            };
        end
    endfunction

endpackage