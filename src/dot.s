.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Calculates sum(arr0[i * stride0] * arr1[i * stride1])
# where i ranges from 0 to (element_count - 1)
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
#
# Preconditions:
#   - Element count must be positive (>= 1)
#   - Both strides must be positive (>= 1)
#
# Error Handling:
#   - Exits with code 36 if element count < 1
#   - Exits with code 37 if any stride < 1
# =======================================================
dot:
    addi sp, sp, -40
    sw a1, 36(sp)
    sw a5, 32(sp)
    sw a6, 28(sp)
    sw ra, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)

    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  
    
    mv a5, a0    # Pointer to first input array
    mv a6, a1    # Pointer to second input array
    li s1, 0     # result     
    li s2, 0     # loop times    
    li s3, 0     # array index (0 base)
 
loop_start:
    bge s2, a2, loop_end          # End loop if all elements are processed

    # Calculate offset for current element in first array
    mv a0, a3                      # Load stride0 into a0
    mv a1, s3                      # Load index into a1
    jal ra, func_mul               # Call func_mul to calculate offset (a3 * s3)
    mv s4, a0                      # Store result in s4
    slli s4, s4, 2                 # Multiply offset by 4 (to convert index to bytes)
    add s4, s4, a5                 # Calculate address in the first array
    lw s4, 0(s4)                   # Load the value from the first array

    # Calculate offset for current element in second array
    mv a0, a4                      # Load stride1 into a0
    mv a1, s3                      # Load index into a1
    jal ra, func_mul               # Call func_mul to calculate offset (a4 * s3)
    mv s5, a0                      # Store result in s5
    slli s5, s5, 2                 # Multiply offset by 4 (to convert index to bytes)
    add s5, s5, a6                 # Calculate address in the second array
    lw s5, 0(s5)                   # Load the value from the second array

    # Multiply the two values and add to result accumulator
    mv a0, s4                      # Move first value to a0
    mv a1, s5                      # Move second value to a1
    jal ra, func_mul               # Call func_mul to calculate (s4 * s5)
    mv s6, a0                      # Store product in s6

    add s1, s1, s6                 # Add product to result accumulator
    addi s2, s2, 1                 # Increment loop counter
    addi s3, s3, 1                 # Increment index for next iteration
    j loop_start                   # Jump back to start of loop

loop_end:
    mv a0, s1                      # Move result to a0 for return

    # Restore saved registers and stack
    lw s6, 0(sp)
    lw s5, 4(sp)
    lw s4, 8(sp)
    lw s3, 12(sp)
    lw s2, 16(sp)
    lw s1, 20(sp)
    lw ra, 24(sp)
    lw a6, 28(sp)
    lw a5, 32(sp)
    lw a1, 36(sp)
    addi sp, sp, 40
    jr ra                          # Return to caller
    
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
    
error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit 
    
set_error_36:
    li a0, 36
    j exit
    
