# Experiment 2 — Parallel Matrix Multiplication Using OpenMP

## 1. Aim

To parallelize square matrix multiplication on a shared-memory CPU using OpenMP, understand how loop iterations are distributed among threads, validate the computed output and compare the recorded execution time with the sequential baseline from Experiment 1.

## 2. Introduction

OpenMP is an API for shared-memory parallel programming in C, C++ and Fortran. It provides compiler directives and runtime functions that allow a programmer to express parallel regions and distribute work among threads without manually creating and managing every thread.

In a shared-memory system, multiple threads execute within one process and can access the same address space. This makes it possible for threads to read common input matrices while writing separate portions of an output matrix. Matrix multiplication is suitable for this approach because each output row can be calculated independently when the input matrices remain unchanged.

## 3. Problem formulation

The experiment uses the same matrix multiplication operation as Experiment 1:

```text
C[i][j] = Σ A[i][k] × B[k][j], for k = 0 to N-1
```

The workload uses 4000 × 4000 matrices with all input elements initialized to 1.0. Consequently, each output element should equal 4000.00.

## 4. Parallelization strategy

The implementation parallelizes the outer row loop using:

```c
#pragma omp parallel for schedule(static)
```

The OpenMP runtime creates a team of threads and distributes loop iterations among them. With static scheduling, the iterations are assigned in predetermined chunks. Each thread calculates one or more rows of the output matrix.

The input matrices A and B are shared among the threads. Each assigned iteration writes to a different row of C, so the output regions do not overlap. This independent-write arrangement avoids the need for a critical section around the matrix calculation.

## 5. Experimental configuration

| Parameter | Value |
|---|---|
| Matrix dimension | 4000 × 4000 |
| Data type | `double` |
| Input initialization | All elements are 1.0 |
| Parallel programming model | OpenMP shared memory |
| Parallelized loop | Outer matrix-row loop |
| Scheduling policy | Static |
| Recorded thread setting | 12 |
| Expected C[0][0] | 4000.00 |
| Time complexity | O(N³) total arithmetic work |

OpenMP changes how the work is scheduled, not the mathematical operation being performed. A correct parallel result should therefore match the sequential result.

## 6. Source file

- [`src/matrix_openmp.c`](src/matrix_openmp.c) — implements the OpenMP matrix multiplication and uses `omp_get_wtime()` for wall-clock timing.

## 7. Requirements

- GCC with OpenMP support enabled.
- An operating system and runtime environment that support OpenMP.
- Sufficient memory for the three 4000 × 4000 double-precision matrices.
- A CPU with multiple available hardware execution contexts is recommended for observing parallel execution.

## 8. Compilation and execution

Run from the repository root:

```bash
gcc -O2 -fopenmp Experiment_2/src/matrix_openmp.c -o openmp
OMP_NUM_THREADS=12 ./openmp
```

The `-fopenmp` compiler option enables OpenMP directives and links the required runtime support. The environment variable `OMP_NUM_THREADS=12` requests a team of 12 threads. The program also reports the maximum thread setting visible to the OpenMP runtime.

To study the effect of thread count, change the environment variable and repeat the run, for example:

```bash
OMP_NUM_THREADS=2 ./openmp
OMP_NUM_THREADS=4 ./openmp
OMP_NUM_THREADS=8 ./openmp
OMP_NUM_THREADS=12 ./openmp
```

The actual number of threads used can depend on runtime settings, CPU availability and program configuration.

## 9. Execution procedure

1. Ensure GCC and OpenMP support are available.
2. Compile the source using the command above.
3. Set the desired thread count through `OMP_NUM_THREADS`.
4. Execute the generated program.
5. Record the thread setting and elapsed time.
6. Check the reported sample output against 4000.00.
7. If testing multiple thread counts, keep the matrix dimensions and initialization unchanged.
8. Capture the actual compilation and execution output for the practical record.

## 10. Recorded observations

| Measurement | Recorded value |
|---|---:|
| OpenMP execution time | 230.801465 s |
| Sequential reference time | 417.205920 s |
| Reported speedup | 1.81× |
| Recorded thread setting | 12 |
| Verification: C[0][0] | 4000.00 |

The reported speedup is calculated from the two recorded times:

```text
Speedup = 417.205920 / 230.801465
        ≈ 1.81
```

This is a historical result from the recorded environment. Experiment 1 uses C's `clock()`, whereas this OpenMP program uses `omp_get_wtime()`. Since the timing methods are not identical, the ratio is useful as a recorded comparison but is not a perfectly controlled benchmark. For a rigorous performance study, both versions should be measured using the same wall-clock timing method under comparable conditions.

## 11. Correctness and performance discussion

The output value 4000.00 agrees with the expected result for the uniform input. This indicates that the parallel row computation produced the expected sample value.

The measured speedup is below the ideal linear speedup that might be imagined from the thread count. This is normal. The runtime can be influenced by:
- The number of physical CPU cores and hardware threads.
- Whether the process runs inside a virtual machine.
- Memory bandwidth and cache behaviour.
- Thread creation and scheduling overhead.
- Operating-system activity and other workloads.
- Differences between timing methods and measurement regions.

Adding threads does not guarantee that execution time will decrease in direct proportion. Once a workload reaches a hardware or memory-bandwidth limit, additional threads may provide diminishing returns.

## 12. Key concepts demonstrated

**Shared address space:** OpenMP threads can access common arrays within the process.

**Work sharing:** The parallel-for construct distributes loop iterations among the thread team.

**Static scheduling:** Work is assigned in predictable chunks, which is useful when each row has a similar computational cost.

**Data independence:** Each output row is written by one assigned iteration, avoiding conflicting writes.

**Speedup:** The recorded result provides an initial indication of the benefit of shared-memory parallel execution.

## 13. Conclusion

The experiment demonstrates how OpenMP can parallelize a computationally intensive matrix multiplication workload by distributing independent row iterations among CPU threads. The computed sample value matches the sequential mathematical expectation. The recorded execution time is lower than the sequential reference, illustrating the potential benefit of shared-memory parallelism while also showing that actual speedup depends on hardware, memory behaviour, runtime configuration and measurement methodology.
