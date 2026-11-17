# Experiment 3 — MPI Matrix Multiplication and Message Passing

## 1. Aim

To implement distributed matrix multiplication using the Message Passing Interface (MPI), understand communication among independent processes, study collective and point-to-point communication routines, and validate the output and recorded performance of a multi-process execution.

## 2. Introduction

MPI is a standard programming interface used to develop parallel programs in which multiple processes cooperate to solve a problem. Unlike a shared-memory model, MPI processes generally have separate address spaces. A process cannot directly read another process's local variables; information must be transferred through explicit communication operations.

This experiment demonstrates two important MPI programming patterns:
1. Distributing a matrix computation among processes using collective communication.
2. Sending a value from one process to another using point-to-point communication.

## 3. Part A — Distributed matrix multiplication

### 3.1 Mathematical operation

The program computes the product of two square matrices A and B:

```text
C[i][j] = Σ A[i][k] × B[k][j], for k = 0 to N-1
```

The matrix dimension is 4000 × 4000. Both input matrices are initialized with 1.0, so the expected value for each output element is 4000.00.

### 3.2 Process and data distribution

The implementation uses MPI ranks to identify participating processes. Rank 0 performs the initial setup and coordinates distribution and collection of data. Rows of A are divided into blocks, and each process calculates the output rows corresponding to its assigned block.

The program checks that the matrix dimension is divisible by the number of processes so that the row blocks can be distributed evenly by the implementation.

### 3.3 Communication workflow

The main communication stages are:

1. **MPI initialization:** each process joins the MPI execution environment and obtains its rank and the total process count.
2. **Input preparation:** rank 0 allocates and initializes matrices A and B.
3. **Broadcast:** `MPI_Bcast` distributes matrix B to all participating processes. Every process needs B to calculate its assigned output rows.
4. **Scatter:** `MPI_Scatter` distributes row blocks of A from rank 0 to the participating processes.
5. **Local computation:** each process computes the corresponding rows of its local result matrix.
6. **Gather:** `MPI_Gather` collects the local output blocks and assembles the complete result on rank 0.
7. **Finalization:** processes complete their MPI work and leave the MPI environment.

The collective operations are called by the participating processes according to MPI's collective communication rules. Their matching participation is essential to a correct program.

### 3.4 Configuration

| Parameter | Value |
|---|---|
| Matrix dimension | 4000 × 4000 |
| Data type | `double` |
| Input initialization | A and B contain 1.0 |
| Recorded process count | 4 |
| Work distribution | Equal row blocks |
| Main collective operations | `MPI_Bcast`, `MPI_Scatter`, `MPI_Gather` |
| Expected sample result | C[0][0] = 4000.00 |

### 3.5 Source file

- [`src/matrix_mpi.c`](src/matrix_mpi.c) — distributed matrix multiplication using MPI processes and collective communication.

### 3.6 Compile and execute

Install an MPI implementation such as Open MPI. From the repository root:

```bash
mpicc -O2 Experiment_3/src/matrix_mpi.c -o matrix_mpi
mpirun -np 4 ./matrix_mpi
```

The `mpicc` wrapper invokes the underlying C compiler with the appropriate MPI include and link settings. The `-np 4` option requests four MPI processes.

The program's reported computation interval includes the scatter, local calculation and gather phases. The broadcast of B and initial setup take place before the timer starts, as documented by the implementation.

## 4. Part B — Point-to-point send and receive

### 4.1 Objective

The second program demonstrates direct communication between two MPI processes. Rank 0 sends the integer value 10 to rank 1. Rank 1 receives the value and can display or process the received data.

### 4.2 MPI operations

- `MPI_Send` is used by the sending process to transmit a message.
- `MPI_Recv` is used by the receiving process to accept the message.
- The sender and receiver must agree on the communication details, including the communicator, source/destination, message tag and compatible data type/count.

### 4.3 Source file and execution

- [`src/mpi_send_recv.c`](src/mpi_send_recv.c) — point-to-point integer communication.

Compile and run with at least two processes:

```bash
mpicc -O2 Experiment_3/src/mpi_send_recv.c -o mpi_send_recv
mpirun -np 2 ./mpi_send_recv
```

## 5. Requirements

- A C compiler and MPI implementation such as Open MPI.
- MPI compiler wrapper `mpicc`.
- MPI launcher such as `mpirun` or the implementation's equivalent.
- Enough memory for the matrix data held by rank 0 and the local blocks.
- A system or virtual machine that permits the requested MPI process count.

## 6. Execution procedure

1. Install and verify the MPI compiler and launcher.
2. Compile the matrix multiplication source.
3. Launch the program with four processes.
4. Observe the process count and execution-time output.
5. Verify that the gathered output includes the expected value 4000.00.
6. Compile the point-to-point source separately.
7. Run the send/receive program with two processes.
8. Observe the value transmitted from rank 0 to rank 1.
9. Capture genuine terminal output from both programs for the practical record.

## 7. Recorded matrix multiplication result

| Measurement | Recorded value |
|---|---:|
| MPI process count | 4 |
| Execution time | 138.772617 s |
| Sequential reference time | 417.205920 s |
| Reported speedup | 3.01× |
| Verification: C[0][0] | 4000.00 |

The reported ratio is:

```text
Speedup = 417.205920 / 138.772617
        ≈ 3.01
```

The recorded measurement came from a four-process/virtual-machine environment. Results may vary with CPU allocation, process placement, memory bandwidth, MPI implementation and system load.

## 8. Performance interpretation

MPI distributes computation, but it also introduces communication. Each process needs the relevant portion of A and the complete B matrix, and the local output blocks must be returned to rank 0. The total performance therefore depends on both local computation and the cost of data movement.

For this experiment, the reported timer includes scatter, local computation and gather, while the broadcast and initial setup occur before timing. This timing boundary should be kept in mind when comparing the result with other implementations.

## 9. Important concepts demonstrated

- **Rank:** a process identifier within an MPI communicator.
- **Communicator:** the group of processes participating in MPI operations.
- **Collective communication:** operations such as broadcast, scatter and gather that coordinate a group of processes.
- **Point-to-point communication:** direct message transfer between a sender and receiver.
- **Distributed memory:** each process owns local memory and exchanges required data through messages.
- **Work partitioning:** dividing a large computation into smaller process-specific portions.

## 10. Conclusion

The experiment demonstrates how MPI processes cooperate to perform matrix multiplication using distributed row blocks. Collective operations distribute input data and gather the completed output, while the separate send/receive program illustrates direct message passing between two ranks. The sample matrix result matches the expected value, and the recorded four-process execution provides an observation of distributed computation under the stated environment.
