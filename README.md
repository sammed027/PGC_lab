# Parallel and GPU Computing Laboratory

A collection of completed laboratory experiments covering parallel programming, synchronization, cache coherence, NUMA memory behavior, and CUDA GPU computing.

## Experiments

| Experiment | Title | Main topics |
|---|---|---|
| [Experiment 3](Experiment_3/README.md) | Synchronization Mechanisms in Parallel Programs | Race conditions, critical sections, atomic operations, barriers, POSIX semaphores |
| [Experiment 4](Experiment_4/README.md) | Cache Coherence and NUMA | MSI, MESI, MOESI, false sharing, cache-line padding, NUMA topology |
| [Experiment 5](Experiment_5/README.md) | Neural Network Layers in CUDA | Matrix multiplication with bias, ReLU, sigmoid, CPU/GPU validation and timing |

## Repository structure

```text
PGC_lab/
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

## How to use

Open the README inside an experiment folder for its objective, requirements, source files, build and run commands, measured results, observations, and conclusion.

## Technologies

- C and C++
- OpenMP and POSIX threads
- POSIX semaphores
- Python
- NVIDIA CUDA Toolkit
- GCC and NVIDIA NVCC
- Ubuntu and Windows
