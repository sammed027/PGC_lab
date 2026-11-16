# Experiment 5 – Synchronization Mechanisms in Parallel Programs

## Aim
Study synchronization techniques and understand how they prevent race conditions when multiple threads access shared data.

## Concepts
- Race conditions and lost updates
- OpenMP critical sections and atomic operations
- Thread barriers
- POSIX semaphores
- Synchronization performance comparison

## Environment
- Host: MacBook
- VM: VMware Fusion, Ubuntu 24.04.5 LTS
- Compiler: GCC
- Benchmark iterations: 10,000,000
- Thread counts: 1, 2, 4 and 8

## Source files
| File | Purpose |
|---|---|
| `src/race.c` | Unprotected shared counter |
| `src/critical.c` | OpenMP critical section |
| `src/atomic.c` | OpenMP atomic update |
| `src/barrier.c` | Thread barrier |
| `src/semaphore.c` | POSIX semaphore |
| `src/compare_sync.c` | Synchronization benchmark |

## Setup
```bash
sudo apt update
sudo apt install build-essential
```

## Compile and run
```bash
gcc -O2 -fopenmp Experiment_5/src/race.c -o race && ./race
gcc -O2 -fopenmp Experiment_5/src/critical.c -o critical && ./critical
gcc -O2 -fopenmp Experiment_5/src/atomic.c -o atomic && ./atomic
gcc -O2 -fopenmp Experiment_5/src/barrier.c -o barrier && ./barrier
gcc -O2 -pthread Experiment_5/src/semaphore.c -o semaphore && ./semaphore
gcc -O2 -fopenmp Experiment_5/src/compare_sync.c -o compare_sync && ./compare_sync
```

## Recorded observations
- Race demonstration: final counter 1,000,000 in the captured run.
- Critical section: final counter 1,000,000.
- Atomic operation: final counter 1,000,000.
- POSIX semaphore: final counter 200,000.
- In the comparison runs, unsynchronized multi-threaded updates lost increments, while critical, atomic and lock implementations reached the expected count of 10,000,000.
- Atomic updates were faster than critical-section and lock approaches in the recorded benchmark runs.

Execution times and unsynchronized counts varied between runs due to scheduling and system load.

## Conclusion
The experiment demonstrates lost updates from unsynchronized concurrent access and shows how critical sections, atomic operations, locks and semaphores protect shared resources, with additional synchronization overhead.
