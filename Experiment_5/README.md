# Experiment 5 — Synchronization Mechanisms in Parallel Programs

## Aim
Demonstrate race conditions and compare mechanisms that coordinate concurrent access to shared data.

## Concepts
- Race conditions and lost updates
- OpenMP critical sections
- OpenMP atomic updates
- Thread barriers
- POSIX semaphores
- Timing and correctness comparison

## Recorded environment
- Host: MacBook
- Virtual machine: VMware Fusion with Ubuntu 24.04.5 LTS
- Compiler: GCC
- Comparison iterations: 10,000,000
- Thread counts in the comparison program: 1, 2, 4 and 8

## Source files

| File | Purpose | Expected behavior |
|---|---|---|
| [`src/race.c`](src/race.c) | Unprotected shared counter | Demonstrates a data race; final value is not guaranteed |
| [`src/critical.c`](src/critical.c) | OpenMP critical region | Serializes the protected increment; expected 1,000,000 |
| [`src/atomic.c`](src/atomic.c) | OpenMP atomic update | Protects the increment operation; expected 1,000,000 |
| [`src/barrier.c`](src/barrier.c) | OpenMP barrier | Makes both threads wait before proceeding |
| [`src/semaphore.c`](src/semaphore.c) | POSIX semaphore with pthreads | Protects two workers' increments; expected 200,000 |
| [`src/compare_sync.c`](src/compare_sync.c) | Compares no protection, critical, atomic and OpenMP lock | Tests 10,000,000 increments at 1, 2, 4 and 8 threads |

## Setup

```bash
sudo apt update
sudo apt install build-essential
```

## Compile and run
Run from the repository root:

```bash
gcc -O2 -fopenmp Experiment_5/src/race.c -o race && ./race
gcc -O2 -fopenmp Experiment_5/src/critical.c -o critical && ./critical
gcc -O2 -fopenmp Experiment_5/src/atomic.c -o atomic && ./atomic
gcc -O2 -fopenmp Experiment_5/src/barrier.c -o barrier && ./barrier
gcc -O2 -pthread Experiment_5/src/semaphore.c -o semaphore && ./semaphore
gcc -O2 -fopenmp Experiment_5/src/compare_sync.c -o compare_sync && ./compare_sync
```

## Recorded observations
- The captured run of the race demonstration printed 1,000,000, but that value is not guaranteed because the update is intentionally unprotected.
- The critical-section and atomic examples reached the expected count of 1,000,000 in the recorded runs.
- The semaphore program uses two threads with 100,000 increments each and reached 200,000.
- In the comparison benchmark, unsynchronized multi-threaded updates lost increments in the recorded runs, while critical, atomic and lock-based updates reached 10,000,000.
- Atomic updates were faster than critical-section and lock approaches in the recorded benchmark runs.

Timings and the incorrect count from a data-race run can change between executions. Do not interpret a single race output as a stable result.

## Key interpretation
- A **critical section** protects a block of statements.
- An **atomic operation** protects a supported individual memory update.
- A **semaphore** controls access using a counter and wait/post operations.
- A **barrier** synchronizes phases; it does not, by itself, protect a shared counter increment.
- Correctness and elapsed time should both be checked when comparing synchronization techniques.

## Conclusion
The experiment shows why shared updates require synchronization. Critical sections, atomic operations, locks and semaphores can preserve correctness, but they introduce different costs. A barrier serves a different purpose by coordinating when threads move to the next phase.
