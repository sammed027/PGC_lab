# Parallel and GPU Computing Laboratory

This repository contains practical implementations and measured results from parallel and GPU computing laboratory experiments.

## Experiments

| No. | Experiment | Topics |
|---:|---|---|
| 1 | [Performance Analysis of Matrix Multiplication](Experiment_1/README.md) | Sequential, OpenMP, MPI and CUDA |
| 3 | [Synchronization Mechanisms](Experiment_3/README.md) | Race conditions, critical sections, atomic operations, barriers and semaphores |
| 4 | [Cache Coherence and NUMA](Experiment_4/README.md) | MSI, MESI, MOESI, false sharing, padding and NUMA |
| 5 | [Neural Network Layers in CUDA](Experiment_5/README.md) | Matrix multiplication with bias, ReLU, sigmoid and CPU/GPU comparison |

## Repository structure

```text
PGC_lab/
├── Experiment_1/
│   ├── README.md
│   └── src/
├── Experiment_3/
│   ├── README.md
│   └── src/
├── Experiment_4/
│   ├── README.md
│   └── src/
└── Experiment_5/
    ├── README.md
    └── neural_network.cu
```

## Getting started

1. Open the README for the experiment you want to run.
2. Install the compiler and libraries listed in that experiment.
3. Compile the source files using the provided commands.
4. Run the executable and compare your output with the recorded observations.

## Technologies

C, C++, OpenMP, MPI, POSIX threads, POSIX semaphores, Python and NVIDIA CUDA.
