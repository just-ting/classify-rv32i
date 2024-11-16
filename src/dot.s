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

    li t0, 0  # result           
    li t1, 0  # index         

loop_start:
    bge t1, a2, loop_end
    # TODO: Add your own implementation
	mv t2, a3
	li t3, 0
	stride0_mul:
		bge zero, t2, stride0_mul_done
		add t3, t3, t1  
		addi t2, t2, -1
		j stride0_mul
	stride0_mul_done:
		li t3, 0
		mv t2, a4
	stride1_mul:
		bge zero, t2, stride1_mul_done
		add t4, t4, t1
		addi t2, t2, -1
		j stride1_mul
	stride1_mul_done:
		slli t3, t3, 2 
		slli t4, t4, 2
		add t3, t3, a0 # t3 = a0 + (i * stride0 * 4)
		add t4, t4, a1 # t4 = a1 + (i * stride1 * 4)
		lw t5, 0(t3)
		lw t6, 0(t4)
	li t2, 0
	mul_loop:
		bge t2, t6, mul_done
		add t0, t0, t5
		addi t2, t2, 1
		j mul_loop

	mul_done:
		addi t1, t1, 1
		j loop_start

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
