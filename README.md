# Parallel & GPU Computing Laboratory

[![Course](https://img.shields.io/badge/Course-Parallel%20%26%20GPU%20Computing-2457A7)](https://github.com/sammed027/PGC_lab)
[![Experiments](https://img.shields.io/badge/Experiments-7-6D4CBB)](./)
[![Languages](https://img.shields.io/badge/Code-C%20%7C%20CUDA%20%7C%20Python-16865C)](./)
[![Status](https://img.shields.io/badge/Repository-Lab%20Work-informational)](./)

A practical record of parallel and GPU computing experiments. This repository brings together implementations, execution instructions, observations and performance notes for sequential processing, shared-memory parallelism, distributed computing, CUDA, synchronization, cache coherence and neural-network workloads.

> **Purpose:** keep each experiment independently understandable and reproducible. Open the relevant experiment folder for its detailed procedure and source files.

---

## Experiment index

| No. | Experiment | Concepts explored | Documentation |
|:--:|---|---|---|
| 01 | Sequential Matrix Multiplication | CPU baseline, matrix operations, execution timing | [Open experiment](Experiment_1/README.md) |
| 02 | OpenMP Matrix Multiplication | Shared-memory parallelism, threads, parallel loops | [Open experiment](Experiment_2/README.md) |
| 03 | MPI Matrix Multiplication | Distributed memory, process communication, send/receive | [Open experiment](Experiment_3/README.md) |
| 04 | CUDA Matrix Multiplication | GPU execution model, kernel timing, host/device transfers | [Open experiment](Experiment_4/README.md) |
| 05 | Synchronization Mechanisms | Race conditions, critical sections, atomics, barriers, semaphores | [Open experiment](Experiment_5/README.md) |
| 06 | Cache Coherence and NUMA | MSI/MESI/MOESI, false sharing, memory locality | [Open experiment](Experiment_6/README.md) |
| 07 | Neural Network Layers with CUDA | Matrix multiplication, bias, ReLU, sigmoid, CPU/GPU validation | [Open experiment](Experiment_7/README.md) |

## Repository map

```text
PGC_lab/
├── Experiment_1/
│   ├── README.md
│   └── src/
├── Experiment_2/
│   ├── README.md
│   └── src/
├── Experiment_3/
│   ├── README.md
│   └── src/
├── Experiment_4/
│   └── README.md
├── Experiment_5/
│   ├── README.md
│   └── src/
├── Experiment_6/
│   ├── README.md
│   └── src/
└── Experiment_7/
    ├── README.md
    └── neural_network.cu
```

The tree above is a guide to the top-level organization; individual folders may contain additional files.

## Technology stack

| Area | Tools and technologies |
|---|---|
| Systems programming | C, GCC |
| Shared-memory computing | OpenMP, POSIX threads |
| Distributed computing | MPI |
| GPU programming | NVIDIA CUDA, NVCC |
| Synchronization | OpenMP synchronization, POSIX semaphores |
| Architecture studies | Cache coherence, false sharing, NUMA |
| Analysis | Python and command-line benchmarking |

## Working with an experiment

1. Open the experiment's README.
2. Check its prerequisites and recorded environment.
3. Move to the repository root before running the listed commands unless the experiment says otherwise.
4. Compile the source with the command shown in that experiment.
5. Run the executable and compare your output with the expected validation value.
6. Record your own timings with the machine, compiler and configuration used.

### Common setup packages (Ubuntu)

Install only the packages required by the experiment you are running:

```bash
sudo apt update
sudo apt install build-essential
```

For MPI, OpenMP, Python or CUDA work, follow the additional setup instructions in the corresponding experiment. CUDA requires a compatible NVIDIA GPU, driver and toolkit; a CPU-only system cannot execute CUDA kernels.

## Understanding the performance results

Performance measurements are hardware- and configuration-dependent. Treat values in the experiment records as observations from the stated environment, not as guaranteed results on every machine.

- **Execution time:** elapsed time for the measured section of work.
- **Speedup:** sequential execution time divided by parallel execution time.
- **Efficiency:** speedup divided by the number of processing units, commonly expressed as a percentage.
- **Kernel time vs end-to-end time:** CUDA kernel-only measurements exclude host/device transfer time; end-to-end measurements include the phases explicitly stated in the experiment.

## Learning outcomes

By working through these experiments, the lab develops practical understanding of:

- How a sequential baseline is used to assess parallel implementations.
- How threads and processes divide computational work.
- Why synchronization is required when parallel workers share data.
- How cache-coherence traffic and false sharing affect performance.
- How GPU kernels and data transfers contribute to total execution time.
- How to validate numerical output before interpreting benchmark results.

## Repository conventions

- Each experiment has its own README with its aim, procedure, prerequisites, source map and conclusion.
- Source files are kept with the experiment they implement.
- Measured results are identified as recorded observations; missing implementations or measurements are stated openly.
- Re-run benchmarks before comparing systems, and update the environment details alongside new measurements.

---

**Maintained by Sammed Patil**  
[GitHub repository](https://github.com/sammed027/PGC_lab)
