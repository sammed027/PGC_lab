# Experiment 5 — Synchronization Mechanisms in Parallel Programs

## 1. Aim

To demonstrate race conditions in concurrent programs and study how synchronization mechanisms such as OpenMP critical sections, atomic operations, barriers, locks and POSIX semaphores coordinate access to shared resources.

## 2. Introduction

Parallel programs allow multiple threads to execute at the same time. When threads operate on independent data, they can often proceed without interfering with one another. However, when multiple threads access and modify the same shared variable, the order of operations becomes important.

A common example is incrementing a shared counter. An increment is conceptually a read, modification and write operation. If two threads read the same old value before either writes its update, one increment can be lost. This is a race condition.

Synchronization mechanisms coordinate concurrent execution so that shared data is accessed safely. Different mechanisms provide different guarantees and have different performance costs.

## 3. Core concepts

### 3.1 Race condition

A race condition occurs when the correctness of a program depends on the relative timing or ordering of concurrent operations. In the shared-counter example, unprotected increments can overlap and produce a final value smaller than the expected total.

### 3.2 Critical section

An OpenMP critical region allows only one thread at a time to execute the protected region associated with that critical construct. It is suitable when a group of statements must be executed without concurrent interference.

### 3.3 Atomic operation

An OpenMP atomic construct protects a supported memory operation, such as a shared counter update. It is generally more narrowly scoped than a critical region and can be efficient for simple updates.

### 3.4 Barrier

A barrier is a synchronization point. Threads that reach it wait until all participating threads have reached the same barrier. It coordinates the transition between phases, but it does not automatically make arbitrary shared-variable updates safe.

### 3.5 Semaphore

A POSIX semaphore maintains a counter used to control access to a resource or coordinate threads. A thread can wait on a semaphore and another thread can post to it. A semaphore initialized to one can be used as a simple mutual-exclusion mechanism when used correctly.

### 3.6 Lock

A lock provides mutual exclusion around a protected region. A thread must acquire the lock before entering and release it after completing the protected operation.

## 4. Recorded environment and workload

| Parameter | Recorded configuration |
|---|---|
| Host system | MacBook |
| Virtualization | VMware Fusion |
| Guest operating system | Ubuntu 24.04.5 LTS |
| Compiler | GCC |
| Comparison workload | 10,000,000 increments |
| Thread settings | 1, 2, 4 and 8 |
| Main APIs | OpenMP, pthreads and POSIX semaphores |

## 5. Source files and purpose

| Source file | Purpose | Behaviour being studied |
|---|---|---|
| [`src/race.c`](src/race.c) | Unprotected shared counter | Shows that concurrent increments are not guaranteed to be preserved |
| [`src/critical.c`](src/critical.c) | OpenMP critical section | Serializes the protected increment |
| [`src/atomic.c`](src/atomic.c) | OpenMP atomic update | Protects the individual counter update |
| [`src/barrier.c`](src/barrier.c) | OpenMP barrier | Coordinates threads before they continue to the next phase |
| [`src/semaphore.c`](src/semaphore.c) | POSIX semaphore with pthreads | Coordinates two workers updating a shared counter |
| [`src/compare_sync.c`](src/compare_sync.c) | Synchronization comparison | Compares unprotected, critical, atomic and lock-based updates |

## 6. System requirements and setup

The examples require a Linux environment with GCC, OpenMP support and POSIX thread/semaphore facilities.

```bash
sudo apt update
sudo apt install build-essential
```

The semaphore example is compiled with pthread support. OpenMP examples use the `-fopenmp` option.

## 7. Compilation and execution

Run the commands from the repository root:

```bash
gcc -O2 -fopenmp Experiment_5/src/race.c -o race
./race

gcc -O2 -fopenmp Experiment_5/src/critical.c -o critical
./critical

gcc -O2 -fopenmp Experiment_5/src/atomic.c -o atomic
./atomic

gcc -O2 -fopenmp Experiment_5/src/barrier.c -o barrier
./barrier

gcc -O2 -pthread Experiment_5/src/semaphore.c -o semaphore
./semaphore

gcc -O2 -fopenmp Experiment_5/src/compare_sync.c -o compare_sync
./compare_sync
```

## 8. Experimental procedure

1. Compile and execute the unprotected counter program.
2. Observe the final counter value and note that it is not guaranteed to equal the intended count.
3. Compile and execute the critical-section program.
4. Verify that the protected counter reaches the expected value.
5. Run the atomic update program and compare its correctness.
6. Run the barrier program and observe how threads wait at the synchronization point.
7. Execute the semaphore program and verify the combined updates from the two workers.
8. Run the comparison program for the configured thread counts.
9. Record both the final counter values and execution times.
10. Capture genuine output from each relevant program for the practical record.

## 9. Expected values and recorded observations

The critical and atomic examples use a target count of 1,000,000. The semaphore example uses two workers, each performing 100,000 increments, giving an expected total of 200,000. The comparison program evaluates 10,000,000 increments.

Recorded observations:
- The race demonstration printed 1,000,000 in the captured run. This value is not guaranteed because the shared update is intentionally unprotected.
- The critical-section and atomic examples reached 1,000,000 in the recorded runs.
- The semaphore program reached 200,000 after the two workers completed their increments.
- In the comparison benchmark, unprotected multi-threaded updates lost increments in the recorded runs.
- Critical, atomic and lock-based updates reached the target count of 10,000,000 in the recorded comparison.
- Atomic updates were faster than critical-section and lock approaches in the recorded benchmark runs.

No fixed timing values are claimed here because the measured durations depend on the machine and runtime conditions. Re-run the benchmark to obtain timings for the current environment.

## 10. Result analysis

The race demonstration is important because a correct result in one execution does not prove that the program is thread-safe. Thread scheduling can change between runs, and the timing of memory operations can cause different final values.

Critical sections, atomics and locks protect shared updates, but they do so with different scopes and implementation costs. A critical section protects a region of code, while an atomic construct protects a supported individual operation. A lock gives the programmer explicit control over the protected region. A semaphore can coordinate access or ordering using its counter and wait/post operations.

A barrier has a different purpose: it ensures that participating threads have reached a synchronization point before they proceed. It should not be treated as a substitute for mutual exclusion around a shared increment.

## 11. Comparison of synchronization methods

| Mechanism | Main purpose | Typical use in this experiment |
|---|---|---|
| No synchronization | No protection | Demonstrating a race condition |
| Critical section | Mutual exclusion for a code region | Protecting a counter increment |
| Atomic operation | Atomicity of a supported update | Protecting a simple increment |
| Barrier | Phase synchronization | Waiting for all threads before continuing |
| Semaphore | Counter-based coordination | Protecting shared updates among workers |
| Lock | Explicit mutual exclusion | Protecting a shared counter in the comparison |

## 12. Important observations

- Correctness must be checked separately from execution time.
- An unprotected program can occasionally display the expected result even though it contains a race.
- Synchronization introduces coordination overhead, but it is necessary when concurrent operations would otherwise conflict.
- The fastest synchronization method depends on the operation, thread count, hardware and runtime implementation.
- Results should be repeated rather than inferred from one execution.

## 13. Conclusion

The experiment demonstrates why synchronization is essential when multiple threads update shared data. The unprotected counter illustrates the possibility of lost updates, while critical sections, atomic operations, locks and semaphores provide mechanisms for safe coordination. The barrier example demonstrates synchronization between phases rather than mutual exclusion. The comparison highlights the need to evaluate both correctness and performance when selecting a synchronization method.
