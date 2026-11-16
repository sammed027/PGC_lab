# Experiment 3 – Synchronization Mechanisms in Parallel Programs

> **Source note:** The C files in this folder are reconstructed implementations based on the supplied lab manual and execution screenshots. They are not recovered copies of the original files used during the recorded run. Re-running reconstructed code may produce different timings and race-condition counts.

## Objective

Study synchronization mechanisms used in parallel programs and compare their correctness and execution time.

## Environment used

| Item | Recorded environment |
|---|---|
| Host | MacBook |
| Virtualization | VMware Fusion |
| Guest OS | Ubuntu 24.04.5 LTS |
| Compiler | GCC (installed through `build-essential`) |
| Parallel programming | OpenMP |
| Threading API | POSIX threads |
| Benchmark iterations | 10,000,000 |
| Benchmark thread counts | 1, 2, 4 and 8 |

The Ubuntu release is read from the submitted terminal screenshot. The screenshot shows installation of `build-essential` and compilation with GCC.

## Programs

| File | Concept | Build command | Run |
|---|---|---|---|
| `src/race.c` | Unprotected shared counter / race condition | `gcc src/race.c -fopenmp -o race` | `./race` |
| `src/critical.c` | OpenMP critical section | `gcc src/critical.c -fopenmp -o critical` | `./critical` |
| `src/atomic.c` | OpenMP atomic update | `gcc src/atomic.c -fopenmp -o atomic` | `./atomic` |
| `src/barrier.c` | OpenMP barrier | `gcc src/barrier.c -fopenmp -o barrier` | `./barrier` |
| `src/semaphore.c` | POSIX semaphore with threads | `gcc src/semaphore.c -pthread -o semaphore` | `./semaphore` |
| `src/compare_sync.c` | None, critical, atomic and lock comparison | `gcc src/compare_sync.c -fopenmp -o compare_sync` | `./compare_sync` |

## Setup and execution

Install the compiler and build tools:

```bash
sudo apt update
sudo apt install build-essential
```

Create a working directory and enter it:

```bash
mkdir -p synchronisation
cd synchronisation
```

Copy the source files into this directory (or work from this repository's `Experiment_3` directory), then compile and run each program using the commands in the table above.

To run the benchmark:

```bash
gcc src/compare_sync.c -fopenmp -o compare_sync
./compare_sync
```

## Recorded benchmark evidence

The following values were transcribed from the user's terminal screenshots. The screenshots show two benchmark executions; both are retained because timing and unsynchronized counts can vary between runs.

### Run 1

| Threads | Mechanism | Final count | Correctness | Time (s) |
|---:|---|---:|---|---:|
| 1 | None | 10,000,000 | Correct | 0.0072 |
| 1 | Critical | 10,000,000 | Correct | 0.1166 |
| 1 | Atomic | 10,000,000 | Correct | 0.0669 |
| 1 | Lock | 10,000,000 | Correct | 0.1118 |
| 2 | None | 8,139,535 | Incorrect | 0.0089 |
| 2 | Critical | 10,000,000 | Correct | 0.3220 |
| 2 | Atomic | 10,000,000 | Correct | 0.1587 |
| 2 | Lock | 10,000,000 | Correct | 0.3377 |
| 4 | None | 3,659,538 | Incorrect | 0.0072 |
| 4 | Critical | 10,000,000 | Correct | 0.2936 |
| 4 | Atomic | 10,000,000 | Correct | 0.1558 |
| 4 | Lock | 10,000,000 | Correct | 0.3897 |
| 8 | None | 1,259,436 | Incorrect | 0.0079 |
| 8 | Critical | 10,000,000 | Correct | 0.3087 |
| 8 | Atomic | 10,000,000 | Correct | 0.1532 |
| 8 | Lock | 10,000,000 | Correct | 0.3538 |

### Run 2

| Threads | Mechanism | Final count (None) | None correctness | Critical time (s) | Atomic time (s) | Lock time (s) |
|---:|---:|---:|---|---:|---:|---:|
| 1 |  | 10,000,000 | Correct | 0.1228 | 0.0681 | 0.1123 |
| 2 |  | 5,691,127 | Incorrect | 0.3140 | 0.1571 | 0.3002 |
| 4 |  | 4,053,084 | Incorrect | 0.2246 | 0.1424 | 0.3517 |
| 8 |  | 5,572,670 | Incorrect | 0.2489 | 0.1550 | 0.3622 |

For Run 2, the screenshot also shows that Critical, Atomic and Lock each returned the expected final count of 10,000,000 at every tested thread count.

## Individual program outputs visible in the screenshots

- Race condition program: `Counter = 1000000`.
- Critical section program: `Counter = 1000000`.
- Atomic program: `Counter = 1000000`.
- Barrier program: both thread IDs print a message before and after the barrier.
- Semaphore program: `Counter = 200000`.

The terminal also shows an attempted shell command `sem_init(&semaphore, 0, 1);` entered directly at the Bash prompt, which produced a Bash syntax error. The semaphore program itself was subsequently compiled and executed and printed the counter result.

## Observations

1. With one thread, the unsynchronized increment produced the expected count in the recorded benchmark.
2. With multiple threads, the unprotected shared counter produced smaller, incorrect counts. This demonstrates lost updates caused by a data race in the recorded executions.
3. Critical sections, atomic updates and locks produced the expected final count in the benchmark screenshots.
4. The recorded atomic timings were lower than the critical-section and lock timings in these runs. This is an observation about this VM and these executions, not a universal performance guarantee.
5. Execution times varied between the two runs. Timing results depend on scheduling and the virtualized execution environment.

## Conclusion

The experiment demonstrates why shared data must be protected when accessed concurrently. The unsynchronized counter produced incorrect results with multiple threads, while the critical section, atomic operation and lock maintained the expected count in the recorded benchmark. The barrier demonstrated thread coordination, and the semaphore program demonstrated controlled access to a shared counter.

## Reproducibility note

The screenshots are evidence of the user's original executions. The source files committed alongside this README are reconstructed implementations based on the manual and screenshots. Their exact output and timings must be verified by compiling and running them; they must not be treated as the exact original binaries or source used for the screenshots.
