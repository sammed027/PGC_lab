# Experiment 4 – Cache Coherence (MSI, MESI, MOESI) and NUMA Memory Access Performance

> **Evidence note:** The screenshots in this folder are the user's original Ubuntu/VMware terminal captures. The source files are organized from the supplied experiment handout. The handout describes a 512 MB NUMA sweep, while the submitted terminal captures show 256 MB in the comparison program and a separate 512 MB sweep. The results below preserve the values visible in the screenshots rather than substituting sample values from the handout.

## Objective

Study how MSI, MESI and MOESI cache-coherence protocols maintain consistent data across processor caches, observe false sharing when independent counters occupy the same cache line, and inspect NUMA memory topology and memory-sweep performance.

## Environment and tools

| Component | Observed / used |
|---|---|
| Virtualization | VMware Workstation |
| Guest OS | Ubuntu 64-bit |
| CPU architecture | x86_64 |
| CPU model shown by `lscpu` | 13th Gen Intel Core i5-13400 |
| Virtual CPUs | 4 (CPU IDs 0–3) |
| GCC | 15.2.0 |
| Python | 3.14.4 |
| numactl | 2.0.19 |
| OpenMP | GCC `-fopenmp` runtime |
| NUMA topology shown | 1 node (node 0) |

## Concepts covered

- **MSI:** Modified, Shared and Invalid cache-line states.
- **MESI:** Adds Exclusive, allowing a private clean line to transition to Modified without an upgrade transaction.
- **MOESI:** Adds Owned, allowing a dirty line to be shared while its owner supplies data.
- **False sharing:** Independent variables on one cache line cause invalidations and cache-line ping-pong.
- **Padding:** Separating per-thread counters onto different cache lines reduces false sharing.
- **NUMA:** Local and remote memory placement can affect memory access latency. The submitted VM reports only one NUMA node, so this run does not demonstrate a true remote-node comparison.

## Repository structure

```text
Experiment_4/
├── README.md
├── src/
│   ├── coherence_sim.py
│   ├── false_sharing.c
│   ├── numa_sweep.c
│   └── compare_numa.c
└── screenshots/
    ├── 01-apt-update.png
    ├── 02-package-installation.png
    ├── 03-tool-versions-and-openmp.png
    ├── 04-cpu-topology.png
    ├── 05-numa-topology.png
    ├── 06-cache-protocol-simulation.png
    ├── 07-protocol-traffic-summary.png
    ├── 08-false-sharing-run.png
    ├── 09-numa-sweep-run.png
    ├── 10-comparison-benchmark.png
    ├── 11-local-numa-benchmark.png
    └── 12-source-directory-and-results.png
```

## Setup

Install the required packages:

```bash
sudo apt update
sudo apt install build-essential numactl hwloc python3 -y
```

Verify the tools and OpenMP support:

```bash
gcc --version
python3 --version
numactl --version
echo '#include <omp.h>' | gcc -E -fopenmp -xc - > /dev/null && echo "OpenMP OK"
lscpu
numactl --hardware
```

## Compile the programs

Run these commands from the repository root:

```bash
gcc -O2 -fopenmp Experiment_4/src/false_sharing.c -o false_sharing
gcc -O2 -fopenmp Experiment_4/src/numa_sweep.c -o numa_sweep
gcc -O2 -fopenmp Experiment_4/src/compare_numa.c -o compare_numa
```

## Execute

### 1. MSI / MESI / MOESI simulator

```bash
python3 Experiment_4/src/coherence_sim.py 1000
```

### 2. False sharing: adjacent and padded counters

```bash
OMP_NUM_THREADS=2 ./false_sharing adjacent
OMP_NUM_THREADS=2 ./false_sharing padded
```

### 3. NUMA memory sweep

```bash
OMP_NUM_THREADS=2 ./numa_sweep 256
```

### 4. Combined comparison benchmark

```bash
./compare_numa
```

The experiment handout also gives examples using `numactl --cpunodebind` and `--membind`. Do not run a remote-node command with `--membind=1` on this captured VM: `numactl --hardware` reports only node 0.

## Results transcribed from the submitted screenshots

### Cache-coherence simulator

