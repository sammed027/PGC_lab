# Experiment 3 — MPI Matrix Multiplication and Message Passing

## Aim
Use MPI processes to distribute matrix multiplication across a set of processes and demonstrate point-to-point communication.

## Part A — Distributed matrix multiplication

The program partitions the rows of matrix A among all MPI processes. Each process receives its portion of A, computes the corresponding rows of C using the full matrix B, and returns its result to rank 0.

### Workload

| Parameter | Configuration |
|---|---|
| Matrix dimension | 4000 × 4000 |
| Data type | `double` |
| Input initialization | All elements of A and B are 1.0 on rank 0 |
| Recorded process count | 4 |
| Partition | Equal row blocks |
| Expected verification | C[0][0] = 4000.00 |

The implementation checks that 4000 is divisible by the MPI process count. Use a process count that divides the matrix dimension.

### Communication sequence

1. **Initialize:** rank 0 allocates and initializes A and B.
2. **Broadcast:** rank 0 sends B to every process with `MPI_Bcast`.
3. **Scatter:** rows of A are distributed using `MPI_Scatter`.
4. **Compute:** each process calculates its local rows of C.
5. **Gather:** local result blocks are assembled on rank 0 with `MPI_Gather`.

### Source file
- [`src/matrix_mpi.c`](src/matrix_mpi.c) — distributed matrix multiplication.

### Compile and run
Install an MPI implementation such as Open MPI, then run from the repository root:

```bash
mpicc -O2 Experiment_3/src/matrix_mpi.c -o matrix_mpi
mpirun -np 4 ./matrix_mpi
```

The printed execution time includes the scatter, local calculation and gather phases. The broadcast of B and initial setup occur before the timer starts.

## Part B — Point-to-point send and receive

- [`src/mpi_send_recv.c`](src/mpi_send_recv.c) — rank 0 sends integer value `10` to rank 1 using `MPI_Send`; rank 1 receives it using `MPI_Recv`.

Compile and run:

```bash
mpicc -O2 Experiment_3/src/mpi_send_recv.c -o mpi_send_recv
mpirun -np 2 ./mpi_send_recv
```

Use at least two processes for this program.

## Recorded observation

| Measurement | Recorded value |
|---|---:|
| MPI process count | 4 |
| Execution time | 138.772617 s |
| Sequential reference time | 417.205920 s |
| Reported speedup | 3.01× |
| Verification: C[0][0] | 4000.00 |

These results were captured in a four-process/VM environment and can change with CPU allocation, network performance, MPI implementation and process placement.

## What to observe
- MPI uses separate process address spaces rather than one shared address space.
- Collective communication distributes and collects matrix data.
- Point-to-point communication requires matching send and receive operations.
- Communication overhead can limit the speedup of distributed workloads.

## Conclusion
The experiment demonstrates row-wise work distribution and message passing. Rank 0 gathers the completed matrix, and the verification value confirms the expected result for the uniform input.
