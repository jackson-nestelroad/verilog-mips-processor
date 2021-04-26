# Test register file, saving immediate values
# li $8, -5512513
li $8, -5512513
li $9, 16
li $10, 2

# syscall $8
# syscall $9
# syscall $10 

addu $11, $8, $9
# syscall $11

and $11, $8, $9
# syscall $11

div $8, $9
mfhi $11
# syscall $11
mflo $11
# syscall $11

divu $8, $9
mfhi $11
# syscall $11
mflo $11
# syscall $11

mthi $8
mfhi $11
# syscall $11

mtlo $9
mflo $11
# syscall $11

mult $8, $9
mfhi $11
# syscall $11
mflo $11
# syscall $11

multu $8, $9
mfhi $11
# syscall $11
mflo $11
# syscall $11

nor $11, $8, $9
# syscall $11

or $11, $8, $9
# syscall $11

seq $11, $8, $9
# syscall $11

seq $11, $8, $8
# syscall $11

sll $11, $8, 4
# syscall $11

sllv $11, $8, $10
# syscall $11

slt $11, $8, $9
# syscall $11

sltu $11, $8, $9
# syscall $11

sra $11, $8, 4
# syscall $11

srav $11, $8, $10
# syscall $11

srl $11, $8, 4
# syscall $11

srlv $11, $8, $10
# syscall $11

subu $11, $8, $9
# syscall $11

xor $11, $8, $9
# syscall $11

addiu $11, $8, 1
# syscall $11

addiu $11, $8, -100
# syscall $11

addiu $11, $8, 500000
# syscall $11

slti $11, $8, 100
# syscall $11

sltiu $11, $8, 100
# syscall $11

andi $11, $8, 100
# syscall $11

ori $11, $8, 100
# syscall $11

xori $11, $8, 100
# syscall $11

lui $11, 100
# syscall $11

li $12, 100
sw $8, 0($12)
lw $11, 0($12)
# syscall $11

sw $9, 16($12)
lw $11, 16($12)
# syscall $11