The simulator was run for 1,000 iterations. The terminal shows the expected state transitions for MSI, MESI and MOESI. The protocol summary visible in the screenshot reports:

| Layout | Protocol | Bus transactions | BusRd | BusUpgr | Invalidations | Write-backs | Cache-to-cache |
|---|---:|---:|---:|---:|---:|---:|---:|
| Adjacent | MSI | 4000 | 2000 | 2000 | 1999 | 1999 | 0 |
| Adjacent | MESI | 3999 | 2000 | 1999 | 1999 | 1999 | 0 |
| Adjacent | MOESI | 3999 | 2000 | 1999 | 1999 | 0 | 1999 |
| Padded | MSI | 4 | 2 | 2 | 0 | 0 | 0 |
| Padded | MESI | 2 | 2 | 0 | 0 | 0 | 0 |
| Padded | MOESI | 2 | 2 | 0 | 0 | 0 | 0 |

### False-sharing benchmark

The terminal screenshots show both layouts returning the expected total of **100,000,000** increments.

One captured run:

| Layout | Threads | Final count | Correctness | Time (s) |
|---|---:|---:|---|---:|
| Adjacent | 2 | 100,000,000 | Correct | 0.0217 |
| Padded | 2 | 100,000,000 | Correct | 0.0155 |

A combined benchmark capture shows:

| Layout | Threads | Final count | Correctness | Time (s) |
|---|---:|---:|---|---:|
| Adjacent | 1 | 100,000,000 | Correct | 0.0245 |
| Padded | 1 | 100,000,000 | Correct | 0.0222 |
| Adjacent | 2 | 100,000,000 | Correct | 0.0136 |
| Padded | 2 | 100,000,000 | Correct | 0.0113 |
| Adjacent | 4 | 100,000,000 | Correct | 0.0063 |
| Padded | 4 | 100,000,000 | Correct | 0.0056 |

### NUMA memory sweep

The screenshots show a 256 MB sweep (four passes) in the combined comparison output:

| Threads | Time (s) |
|---:|---:|
| 1 | 0.0732 |
| 2 | 0.0745 |
| 4 | 0.0696 |

A separate 256 MB run shows two threads with a time of 0.0490 s. Another standalone 512 MB sweep is visible at 0.1021 s for two threads. These are separate runs and should not be directly compared as identical workloads.

### NUMA topology observation

The captured `numactl --hardware` output reports:

- Available NUMA nodes: **1 (node 0)**
- Node 0 CPUs: **0, 1, 2, 3**
- Node 0 memory: approximately **3350 MB**

Therefore, this VM can be used to inspect NUMA topology and run memory sweeps, but it cannot establish a real local-versus-remote NUMA latency difference with the captured one-node configuration.

## Observations

1. All three coherence protocols maintain valid cache states, but their bus-transaction and memory-traffic behavior differs.
2. Adjacent counters cause substantial coherence traffic because both counters share a cache line.
3. Padding separates the counters and reduces false-sharing overhead.
4. The captured padded-counter timings are lower than adjacent-counter timings in the shown runs.
5. The VM exposes four virtual CPUs but only one NUMA node; remote-memory performance was not demonstrated.
6. Benchmark times vary between runs and depend on the VM, CPU scheduling and system load.

## Conclusion

The experiment demonstrates the role of cache-coherence protocols in maintaining consistent data across cores and shows how false sharing can reduce parallel performance even when threads update different variables. Separating counters onto distinct cache lines improves the measured execution time in the submitted runs. The NUMA inspection confirms a single-node virtual topology, so a genuine remote-memory comparison requires a system or VM configuration exposing at least two NUMA nodes.

## Screenshot evidence

The 12 original terminal screenshots were supplied in this conversation and reviewed while preparing this documentation. They are **not yet committed as image files** in this repository. The connected GitHub file-writing capability used for this update supports text files but does not expose a binary image-upload operation. To avoid broken image links, no image paths are presented as if the screenshots were already uploaded.

To add them from a local clone, copy the screenshots into `Experiment_4/screenshots/` using descriptive names, then commit and push:

```bash
mkdir -p Experiment_4/screenshots
# Copy the 12 supplied screenshot images into this folder.
git add Experiment_4/screenshots
git commit -m "Add Experiment 4 terminal screenshots"
git push origin main
```

