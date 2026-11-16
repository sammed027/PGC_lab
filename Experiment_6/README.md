# Experiment 6 – Cache Coherence and NUMA

## Aim
Study cache-coherence protocols, observe false sharing, and examine NUMA topology and memory-access performance.

## Concepts
- MSI, MESI and MOESI protocols
- Cache-line states and invalidation
- False sharing and cache-line padding
- NUMA topology and memory placement

## Environment
- Virtualization: VMware
- OS: Ubuntu
- CPU: 13th Gen Intel Core i5-13400
- Virtual CPUs: 4
- GCC: 15.2.0
- Python: 3.14.4
- NUMA nodes: 1 (node 0)

## Source files
| File | Purpose |
|---|---|
| `src/coherence_sim.py` | Simulates MSI, MESI and MOESI |
| `src/false_sharing.c` | Compares adjacent and padded counters |
| `src/numa_sweep.c` | Measures memory-sweep performance |
| `src/compare_numa.c` | Combined performance comparison |

## Setup and compile
```bash
sudo apt update
sudo apt install build-essential numactl hwloc python3 -y
gcc -O2 -fopenmp Experiment_6/src/false_sharing.c -o false_sharing
gcc -O2 -fopenmp Experiment_6/src/numa_sweep.c -o numa_sweep
gcc -O2 -fopenmp Experiment_6/src/compare_numa.c -o compare_numa
```

## Execute
```bash
python3 Experiment_6/src/coherence_sim.py 1000
OMP_NUM_THREADS=2 ./false_sharing adjacent
OMP_NUM_THREADS=2 ./false_sharing padded
OMP_NUM_THREADS=2 ./numa_sweep 256
./compare_numa
```

## Recorded results

### Cache-coherence simulation (1,000 iterations)

| Layout | Protocol | Bus transactions | Invalidations | Write-backs | Cache-to-cache |
|---|---|---:|---:|---:|---:|
| Adjacent | MSI | 4000 | 1999 | 1999 | 0 |
| Adjacent | MESI | 3999 | 1999 | 1999 | 0 |
| Adjacent | MOESI | 3999 | 1999 | 0 | 1999 |
| Padded | MSI | 4 | 0 | 0 | 0 |
| Padded | MESI | 2 | 0 | 0 | 0 |
| Padded | MOESI | 2 | 0 | 0 | 0 |

### False-sharing benchmark

Both layouts produced 100,000,000 increments. Recorded examples:
- 2 threads: adjacent 0.0217 s; padded 0.0155 s
- 4 threads: adjacent 0.0063 s; padded 0.0056 s

### NUMA memory sweep
- 256 MB, 1 thread: 0.0732 s
- 256 MB, 2 threads: 0.0745 s
- 256 MB, 4 threads: 0.0696 s
- Additional runs: 256 MB / 2 threads 0.0490 s; 512 MB / 2 threads 0.1021 s

The system exposed only one NUMA node (node 0, CPUs 0–3). A local-versus-remote NUMA comparison could not be performed on this configuration.

## Conclusion
The simulation and benchmarks demonstrate coherence traffic and false-sharing overhead. Padding reduced measured runtime in the captured runs. Remote NUMA latency was not measured because the VM exposed one NUMA node.
