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
    li t0, 1
    blt a2, t0, error_terminate  
    blt a3, t0, error_terminate   
    blt a4, t0, error_terminate  
    slli a3, a3, 2      # a3 = 4 * a3
    slli a4, a4, 2      # a4 = 4 * a4

    li t0, 0            # t0 is dot sum
    li t1, 0            # t1 is i
loop_start:
    # TODO: Add your own implementation
    lw t2, 0(a0)        # extract current arr0 element to t2
    lw t3, 0(a1)        # extract current arr1 element to t3
    # calculate t2 * t3
    li t4, 0            # set mul_sum = 0
    mul_loop:
        beqz t3, mul_end     # if t3 is 0, then the multiplication is done
        andi t5, t3, 1       # check the LSB of t3 
        beqz t5, mul_skip_add # if LSB is 0, then skip
        add t4, t4, t2       # mul_sum += t2
    mul_skip_add:
        srli t3, t3, 1       # t3 >>= 1
        slli t2, t2, 1       # t2 <<= 1
        j mul_loop
    mul_end:
    add t0, t0, t4
    add a0, a0, a3      # move to next arr0 element
    add a1, a1, a4      # move to next arr1 element
    addi t1, t1, 1
    blt t1, a2, loop_start

loop_end:
    mv a0, t0
    jr ra

error_terminate:
    blt a2, t0, set_error_36
    li a0, 37
    j exit

set_error_36:
    li a0, 36
    j exit
