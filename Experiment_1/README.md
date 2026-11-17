# Experiment 1 — Sequential Matrix Multiplication

## 1. Aim

To implement square matrix multiplication using a conventional sequential CPU program, understand the role of nested loops in matrix computation, verify the numerical output and establish a baseline execution time for comparison with parallel implementations.

## 2. Introduction

Matrix multiplication is a fundamental operation in scientific computing, engineering simulations, image processing and machine learning. It combines values from rows of one matrix with values from columns of another matrix. The operation is computationally intensive for large matrices and is therefore a useful example for studying performance optimization.

In this experiment, the computation is performed by a single sequential execution flow. No OpenMP threads, MPI processes or CUDA kernels are used. The program therefore provides a reference implementation against which later parallel approaches can be compared.

## 3. Mathematical formulation

Let A and B be two square matrices of dimension N × N. Their product C is also an N × N matrix. Each element of the output is calculated as:

```text
C[i][j] = Σ A[i][k] × B[k][j], for k = 0 to N-1
```

The program uses three nested loops:
- The outer loop selects the row of A and C.
- The middle loop selects the column of B and C.
- The inner loop calculates the dot product of the selected row and column.

The inner loop accumulates the products into one output element before the program moves to the next column.

## 4. Experimental configuration

| Parameter | Value |
|---|---|
| Matrix dimension | 4000 × 4000 |
| Numeric type | `double` |
| Number of matrices | 3 (A, B and C) |
| Input initialization | Every element of A and B is 1.0 |
| Execution model | Sequential, single execution flow |
| Algorithm | Three nested loops |
| Time complexity | O(N³) |
| Storage complexity | O(N²) |

For N = 4000, each output element is the sum of 4000 products. Since every input element is 1.0, the expected value of every output element is 4000. In particular, the program checks **C[0][0] = 4000.00**.

## 5. Source-code organization

- [`src/matrix_sequential.c`](src/matrix_sequential.c) — contains matrix allocation, initialization, the sequential multiplication loops, timing and output verification.

The implementation follows the conventional row-by-column multiplication method. The input matrices are prepared before the multiplication section begins, and the measured interval is focused on the computation rather than the allocation and initialization phases.

## 6. Requirements

- A C compiler such as GCC.
- A Linux or compatible command-line environment.
- Sufficient available memory for the three matrices.
- Basic understanding of arrays, nested loops and floating-point values.

Each 4000 × 4000 matrix of double-precision values requires approximately 122.1 MiB in decimal units (about 122 MiB). Three such matrices therefore require approximately 366 MiB, excluding the executable, runtime and operating-system overhead. The system should have additional free memory.

## 7. Compilation and execution

Run the following commands from the repository root:

```bash
gcc -O2 Experiment_1/src/matrix_sequential.c -o sequential
./sequential
```

The `-O2` option enables compiler optimization. The generated executable is named `sequential`. On successful execution, the program reports the matrix dimension, elapsed computation time and a sample output element.

## 8. Execution procedure

1. Open a terminal in the repository directory.
2. Confirm that the source file exists at the path shown above.
3. Compile the C source using GCC.
4. Run the generated executable.
5. Observe the matrix dimension and execution-time output.
6. Verify that the displayed sample element is 4000.00.
7. Record the system configuration and preserve a screenshot of the genuine terminal output for the practical record.

## 9. Recorded result

| Measurement | Recorded value |
|---|---:|
| Matrix size | 4000 × 4000 |
| Execution time | 417.205920 s |
| Expected sample element | 4000.00 |
| Recorded sample element | 4000.00 |

The recorded program uses C's `clock()` function for timing. The reported duration is retained as the historical observation from the recorded run. Actual time can vary with processor model, compiler optimization, memory subsystem, system load and virtual-machine configuration.

## 10. Result verification

The uniform input makes the expected result straightforward to calculate independently. For any output position (i, j), the program adds N values, and every multiplication is 1.0 × 1.0. Therefore:

```text
C[i][j] = 1 + 1 + ... + 1  (N terms)
        = N
        = 4000
```

The observed value of 4000.00 at C[0][0] is consistent with the mathematical expectation. Checking a sample element is a useful basic correctness check; a complete numerical validation would inspect all output elements.

## 11. Complexity analysis

The outer two loops visit N² output positions. For every position, the inner loop performs N multiply-accumulate iterations. The total computational work therefore grows proportionally to N³. The three matrices require storage proportional to N².

This growth explains why large matrix dimensions can take considerable time on a sequential processor. It also motivates later experiments that divide the output rows or output elements among multiple processing units.

## 12. Discussion and observations

- The program uses a direct and easy-to-understand algorithm.
- Each output cell is independent mathematically, but the sequential implementation calculates the cells one after another.
- The large number of arithmetic operations makes matrix multiplication a suitable benchmark for parallelization.
- The measured time includes the multiplication region identified by the program, not the earlier allocation and initialization work.
- The result is a baseline, not a universal benchmark for every CPU.

## 13. Conclusion

The experiment successfully demonstrates sequential square matrix multiplication using three nested loops. The output verification value agrees with the expected mathematical result, and the recorded execution time provides a reference point for the subsequent OpenMP, MPI and CUDA implementations. The experiment establishes the importance of correctness validation and clearly defined timing before performance comparisons are made.
