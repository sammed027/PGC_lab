# Experiment 1 – Performance Analysis of Sequential, OpenMP, MPI and CUDA Matrix Multiplication

## Aim

To implement matrix multiplication using sequential CPU execution, OpenMP, MPI and CUDA, then compare execution time and speedup.

## Problem

Multiply two 4000 × 4000 matrices initialized with 1.0.

```text
C = A × B
C[i][j] = Σ A[i][k] × B[k][j]
Expected value of every output element = 4000.00
```

## Implementations

| Implementation | Source file | Parallel model |
|---|---|---|
| Sequential | `src/matrix_sequential.c` | Single CPU execution flow |
| OpenMP | `src/matrix_openmp.c` | Shared-memory threads |
| MPI matrix multiplication | `src/matrix_mpi.c` | Distributed-memory processes |
| MPI send/receive | `src/mpi_send_recv.c` | Point-to-point message passing |

The CUDA implementation was part of the original experiment and its recorded result is included below. The CUDA source file was not present in the available repository files.

## Environment

- Matrix size: 4000 × 4000
- Matrix element type: double
- Input values: 1.0
- OpenMP threads: 12
- MPI processes: 4
- CUDA GPU recorded: NVIDIA GeForce RTX 2050
- CUDA compute capability recorded: 8.6

## Build and run

Run from the repository root.

### Sequential

```bash
gcc -O2 Experiment_1/src/matrix_sequential.c -o sequential
./sequential
```

### OpenMP

```bash
gcc -O2 -fopenmp Experiment_1/src/matrix_openmp.c -o openmp
OMP_NUM_THREADS=12 ./openmp
```

### MPI

```bash
mpicc -O2 Experiment_1/src/matrix_mpi.c -o matrix_mpi
mpirun -np 4 ./matrix_mpi
```

### MPI point-to-point communication

```bash
mpicc -O2 Experiment_1/src/mpi_send_recv.c -o mpi_send_recv
mpirun -np 2 ./mpi_send_recv
```

## Recorded results

| Method | Configuration | Execution time |
|---|---|---:|
| Sequential | 1 CPU execution flow | 417.205920 s |
| OpenMP | 12 threads | 230.801465 s |
| MPI | 4 processes / 4 VMs | 138.772617 s |
| CUDA kernel | NVIDIA GeForce RTX 2050 | 0.316872 s |
| CUDA total phase | Includes transfers and computation | 0.343028 s |

All recorded implementations verified the output element `C[0][0] = 4000.00`.

### Speedup relative to sequential execution

```text
OpenMP total speedup = 417.205920 / 230.801465 = 1.81×
MPI total speedup    = 417.205920 / 138.772617 = 3.01×
CUDA total speedup   = 417.205920 / 0.343028   = 1216.24×
```

The CUDA kernel-only time excludes host/device transfers. The CUDA total-phase time includes them. These measurements describe the recorded setup and should not be treated as universal performance values.

## Observations

1. Sequential execution provides the baseline.
2. OpenMP distributes row calculations among threads sharing memory.
3. MPI distributes rows among processes and uses message passing to distribute input data and collect results.
4. CUDA executes many output calculations in parallel on the GPU.
5. The recorded CUDA total-phase execution was substantially faster than the CPU and MPI implementations for this workload.

## Conclusion

The experiment compared four computing approaches for the same matrix multiplication workload. Each recorded implementation produced the expected output value. The measurements demonstrate the performance potential of shared-memory, distributed-memory and GPU parallelism for a compute-intensive matrix operation.
