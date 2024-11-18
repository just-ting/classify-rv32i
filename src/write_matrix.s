.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Write a matrix of integers to a binary file
# FILE FORMAT:
#   - The first 8 bytes store two 4-byte integers representing the number of 
#     rows and columns, respectively.
#   - Each subsequent 4-byte segment represents a matrix element, stored in 
#     row-major order.
#
# Arguments:
#   a0 (char *) - Pointer to a string representing the filename.
#   a1 (int *)  - Pointer to the matrix's starting location in memory.
#   a2 (int)    - Number of rows in the matrix.
#   a3 (int)    - Number of columns in the matrix.
#
# Returns:
#   None
#
# Exceptions:
#   - Terminates with error code 27 on `fopen` error or end-of-file (EOF).
#   - Terminates with error code 28 on `fclose` error or EOF.
#   - Terminates with error code 30 on `fwrite` error or EOF.
# ==============================================================================
write_matrix:
    # Prologue
    addi sp, sp, -44
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    # save arguments
    mv s1, a1        # s1 = matrix pointer
    mv s2, a2        # s2 = number of rows
    mv s3, a3        # s3 = number of columns

    li a1, 1

    jal fopen

    li t0, -1
    beq a0, t0, fopen_error   # fopen didn't work

    mv s0, a0        # file descriptor

    # Write number of rows and columns to file
    sw s2, 24(sp)    # number of rows
    sw s3, 28(sp)    # number of columns

    mv a0, s0
    addi a1, sp, 24  # buffer with rows and columns
    li a2, 2         # number of elements to write
    li a3, 4         # size of each element

    jal fwrite

    li t0, 2
    bne a0, t0, fwrite_error

    # mul s4, s2, s3   # s4 = total elements
    # FIXME: Replace 'mul' with your own implementation
    addi sp, sp, -32
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw t0, 12(sp)
    sw t1, 16(sp)
    sw t2, 20(sp)
    sw t3, 24(sp)
    sw t4, 28(sp)
    mv a0, s2
    mv a1, s3
    jal func_mul
    mv s4, a0
    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw t0, 12(sp)
    lw t1, 16(sp)
    lw t2, 20(sp)
    lw t3, 24(sp)
    lw t4, 28(sp)
    addi sp, sp, 32
    
    # write matrix data to file
    mv a0, s0
    mv a1, s1        # matrix data pointer
    mv a2, s4        # number of elements to write
    li a3, 4         # size of each element

    jal fwrite

    bne a0, s4, fwrite_error

    mv a0, s0

    jal fclose

    li t0, -1
    beq a0, t0, fclose_error

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44

    jr ra

fopen_error:
    li a0, 27
    j error_exit

fwrite_error:
    li a0, 30
    j error_exit

fclose_error:
    li a0, 28
    j error_exit

error_exit:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44
    j exit
   
func_two_sort:
    ####
    # a0 : Addr(array)
    ####
    
    lw t0, 0(a0)
    lw t1, 4(a0)
    
    bgeu t1, t0, endSwap

swap:
    sw t1, 0(a0)
    sw t0, 4(a0)

endSwap:
    ret
func_mul:
    ####
    # a0 : Multiplicand / return value
    # a1 : Multiplier
    # s0 : result
    ####
    
    # Calle saved
    addi sp, sp, -4
    sw s0, 0(sp)
    
    # Set result = 0
    li s0, 0
    
    # t0 = abs(Multiplicand)
    srai t3, a0, 31
    xor t0, a0, t3
    sub t0, t0, t3
    
    # t1 = abs(Multplier)
    srai t4, a1, 31
    xor t1, a1, t4
    sub t1, t1, t4
    
    # t2 = (is_result_positive) ? 0 : -1
    xor t2, t3, t4
    
    ## sort t0, t1
    # Caller saved
    addi sp, sp, -16
    sw ra, 12(sp)
    sw t2, 8(sp)
    sw t1, 4(sp)
    sw t0, 0(sp)
    
    # Pass the parameters
    addi a0, sp, 0
    
    # Jump to func_two_sort
    jal ra, func_two_sort
    ###
    
    # t0 < t1
    lw t0, 0(sp)
    lw t1, 4(sp)
    lw t2, 8(sp)
    
    # Consecutive addition to implement multiplication
    li t3, 0
    bgeu t3, t0, endMulLoop
    
mulLoop:
    add s0, s0, t1
    addi t3, t3, 1
    bltu t3, t0, mulLoop
    
endMulLoop:
    # s0 is abs(Multiplicand * Multiplier) now
    # According t2 to keep s0 positive or turn s0 to negative
    xor s0, s0, t2
    sub s0, s0, t2
    
    # Store return value in a0
    mv a0, s0
    
    # Retrieve ra & Calle saved
    lw ra, 12(sp)
    lw s0, 16(sp)
    addi sp, sp, 20
    
    ret
