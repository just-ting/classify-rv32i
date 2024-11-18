# Assignment 2: Classify

## Part A: Mathematical Functions
### Task 1: ReLU
In `relu.s`, implement the ReLU function, which applies the transformation: 
<p class="text-center">
    $$ReLU = max(a,0)$$
</p>

Each element of the input array will be individually processed by setting negative values to 0. Since the matrix is stored as a 1D row-major vector, this function operates directly on the flattened array.

I traverse an array to check every element if it is negative. If TRUE, then change the negative one to `zero`.

1. Check if the pointer to integer array points to last one.
```asm
bge t1, a1, loop_end
```
2. Load the element of integer array.
```asm
slli t2, t1, 2
add t2, t2, a0
lw t3, 0(t2)
```
3. Check if negative.
```asm
blt t3, zero, neg
addi t1, t1, 1
j loop_start
```
4. If negative, change the value to zero.
```asm
neg:
sw zero,0(t2)
j loop_start
```
### Task 2: ArgMax
In `argmax.s`, implement the argmax function, which returns the index of the largest element in a given vector. If multiple elements share the largest value, return the smallest index. This function operates on 1D vectors.

I use two pointers to compare the elements in the array. `t1` stores the first largest element, while `t2` is used to traverse the entire array, visiting each element until all elements have been processed.

```asm
loop_start:
	bge t2, a1, loop_end
	slli t3, t2, 2
	add t3, t3, a0
	lw t4, 0(t3)
	bge t0, t4, next_step  # if t0 >= t4 then next_step
	mv t1, t2
	mv t0, t4
next_step:
	addi t2, t2, 1
	j loop_start
loop_end:
    # Return the index of the first maximum value
    mv a0, t1
    jr ra
```
### Task 3.1: Dot Product
In `dot.s`, implement the dot product function, defined as:

$$dot(a, b) = \sum_{i=0}^n (a_i\cdot b_i)$$

`dot.s` calculates a **strided dot product**, where the elements of two arrays are multiplied in a manner that incorporates a stride (or step) between elements. Specifically, it calculates:

$$\text{dot product} = \sum_{i=0}^{\text{element count} - 1} \left( \text{arr0}[i \times \text{stride0}] \times \text{arr1}[i \times \text{stride1}] \right)
$$

1. Each stride value (`stride0` and `stride1`) is multiplied by 4 to convert it to a byte offset.
```asm
slli a3, a3, 2  # Multiply stride0 by 4 (assuming each element is 4 bytes)
slli a4, a4, 2  # Multiply stride1 by 4 (assuming each element is 4 bytes)
```
2. In each loop iteration, load the elements from both arrays using the stride values. Then, implement multiplication through accumulative addition.
```asm
li t0, 0  # Initialize result to 0
li t1, 0  # Initialize index to 0
loop_start:

lw t2, 0(a0)  # Load arr0[i * stride0] element
lw t3, 0(a1)  # Load arr1[i * stride1] element

li t4, 0  # Initialize the product accumulator
mul_loop:
    beqz t3, mul_end  # If arr1 element is 0, jump to multiplication end
    andi t5, t3, 1  # Check if the least significant bit of t3 is 1
    beqz t5, mul_skip  # If the bit is 0, skip the multiplication
    add t4, t4, t2  # If the bit is 1, add arr0[i] to the product accumulator
mul_skip:
    srli t3, t3, 1  # Right shift t3 to check the next bit
    slli t2, t2, 1  # Left shift t2 to move to the next element in arr0
    j mul_loop  # Repeat the loop
mul_end:
```
### Task 3.2: Matrix Multiplication
In `matmul.s`, implement matrix multiplication, where:
$$C[i][j] = dot(A[i],B[:,j])$$
1. The outer loop counter `s0` is incremented, and the pointer for matrix `M0` (`s3`) is updated to point to the next row.
```asm
inner_loop_end:
	addi s0, s0, 1       
    slli t1, a2, 2      
    add s3, s3, t1      
    j outer_loop_start
```
2. The function's epilogue restores the saved registers and return address from the stack and returns to the caller.
```asm
outer_loop_end:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    ret
```

