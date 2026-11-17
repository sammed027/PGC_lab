# Experiment 1 — Sequential Matrix Multiplication

## Aim
Implement square matrix multiplication with a single CPU thread and record a baseline for later parallel implementations.

## Problem definition
Given two matrices A and B, calculate:

```text
C[i][j] = sum(A[i][k] * B[k][j]) for k = 0 ... N-1
```

| Parameter | Configuration |
|---|---|
| Matrix dimension | 4000 × 4000 |
| Data type | `double` |
| Input initialization | Every element of A and B is 1.0 |
| Algorithm | Three nested loops (i, j, k) |
| Time complexity | O(N^3) |
| Matrix storage | O(N^2) |

Since each output element is the sum of 4000 products of 1.0, the expected verification value is **C[0][0] = 4000.00**.

## Source file
- [`src/matrix_sequential.c`](src/matrix_sequential.c) — allocation, initialization, sequential multiplication, timing and output verification.

## Requirements
- GCC or another compatible C compiler
- Sufficient RAM for three 4000 × 4000 double-precision matrices (about 366 MiB of matrix data, excluding runtime overhead)

## Compile and run
Run these commands from the repository root:

```bash
gcc -O2 Experiment_1/src/matrix_sequential.c -o sequential
./sequential
```

The program reports the matrix size, elapsed time and `C[0][0]`. The timer surrounds the multiplication loop; allocation and initialization happen before timing.

## Recorded observation

| Measurement | Recorded value |
|---|---:|
| Execution time | 417.205920 s |
| Verification: C[0][0] | 4000.00 |

The execution time is a measurement from the recorded machine, not a universal expected runtime. The program uses C's `clock()` for timing.

## What to observe
1. The three loops perform one dot product for every output cell.
2. The same input values make the expected result easy to verify.
3. This sequential implementation is the reference workload for the parallel experiments.

## Conclusion
The program completes matrix multiplication without parallel workers and provides a correctness check and historical timing baseline. For a strict timing comparison, use the same wall-clock timing method and workload across all implementations.
