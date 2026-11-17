# Experiment 2 — OpenMP Matrix Multiplication

## Aim
Parallelize matrix multiplication on a shared-memory CPU using OpenMP and compare the result with the sequential implementation.

## Problem and parallel strategy
The experiment uses the same 4000 × 4000 double-precision matrices as Experiment 1. Each output row is independent, so the outer loop is parallelized with:

```c
#pragma omp parallel for schedule(static)
```

OpenMP divides row iterations among threads. The input matrices are shared, while each loop iteration writes to a distinct output row.

| Parameter | Configuration |
|---|---|
| Matrix dimension | 4000 × 4000 |
| Data type | `double` |
| Input initialization | All elements are 1.0 |
| Parallel model | OpenMP shared-memory threads |
| Scheduling | Static row assignment |
| Recorded thread setting | 12 |
| Expected C[0][0] | 4000.00 |

## Source file
- [`src/matrix_openmp.c`](src/matrix_openmp.c) — OpenMP matrix multiplication using `omp_get_wtime()`.

## Requirements
- GCC with OpenMP support
- A system with enough memory for the three matrices

## Compile and run
Run from the repository root:

```bash
gcc -O2 -fopenmp Experiment_2/src/matrix_openmp.c -o openmp
OMP_NUM_THREADS=12 ./openmp
```

Change `OMP_NUM_THREADS` to experiment with a different thread count. The program prints the maximum OpenMP thread setting visible to its runtime.

## Recorded observation

| Measurement | Recorded value |
|---|---:|
| Execution time | 230.801465 s |
| Sequential reference time | 417.205920 s |
| Reported speedup | 1.81× |
| Verification: C[0][0] | 4000.00 |

The speedup is the ratio of the two recorded times. Treat it as an observation from the recorded environment, not a guaranteed result. Experiment 1 uses `clock()`, while this program uses OpenMP wall-clock timing; rerun both with a common timing method for a rigorous comparison.

## What to observe
- Rows are independent, so separate threads can calculate them concurrently.
- Static scheduling assigns predictable chunks of loop iterations.
- Increasing the thread count does not guarantee linear speedup; available cores, memory bandwidth and scheduling overhead affect performance.

## Conclusion
OpenMP adds shared-memory parallelism without changing the mathematical workload. The computed verification value matches the sequential result, while the measured runtime depends on the hardware and runtime configuration.
