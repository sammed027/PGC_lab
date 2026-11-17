# Experiment 6 — Cache Coherence, False Sharing and NUMA

## 1. Aim

To study cache-coherence protocols, understand how multiple processors maintain consistent cached copies of shared memory, investigate the performance impact of false sharing, and examine memory-access behaviour on a NUMA-aware system.

## 2. Introduction

Modern processors use cache memory to reduce the average time required to access data. When multiple CPU cores access shared memory, each core may hold a cached copy of the same memory region. If one core modifies data that is also cached elsewhere, the system must maintain a consistent view of memory.

Cache-coherence protocols define how cached copies transition between states and how processors coordinate reads and writes. Even when threads update different variables, they may experience interference if those variables occupy the same cache line. This effect is known as false sharing.

NUMA, or Non-Uniform Memory Access, describes systems in which memory-access time can depend on the relationship between a processor and the memory node containing the data. Understanding these effects is important when designing scalable parallel programs.

## 3. Cache-coherence protocols

This experiment includes a simplified simulator for three well-known protocol families.

### 3.1 MSI protocol

MSI uses three cache-line states:
- **Modified (M):** the cache has modified data that is not yet consistent with main memory.
- **Shared (S):** the cache holds a clean copy that may also be present in other caches.
- **Invalid (I):** the cache line is not valid for use.

A write to a shared line may require invalidating other cached copies before the writer obtains exclusive ownership.

### 3.2 MESI protocol

MESI extends MSI with the **Exclusive (E)** state. An exclusive line is clean and held by only one cache. A processor can often transition an exclusive line to modified without first requesting invalidations from other caches.

### 3.3 MOESI protocol

MOESI adds the **Owned (O)** state. An owned line can be dirty and shared, allowing one cache to be responsible for supplying the modified data while other caches hold shared copies. This can reduce the need for immediate write-back in certain sharing situations.

The repository simulator models simplified protocol activity. Its counters should be interpreted as simulator outputs, not as direct measurements from physical CPU cache hardware.

## 4. False sharing

False sharing occurs when separate threads modify different variables that happen to reside on the same cache line. The variables are logically independent, but cache coherence operates at cache-line granularity. A write by one core can cause another core's cached copy of the line to be invalidated, resulting in repeated coherence traffic.

The false-sharing program compares two arrangements:
- **Adjacent layout:** per-thread counters are placed close together and may share a cache line.
- **Padded layout:** spacing/alignment is used to separate counters into different cache-line regions.

The intended result is to observe whether separating the counters reduces the cost associated with cache-line contention. The source uses a 64-byte alignment/padding assumption; actual cache-line characteristics are hardware-dependent.

## 5. NUMA memory locality

In a NUMA architecture, a processor may access memory attached to its local node more efficiently than memory attached to another node. Parallel applications can benefit from placing data close to the processor that uses it.

The experiment includes memory-sweep programs and system inspection commands. The recorded virtual machine exposed only one NUMA node. Therefore, the experiment can examine memory-sweep behaviour but cannot provide a genuine local-versus-remote NUMA comparison in that environment.

## 6. Recorded environment

| Parameter | Recorded configuration |
|---|---|
| Virtualization | VMware |
| Operating system | Ubuntu |
| CPU | 13th Gen Intel Core i5-13400 |
| Virtual CPUs | 4 |
| GCC | 15.2.0 |
| Python | 3.14.4 |
| NUMA nodes visible to VM | 1 (node 0) |

## 7. Source files

| File | Description |
|---|---|
| [`src/coherence_sim.py`](src/coherence_sim.py) | Simulates simplified MSI, MESI and MOESI protocol traces |
| [`src/false_sharing.c`](src/false_sharing.c) | Compares adjacent and padded per-thread counter layouts |
| [`src/numa_sweep.c`](src/numa_sweep.c) | Measures repeated memory sweeps over a configurable buffer |
| [`src/compare_numa.c`](src/compare_numa.c) | Combines counter-layout and memory-sweep measurements |

## 8. Setup and compilation

Install the required tools:

```bash
sudo apt update
sudo apt install build-essential numactl hwloc python3 -y
```

Compile the C programs from the repository root:

```bash
gcc -O2 -fopenmp Experiment_6/src/false_sharing.c -o false_sharing
gcc -O2 -fopenmp Experiment_6/src/numa_sweep.c -o numa_sweep
gcc -O2 -fopenmp Experiment_6/src/compare_numa.c -o compare_numa
```

