# Experiment 6 — Cache Coherence, False Sharing and NUMA

## Aim
Explore cache-coherence state transitions, measure the effect of false sharing, and inspect memory-access behavior on a NUMA-aware system.

## Concepts
- MSI, MESI and MOESI cache-coherence protocols
- Read, write, upgrade and invalidation transactions
- False sharing and cache-line padding
- NUMA topology and memory locality

## Recorded environment
- Virtualization: VMware
- Operating system: Ubuntu
- CPU: 13th Gen Intel Core i5-13400
- Virtual CPUs: 4
- GCC: 15.2.0
- Python: 3.14.4
- NUMA nodes exposed to the VM: 1 (node 0)

## Source files

| File | Purpose |
|---|---|
| [`src/coherence_sim.py`](src/coherence_sim.py) | Small two-core MSI/MESI/MOESI trace simulator |
| [`src/false_sharing.c`](src/false_sharing.c) | Compares per-thread counters in adjacent and padded cache-line positions |
| [`src/numa_sweep.c`](src/numa_sweep.c) | Measures repeated memory sweeps over a configurable buffer |
| [`src/compare_numa.c`](src/compare_numa.c) | Combines counter-layout and memory-sweep measurements |

## Setup and compilation

```bash
sudo apt update
sudo apt install build-essential numactl hwloc python3 -y

gcc -O2 -fopenmp Experiment_6/src/false_sharing.c -o false_sharing
gcc -O2 -fopenmp Experiment_6/src/numa_sweep.c -o numa_sweep
gcc -O2 -fopenmp Experiment_6/src/compare_numa.c -o compare_numa
```

## Run the experiments
Run from the repository root:

```bash
python3 Experiment_6/src/coherence_sim.py 1000
OMP_NUM_THREADS=2 ./false_sharing adjacent
OMP_NUM_THREADS=2 ./false_sharing padded
OMP_NUM_THREADS=2 ./numa_sweep 256
./compare_numa
numactl --hardware
```

The simulator argument specifies the number of iterations. The false-sharing program accepts `adjacent` or `padded`; the memory-sweep program accepts a buffer size in MB.

## Recorded results

### Cache-coherence simulation — 1,000 iterations

| Layout | Protocol | Bus transactions | Invalidations | Write-backs | Cache-to-cache |
|---|---|---:|---:|---:|---:|
| Adjacent | MSI | 4000 | 1999 | 1999 | 0 |
| Adjacent | MESI | 3999 | 1999 | 1999 | 0 |
| Adjacent | MOESI | 3999 | 1999 | 0 | 1999 |
| Padded | MSI | 4 | 0 | 0 | 0 |
| Padded | MESI | 2 | 0 | 0 | 0 |
| Padded | MOESI | 2 | 0 | 0 | 0 |

These are counts produced by the repository's simplified simulator, not hardware performance-counter measurements.

### False-sharing benchmark

Both layouts produced 100,000,000 increments in the recorded tests.

| Threads | Adjacent layout | Padded layout |
|---:|---:|---:|
| 2 | 0.0217 s | 0.0155 s |
| 4 | 0.0063 s | 0.0056 s |

The captured runs show lower times for the padded layout. The result depends on the machine, thread placement and cache organization. The source uses a 64-byte alignment/padding assumption.

### NUMA memory sweep

| Buffer and threads | Recorded time |
|---|---:|
| 256 MB, 1 thread | 0.0732 s |
| 256 MB, 2 threads | 0.0745 s |
| 256 MB, 4 threads | 0.0696 s |
| Additional run: 256 MB, 2 threads | 0.0490 s |
| Additional run: 512 MB, 2 threads | 0.1021 s |

The VM exposed only one NUMA node. A local-versus-remote NUMA latency comparison was therefore not possible in this environment.

## What to observe
1. Adjacent thread-owned counters can still contend when they occupy the same cache line.
2. Padding separates the counters onto different cache-line regions and can reduce false sharing.
3. Coherence protocol state transitions determine how readers and writers obtain ownership of a cache line.
4. A single-node NUMA topology does not provide a remote node for comparison.

## Conclusion
The simulator illustrates how coherence protocols respond to reads and writes, while the benchmarks demonstrate the potential effect of false sharing. The recorded environment supports only a limited NUMA investigation because it exposes one NUMA node.
