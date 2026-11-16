# Experiment 3 – Synchronization Mechanisms in Parallel Programs

## Aim

To study synchronization techniques in parallel programs and understand how they prevent race conditions when multiple threads access shared data.

## Concepts

- Race conditions and lost updates
- OpenMP critical sections
- OpenMP atomic operations
- Thread barriers
- POSIX semaphores
- Performance comparison of synchronization methods

## Environment

| Component | Configuration |
|---|---|
| Host system | MacBook |
| Virtual machine | VMware Fusion |
| Operating system | Ubuntu 24.04.5 LTS |
| Compiler | GCC |
| Parallel API | OpenMP |
| Threading API | POSIX threads |
| Benchmark iterations | 10,000,000 |
| Thread counts | 1, 2, 4 and 8 |

## Source files

| File | Purpose |
|---|---|
| `src/race.c` | Demonstrates an unprotected shared counter |
| `src/critical.c` | Protects the shared counter with an OpenMP critical section |
| `src/atomic.c` | Uses an OpenMP atomic update |
| `src/barrier.c` | Demonstrates synchronization using a barrier |
| `src/semaphore.c` | Uses a POSIX semaphore to protect shared data |
| `src/compare_sync.c` | Compares no synchronization, critical, atomic and lock approaches |

## Setup

Install the compiler and build tools:

```bash
sudo apt update
sudo apt install build-essential
```

Run the commands from the repository root.

## Compile and execute

```bash
gcc -O2 -fopenmp Experiment_3/src/race.c -o race
./race

gcc -O2 -fopenmp Experiment_3/src/critical.c -o critical
./critical

gcc -O2 -fopenmp Experiment_3/src/atomic.c -o atomic
./atomic

gcc -O2 -fopenmp Experiment_3/src/barrier.c -o barrier
./barrier

gcc -O2 -pthread Experiment_3/src/semaphore.c -o semaphore
./semaphore

gcc -O2 -fopenmp Experiment_3/src/compare_sync.c -o compare_sync
./compare_sync
```

## Recorded outputs

| Program | Observed output |
|---|---:|
| Race condition demonstration | Counter = 1,000,000 |
| Critical section | Counter = 1,000,000 |
| Atomic operation | Counter = 1,000,000 |
| POSIX semaphore | Counter = 200,000 |

The barrier program displays thread messages before and after the synchronization point.

## Benchmark results

The comparison program was run for 10,000,000 increments.

### Run 1

| Threads | Method | Final count | Time (s) |
|---:|---|---:|---:|
| 1 | No synchronization | 10,000,000 | 0.0072 |
| 1 | Critical | 10,000,000 | 0.1166 |
| 1 | Atomic | 10,000,000 | 0.0669 |
| 1 | Lock | 10,000,000 | 0.1118 |
| 2 | No synchronization | 8,139,535 | 0.0089 |
| 2 | Critical | 10,000,000 | 0.3220 |
| 2 | Atomic | 10,000,000 | 0.1587 |
| 2 | Lock | 10,000,000 | 0.3377 |
| 4 | No synchronization | 3,659,538 | 0.0072 |
| 4 | Critical | 10,000,000 | 0.2936 |
| 4 | Atomic | 10,000,000 | 0.1558 |
| 4 | Lock | 10,000,000 | 0.3897 |
| 8 | No synchronization | 1,259,436 | 0.0079 |
| 8 | Critical | 10,000,000 | 0.3087 |
| 8 | Atomic | 10,000,000 | 0.1532 |
| 8 | Lock | 10,000,000 | 0.3538 |

### Run 2

| Threads | Unsynchronized final count | Critical (s) | Atomic (s) | Lock (s) |
|---:|---:|---:|---:|---:|
| 1 | 10,000,000 | 0.1228 | 0.0681 | 0.1123 |
| 2 | 5,691,127 | 0.3140 | 0.1571 | 0.3002 |
| 4 | 4,053,084 | 0.2246 | 0.1424 | 0.3517 |
| 8 | 5,572,670 | 0.2489 | 0.1550 | 0.3622 |

In Run 2, Critical, Atomic and Lock each produced the expected final count of 10,000,000 at every tested thread count.

## Observations

1. The unsynchronized counter produced the expected result with one thread but lost updates when multiple threads ran concurrently.
2. Critical sections, atomic updates and locks maintained the expected final count in the benchmark.
3. Atomic updates were faster than the critical-section and lock methods in the recorded runs.
4. Execution time and unsynchronized counts varied between runs because of thread scheduling and system load.
5. Synchronization improves correctness but introduces execution overhead.

## Conclusion

The experiment demonstrated that concurrent access to shared data can cause race conditions and lost updates. Critical sections, atomic operations, locks and semaphores provide synchronization mechanisms to protect shared resources. The benchmark also showed the performance cost associated with synchronization.
