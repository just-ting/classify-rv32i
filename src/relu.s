.globl relu

.text
# ==============================================================================
# FUNCTION: Array ReLU Activation
#
# Applies ReLU (Rectified Linear Unit) operation in-place:
# For each element x in array: x = max(0, x)
#
# Arguments:
#   a0: Pointer to integer array to be modified
#   a1: Number of elements in array
#
# Returns:
#   None - Original array is modified directly
#
# Validation:
#   Requires non-empty array (length ≥ 1)
#   Terminates (code 36) if validation fails
#
# Example:
#   Input:  [-2, 0, 3, -1, 5]
#   Result: [ 0, 0, 3,  0, 5]
# ==============================================================================
relu:
    li t0, 1             
    blt a1, t0, error     
    li t1, 0  # index             

loop_start:
    # TODO: Add your own implementation
	bge t1, a1, loop_end
	slli t2, t1, 2
	add t2, t2, a0
	lw t3, 0(t2)
	blt t3, zero, neg
	addi t1, t1, 1
	j loop_start
	neg:
		sw zero,0(t2)
		j loop_start 

error:
    li a0, 36          
    j exit          

loop_end:
    nop
