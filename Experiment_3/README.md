# Experiment 3 – MPI Matrix Multiplication

## Aim
Implement distributed-memory matrix multiplication using MPI processes and demonstrate point-to-point communication.

## Sources
- `src/matrix_mpi.c` – distributed matrix multiplication
- `src/mpi_send_recv.c` – basic MPI send/receive demonstration

## Compile and run
From the repository root:

```bash
mpicc -O2 Experiment_3/src/matrix_mpi.c -o matrix_mpi
mpirun -np 4 ./matrix_mpi

mpicc -O2 Experiment_3/src/mpi_send_recv.c -o mpi_send_recv
mpirun -np 2 ./mpi_send_recv
```

## Matrix multiplication workload
- Matrix dimensions: 4000 × 4000
- Element type: double
- Input values: 1.0
- MPI processes: 4
- Expected output element: 4000.00

## Recorded result

| Measurement | Result |
|---|---:|
| Execution time | 138.772617 s |
| Sequential baseline | 417.205920 s |
| Speedup over sequential | 3.01× |
| Verified output C[0][0] | 4000.00 |

The timing was recorded using four processes/VMs and is specific to that environment.

## Conclusion
MPI distributes work across processes and exchanges data through message passing. The experiment includes both a matrix multiplication implementation and a small send/receive program.