## Part B: File Operations and Main
### Task 1: Read Matrix
In `read_matrix.s`, implement the function to read a binary matrix from a file and load it into memory.
1. Call a function `mul_func` to calculate matrix data size, and store the result in `s1`.
```asm
addi sp, sp, -16
sw ra, 0(sp)
sw t0, 4(sp)
sw t1, 8(sp)
sw t2, 12(sp)
jal ra, mul_func
lw ra, 0(sp)
lw t0, 4(sp)
lw t1, 8(sp)
lw t2, 12(sp)
addi sp, sp, 16
```
2. Use `mul_func` function computes the product of two numbers:
```asm
mul_func:
    # Prologue
    addi sp, sp, -4
    sw s0, 0(sp)
    li s0, 0  # Initialize product to 0
    li t0, 0  # Loop counter
    bge t0, t1, mul_loop_end  # If counter >= t1, exit loop

mul_loop:
    add s0, s0, t2  # Add t2 to product
    addi t0, t0, 1  # Increment counter
    blt t0, t1, mul_loop  # Continue loop if counter < t1

mul_loop_end:
    mv s1, s0  # Store result in s1
    lw s0, 0(sp)
    addi sp, sp, 4
    ret
```

### Task 2: Write Matrix
In `write_matrix.s`, implement the function to write a matrix to a binary file.
1. Call a function `mul_func` to calculate matrix data size, and store the result in `s1`.
```asm
addi sp, sp, -16
sw ra, 0(sp)
sw t0, 4(sp)
sw t1, 8(sp)
sw t2, 12(sp)
jal ra, mul_func
lw ra, 0(sp)
lw t0, 4(sp)
lw t1, 8(sp)
lw t2, 12(sp)
addi sp, sp, 16
```
2. Use `mul_func` function computes the product of two numbers:
```asm
mul_func:
    # Prologue
    addi sp, sp, -4
    sw s0, 0(sp)
    li s0, 0  # Initialize product to 0
    li t0, 0  # Loop counter
    bge t0, t1, mul_loop_end  # If counter >= t1, exit loop

mul_loop:
    add s0, s0, t2  # Add t2 to product
    addi t0, t0, 1  # Increment counter
    blt t0, t1, mul_loop  # Continue loop if counter < t1

mul_loop_end:
    mv s1, s0  # Store result in s1
    lw s0, 0(sp)
    addi sp, sp, 4
    ret
```

