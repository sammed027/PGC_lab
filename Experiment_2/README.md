# Experiment 2 – OpenMP Matrix Multiplication

## Aim
Parallelize matrix multiplication on a shared-memory CPU using OpenMP threads and compare its performance with the sequential baseline.

## Workload and configuration
- Matrix dimensions: 4000 × 4000
- Element type: double
- Input values: 1.0
- OpenMP threads: 12
- Expected output element: 4000.00

## Source
- `src/matrix_openmp.c`

## Compile and run
From the repository root:

```bash
gcc -O2 -fopenmp Experiment_2/src/matrix_openmp.c -o openmp
OMP_NUM_THREADS=12 ./openmp
```

## Recorded result

| Measurement | Result |
|---|---:|
| Execution time | 230.801465 s |
| Sequential baseline | 417.205920 s |
| Speedup over sequential | 1.81× |
| Verified output C[0][0] | 4000.00 |

## Conclusion
OpenMP distributes matrix calculations across threads that share the same address space. The recorded 12-thread run was faster than the sequential baseline. Results depend on processor, compiler and runtime configuration.