## 9. Execution procedure

Run the coherence simulator with 1000 iterations:

```bash
python3 Experiment_6/src/coherence_sim.py 1000
```

Compare adjacent and padded counter layouts:

```bash
OMP_NUM_THREADS=2 ./false_sharing adjacent
OMP_NUM_THREADS=2 ./false_sharing padded
```

Run the memory sweep with a 256 MB buffer:

```bash
OMP_NUM_THREADS=2 ./numa_sweep 256
```

Run the combined comparison and inspect the visible NUMA topology:

```bash
./compare_numa
numactl --hardware
```

The simulator argument controls the number of iterations. The false-sharing program accepts the layout name `adjacent` or `padded`, while the memory-sweep program accepts the buffer size in megabytes.

## 10. Recorded results — coherence simulation

The following values are the recorded output from the repository's simplified simulator using 1,000 iterations.

| Layout | Protocol | Bus transactions | Invalidations | Write-backs | Cache-to-cache |
|---|---|---:|---:|---:|---:|
| Adjacent | MSI | 4000 | 1999 | 1999 | 0 |
| Adjacent | MESI | 3999 | 1999 | 1999 | 0 |
| Adjacent | MOESI | 3999 | 1999 | 0 | 1999 |
| Padded | MSI | 4 | 0 | 0 | 0 |
| Padded | MESI | 2 | 0 | 0 | 0 |
| Padded | MOESI | 2 | 0 | 0 | 0 |

These counters illustrate the simulated effect of the selected access patterns and protocol rules. They are not physical hardware-counter measurements and should not be interpreted as a direct count of transactions on the recorded Intel processor.

## 11. Recorded results — false-sharing benchmark

Both layouts produced 100,000,000 increments in the recorded tests.

| Threads | Adjacent layout | Padded layout |
|---:|---:|---:|
| 2 | 0.0217 s | 0.0155 s |
| 4 | 0.0063 s | 0.0056 s |

The captured runs show lower elapsed times for the padded layout. This is consistent with the idea that separating thread-owned counters can reduce false-sharing effects. However, timing depends on processor cache design, thread placement, virtualization, compiler settings and system load. Repeated trials are recommended before drawing a general performance conclusion.

## 12. Recorded results — NUMA memory sweep

| Buffer and thread configuration | Recorded time |
|---|---:|
| 256 MB, 1 thread | 0.0732 s |
| 256 MB, 2 threads | 0.0745 s |
| 256 MB, 4 threads | 0.0696 s |
| Additional run: 256 MB, 2 threads | 0.0490 s |
| Additional run: 512 MB, 2 threads | 0.1021 s |

The VM exposed one NUMA node (node 0). As a result, no remote NUMA node was available for a controlled local-versus-remote memory comparison. The timing values should be treated as observations of the recorded memory-sweep workload, not as a general NUMA latency result.

## 13. Analysis and discussion

The coherence simulation demonstrates that the protocol's state model influences the type and number of simulated transactions. The false-sharing benchmark demonstrates that logically independent counters can still interact through the cache line that contains them. Padding changes the memory layout and can reduce this form of interference.

The NUMA portion highlights the importance of the test environment. A virtual machine that exposes a single NUMA node cannot demonstrate the difference between local and remote NUMA access. Reporting this limitation is necessary for an accurate interpretation of the experiment.

## 14. Key observations

- Cache coherence maintains a consistent view of shared cached data.
- MSI, MESI and MOESI differ in the states available to represent cache-line ownership and sharing.
- False sharing can occur even when threads update different variables.
- Padding can reduce false sharing when it separates frequently written variables into different cache lines.
- NUMA performance depends on the memory topology visible to the application.
- Simulated protocol counters and hardware performance counters are different kinds of evidence.

## 15. Conclusion

The experiment combines protocol simulation, a false-sharing benchmark and memory-sweep measurements to explore the relationship between parallel execution and the memory hierarchy. The recorded padded-counter runs were faster than the adjacent layout runs, while the simulator illustrates differences among MSI, MESI and MOESI. Because the virtual machine exposed only one NUMA node, a remote-memory comparison was not possible. These results show why cache layout, memory topology and experimental limitations must all be considered when analysing parallel performance.
