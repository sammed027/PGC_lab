# Experiment 4 – Cache Coherence and NUMA

## Aim

To study cache-coherence protocols, observe false sharing between threads, and examine NUMA memory topology and memory-access performance.

## Concepts

- MSI, MESI and MOESI cache-coherence protocols
- Cache-line states and invalidation
- False sharing
- Cache-line padding
- NUMA topology and memory placement
- OpenMP parallel memory access

## Environment

| Component | Observed configuration |
|---|---|
| Virtualization | VMware |
| Operating system | Ubuntu |
| CPU architecture | x86_64 |
| CPU model | 13th Gen Intel Core i5-13400 |
| Virtual CPUs | 4 |
| GCC | 15.2.0 |
| Python | 3.14.4 |
| numactl | 2.0.19 |
| NUMA nodes | 1 (node 0) |

## Source files

| File | Purpose |
|---|---|
| `src/coherence_sim.py` | Simulates MSI, MESI and MOESI cache-coherence behavior |
| `src/false_sharing.c` | Compares adjacent and padded counters |
| `src/numa_sweep.c` | Measures memory-sweep performance |
| `src/compare_numa.c` | Runs the combined performance comparison |

## Setup

```bash
sudo apt update
sudo apt install build-essential numactl hwloc python3 -y
```

Check the environment:

```bash
gcc --version
python3 --version
numactl --version
lscpu
numactl --hardware
```

## Compile

Run from the repository root:

```bash
gcc -O2 -fopenmp Experiment_4/src/false_sharing.c -o false_sharing
gcc -O2 -fopenmp Experiment_4/src/numa_sweep.c -o numa_sweep
gcc -O2 -fopenmp Experiment_4/src/compare_numa.c -o compare_numa
```

## Execute

### Cache-coherence simulation

```bash
python3 Experiment_4/src/coherence_sim.py 1000
```

### False-sharing comparison

```bash
OMP_NUM_THREADS=2 ./false_sharing adjacent
OMP_NUM_THREADS=2 ./false_sharing padded
```

### NUMA memory sweep

```bash
OMP_NUM_THREADS=2 ./numa_sweep 256
```

### Combined benchmark

```bash
./compare_numa
```

## Results

### Cache-coherence simulation

The simulator was executed for 1,000 iterations.

| Layout | Protocol | Bus transactions | BusRd | BusUpgr | Invalidations | Write-backs | Cache-to-cache |
|---|---|---:|---:|---:|---:|---:|---:|
| Adjacent | MSI | 4000 | 2000 | 2000 | 1999 | 1999 | 0 |
| Adjacent | MESI | 3999 | 2000 | 1999 | 1999 | 1999 | 0 |
| Adjacent | MOESI | 3999 | 2000 | 1999 | 1999 | 0 | 1999 |
| Padded | MSI | 4 | 2 | 2 | 0 | 0 | 0 |
| Padded | MESI | 2 | 2 | 0 | 0 | 0 | 0 |
| Padded | MOESI | 2 | 2 | 0 | 0 | 0 | 0 |

### False-sharing benchmark

Both layouts produced the expected total of 100,000,000 increments.

| Layout | Threads | Time (s) |
|---|---:|---:|
| Adjacent | 2 | 0.0217 |
| Padded | 2 | 0.0155 |
| Adjacent | 1 | 0.0245 |
| Padded | 1 | 0.0222 |
| Adjacent | 2 | 0.0136 |
| Padded | 2 | 0.0113 |
| Adjacent | 4 | 0.0063 |
| Padded | 4 | 0.0056 |

### NUMA memory sweep

The combined comparison run used a 256 MB memory sweep.

| Threads | Time (s) |
|---:|---:|
| 1 | 0.0732 |
| 2 | 0.0745 |
| 4 | 0.0696 |

Additional captured runs:
- 256 MB, 2 threads: 0.0490 s
- 512 MB, 2 threads: 0.1021 s

These are separate runs and use different workload sizes or execution conditions.

### NUMA topology

The system reported one NUMA node:

- Node count: 1
- Node 0 CPUs: 0, 1, 2, 3
- Node 0 memory: approximately 3350 MB

A local-versus-remote NUMA comparison could not be performed on this one-node configuration.

## Observations

1. MSI, MESI and MOESI maintain cache consistency using different state transitions and bus transactions.
2. Adjacent counters generated more coherence traffic than padded counters.
3. Padding reduced false-sharing overhead in the recorded benchmark runs.
4. The VM exposed four virtual CPUs but only one NUMA node.
5. The recorded memory-sweep timings varied across runs and workload sizes.

## Conclusion

The experiment demonstrated cache-coherence behavior and the performance impact of false sharing. Separating frequently updated counters onto different cache lines reduced measured execution time. The system exposed a single NUMA node, so remote NUMA memory latency was not measured.
