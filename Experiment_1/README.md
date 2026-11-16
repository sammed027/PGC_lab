# Experiment 1 – Sequential Matrix Multiplication

## Aim
Implement matrix multiplication using a single CPU execution flow and establish a baseline for comparison with parallel implementations.

## Workload
- Matrix dimensions: 4000 × 4000
- Element type: double
- Input values: 1.0
- Expected output: every element equals 4000.00

## Source
- `src/matrix_sequential.c`

## Compile and run
From the repository root:

```bash
gcc -O2 Experiment_1/src/matrix_sequential.c -o sequential
./sequential
```

## Recorded result

| Measurement | Result |
|---|---:|
| Execution time | 417.205920 s |
| Verified output C[0][0] | 4000.00 |

## Conclusion
The sequential implementation provides the baseline execution time for evaluating OpenMP, MPI and GPU implementations of the same matrix multiplication workload. The timing is specific to the recorded system.