### Task 3: Classification
In `classify.s`, bring everything together to classify an input using two weight matrices and the ReLU and ArgMax functions.
1. Replacment 4 places of `mul`. Call a function `mul_func` to calculate matrix data size, and store the result in `s1`.
```asm
addi sp, sp, -12
sw ra, 0(sp)
sw a2, 4(sp) # return
sw t2, 8(sp) # counter	
jal ra, mul_func
mv a1, a2
lw ra, 0(sp)
lw a2, 4(sp)
lw t2, 8(sp)
addi sp, sp, 12
```
2. Use `mul_func` function computes the product of two numbers:
```asm
mul_func:
    # Prologue
    addi sp, sp, -4
    sw s0, 0(sp)
    li s0, 0  # tmp
    li t2, 0  # counter
    bge t2, t0, mul_loop_end 

mul_loop:
	add s0, s0, t1
	addi t2, t2, 1
	blt t2, t0, mul_loop

mul_loop_end: 
	# store resullt
	mv a2, s0
	lw s0, 0(sp)
	addi sp, sp, 4
	jr ra
```
## Result
Environment: Mac
```bash
test_abs_minus_one (__main__.TestAbs.test_abs_minus_one) ... ok
test_abs_one (__main__.TestAbs.test_abs_one) ... ok
test_abs_zero (__main__.TestAbs.test_abs_zero) ... ok
test_argmax_invalid_n (__main__.TestArgmax.test_argmax_invalid_n) ... ok
test_argmax_length_1 (__main__.TestArgmax.test_argmax_length_1) ... ok
test_argmax_standard (__main__.TestArgmax.test_argmax_standard) ... ok
test_chain_1 (__main__.TestChain.test_chain_1) ... ok
test_classify_1_silent (__main__.TestClassify.test_classify_1_silent) ... ok
test_classify_2_print (__main__.TestClassify.test_classify_2_print) ... ok
test_classify_3_print (__main__.TestClassify.test_classify_3_print) ... ok
test_classify_fail_malloc (__main__.TestClassify.test_classify_fail_malloc) ... ok
test_classify_not_enough_args (__main__.TestClassify.test_classify_not_enough_args) ... ok
test_dot_length_1 (__main__.TestDot.test_dot_length_1) ... ok
test_dot_length_error (__main__.TestDot.test_dot_length_error) ... ok
test_dot_length_error2 (__main__.TestDot.test_dot_length_error2) ... ok
test_dot_standard (__main__.TestDot.test_dot_standard) ... ok
test_dot_stride (__main__.TestDot.test_dot_stride) ... ok
test_dot_stride_error1 (__main__.TestDot.test_dot_stride_error1) ... ok
test_dot_stride_error2 (__main__.TestDot.test_dot_stride_error2) ... ok
test_matmul_incorrect_check (__main__.TestMatmul.test_matmul_incorrect_check) ... ok
test_matmul_length_1 (__main__.TestMatmul.test_matmul_length_1) ... ok
test_matmul_negative_dim_m0_x (__main__.TestMatmul.test_matmul_negative_dim_m0_x) ... ok
test_matmul_negative_dim_m0_y (__main__.TestMatmul.test_matmul_negative_dim_m0_y) ... ok
test_matmul_negative_dim_m1_x (__main__.TestMatmul.test_matmul_negative_dim_m1_x) ... ok
test_matmul_negative_dim_m1_y (__main__.TestMatmul.test_matmul_negative_dim_m1_y) ... ok
test_matmul_nonsquare_1 (__main__.TestMatmul.test_matmul_nonsquare_1) ... ok
test_matmul_nonsquare_2 (__main__.TestMatmul.test_matmul_nonsquare_2) ... ok
test_matmul_nonsquare_outer_dims (__main__.TestMatmul.test_matmul_nonsquare_outer_dims) ... ok
test_matmul_square (__main__.TestMatmul.test_matmul_square) ... ok
test_matmul_unmatched_dims (__main__.TestMatmul.test_matmul_unmatched_dims) ... ok
test_matmul_zero_dim_m0 (__main__.TestMatmul.test_matmul_zero_dim_m0) ... ok
test_matmul_zero_dim_m1 (__main__.TestMatmul.test_matmul_zero_dim_m1) ... ok
test_read_1 (__main__.TestReadMatrix.test_read_1) ... ok
test_read_2 (__main__.TestReadMatrix.test_read_2) ... ok
test_read_3 (__main__.TestReadMatrix.test_read_3) ... ok
test_read_fail_fclose (__main__.TestReadMatrix.test_read_fail_fclose) ... ok
test_read_fail_fopen (__main__.TestReadMatrix.test_read_fail_fopen) ... ok
test_read_fail_fread (__main__.TestReadMatrix.test_read_fail_fread) ... ok
test_read_fail_malloc (__main__.TestReadMatrix.test_read_fail_malloc) ... ok
test_relu_invalid_n (__main__.TestRelu.test_relu_invalid_n) ... ok
test_relu_length_1 (__main__.TestRelu.test_relu_length_1) ... ok
test_relu_standard (__main__.TestRelu.test_relu_standard) ... ok
test_write_1 (__main__.TestWriteMatrix.test_write_1) ... ok
test_write_fail_fclose (__main__.TestWriteMatrix.test_write_fail_fclose) ... ok
test_write_fail_fopen (__main__.TestWriteMatrix.test_write_fail_fopen) ... ok
test_write_fail_fwrite (__main__.TestWriteMatrix.test_write_fail_fwrite) ... ok

----------------------------------------------------------------------
Ran 46 tests in 35.327s

OK
```
