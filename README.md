# Parallel and GPU Computing Laboratory

A structured collection of laboratory experiments covering CPU execution, shared-memory parallelism, distributed-memory computing, GPU computing, synchronization, cache coherence and CUDA neural-network operations.

## Experiments

| No. | Experiment | Main topics |
|---:|---|---|
| 1 | [Sequential Matrix Multiplication](Experiment_1/README.md) | CPU baseline |
| 2 | [OpenMP Matrix Multiplication](Experiment_2/README.md) | Shared-memory parallelism |
| 3 | [MPI Matrix Multiplication](Experiment_3/README.md) | Distributed-memory parallelism and message passing |
| 4 | [CUDA Matrix Multiplication](Experiment_4/README.md) | GPU acceleration |
| 5 | [Synchronization Mechanisms](Experiment_5/README.md) | Race conditions, critical sections, atomics, barriers and semaphores |
| 6 | [Cache Coherence and NUMA](Experiment_6/README.md) | MSI, MESI, MOESI, false sharing and NUMA |
| 7 | [Neural Network Layers in CUDA](Experiment_7/README.md) | Matrix multiplication, ReLU, sigmoid and CPU/GPU comparison |

## Repository structure

```text
PGC_lab/
├── Experiment_1/   # Sequential matrix multiplication
├── Experiment_2/   # OpenMP matrix multiplication
├── Experiment_3/   # MPI matrix multiplication
├── Experiment_4/   # CUDA matrix multiplication
├── Experiment_5/   # Synchronization mechanisms
├── Experiment_6/   # Cache coherence and NUMA
└── Experiment_7/   # CUDA neural-network layers
```

## Getting started

Open the README inside the required experiment for its aim, setup, compilation commands, execution steps and recorded observations. Install the listed compiler/runtime before building the source.

## Technologies

C, OpenMP, MPI, POSIX threads, POSIX semaphores, Python and NVIDIA CUDA.
