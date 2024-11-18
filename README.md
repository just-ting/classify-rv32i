# Assignment 2: Classify

## Part A: Mathematical Functions
### Task 1: ReLU
#### I traverse an array to check every element if it is negative. If TRUE, then change the negative one to `zero`.

1. Check if the pointer to integer array points to last one.
```
bge t1, a1, loop_end
```
2. Load the element of integer array.
```
slli t2, t1, 2
add t2, t2, a0
lw t3, 0(t2)
```
3. Check if negative.
```
blt t3, zero, neg
addi t1, t1, 1
j loop_start
```
4. If negative, change the value to zero.
```
neg:
sw zero,0(t2)
j loop_start
```
### Task 2: ArgMax
### Task 3.1: Dot Product
### Task 3.2: Matrix Multiplication
## Part B: File Operations and Main
### Task 1: Read Matrix
### Task 2: Write Matrix
### Task 3: Classification
