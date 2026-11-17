# Parallel and GPU Computing Laboratory

[![Course](https://img.shields.io/badge/Course-Parallel%20%26%20GPU%20Computing-2457A7)](https://github.com/sammed027/PGC_lab)
[![Experiments](https://img.shields.io/badge/Experiments-7-6D4CBB)](./)
[![Languages](https://img.shields.io/badge/Languages-C%20%7C%20CUDA%20%7C%20Python-16865C)](./)
[![Documentation](https://img.shields.io/badge/Documentation-Expanded-success)](./)

## 1. Introduction

This repository contains the practical work completed for the **Parallel and GPU Computing Laboratory**. The experiments move from conventional sequential execution to shared-memory parallelism, distributed-memory processing, GPU acceleration, synchronization, memory-system behaviour and GPU-based neural-network computation.

The central theme of the laboratory is understanding how computational work can be divided among multiple execution units, how those units communicate and coordinate, and how the underlying memory hierarchy influences performance. Each experiment combines implementation or simulation with execution, output validation and interpretation of measured behaviour.

The repository is organized so that each experiment can be studied independently. Its README explains the problem, theoretical background, implementation approach, commands, recorded observations and limitations. Source code is stored alongside the corresponding experiment wherever it is available.

## 2. Objectives of the laboratory

- Understand the difference between sequential, shared-memory, distributed-memory and GPU execution models.
- Implement and examine matrix multiplication as a common computational workload.
- Learn how OpenMP threads divide loop iterations and share addressable memory.
- Understand MPI ranks, message passing and collective communication.
- Explore CUDA kernels, thread-level parallelism and host/device data movement.
- Identify race conditions and apply suitable synchronization primitives.
- Study cache-coherence protocols, false sharing and NUMA memory locality.
- Implement basic neural-network forward-pass operations on a GPU.
- Validate program output and interpret execution-time measurements carefully.

## 3. Experiment index

| No. | Experiment | Main topics | Detailed record |
|:--:|---|---|---|
| 01 | Sequential Matrix Multiplication | CPU baseline, nested loops, complexity, timing | [Experiment 1](Experiment_1/README.md) |
| 02 | OpenMP Matrix Multiplication | Shared-memory model, threads, loop scheduling | [Experiment 2](Experiment_2/README.md) |
| 03 | MPI Matrix Multiplication and Message Passing | Distributed memory, ranks, broadcast, scatter, gather, send/receive | [Experiment 3](Experiment_3/README.md) |
| 04 | CUDA Matrix Multiplication | GPU kernels, memory transfers, kernel and total timing | [Experiment 4](Experiment_4/README.md) |
| 05 | Synchronization Mechanisms | Race conditions, critical sections, atomics, barriers, semaphores and locks | [Experiment 5](Experiment_5/README.md) |
| 06 | Cache Coherence, False Sharing and NUMA | MSI/MESI/MOESI, cache lines, padding, memory locality | [Experiment 6](Experiment_6/README.md) |
| 07 | Neural Network Layers with CUDA | Matrix multiplication, bias, ReLU, sigmoid and CPU/GPU validation | [Experiment 7](Experiment_7/README.md) |

## 4. Repository organization

```text
PGC_lab/
├── README.md
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

Each experiment folder is intended to contain its own documentation and implementation files. Experiment 4 currently preserves its recorded lab details but does not yet contain the original CUDA source file; this is explicitly documented in that experiment's README.

## 5. Technology and tools

| Technology | Role in the laboratory |
|---|---|
| C | Sequential algorithms, shared-memory examples and systems programming |
| GCC | Compiling C programs |
| OpenMP | Creating and coordinating shared-memory threads |
| POSIX threads and semaphores | Thread-level concurrency and synchronization |
| MPI / Open MPI | Communication among independent processes |
| CUDA / NVCC | Writing and compiling GPU kernels |
| Python | Simulating cache-coherence protocol behaviour |
| Ubuntu / Linux tools | Compilation, execution and system inspection |
| VMware virtual machine | Providing a Linux environment for selected practicals |

The exact requirements vary by experiment. A compiler or library being installed does not automatically mean that the host has the hardware required to execute a particular workload. For example, CUDA kernel execution requires a supported NVIDIA GPU, a compatible driver and the CUDA Toolkit.

## 6. General workflow followed

1. **Understand the problem:** identify the input, expected output and computational operation.
2. **Study the execution model:** determine whether work runs sequentially, across threads, across processes or on a GPU.
3. **Prepare the environment:** verify the compiler, runtime and hardware prerequisites.
4. **Compile or launch:** use the commands provided in the experiment record.
5. **Validate correctness:** compare the output with the expected value or CPU reference where available.
6. **Measure performance:** record the measured region and the timing method.
7. **Interpret the result:** consider parallel overhead, memory bandwidth, communication and hardware configuration.
8. **Document evidence:** retain genuine terminal output, relevant system details and screenshots from the actual run.

## 7. Performance terminology

**Execution time** is the time taken by the measured portion of a program. It is meaningful only when the timed region is clearly identified.

**Speedup** compares a reference execution with a parallel or accelerated execution:

```text
Speedup = Reference execution time / Parallel execution time
```

**Parallel efficiency** indicates how effectively the available processing units contribute:

```text
Efficiency = Speedup / Number of processing units
```

**Kernel time** measures GPU kernel execution without necessarily including host/device data transfers. **End-to-end time** includes the phases explicitly measured by the program, such as memory copies, kernel launches and synchronization. These values should not be compared as though they measure the same work.

## 8. General observations across the experiments

The experiments illustrate that parallelism is not simply a matter of adding more threads or processors. Work must be divided in a way that avoids unnecessary dependencies, shared data must be accessed safely, and communication or memory-transfer overhead must be considered. A parallel implementation can produce the correct result but still provide limited speedup if the workload is constrained by memory bandwidth, synchronization or process communication.

The matrix multiplication experiments provide a useful progression: a sequential implementation establishes the reference computation, OpenMP distributes work among threads, MPI distributes work among processes, and CUDA maps computation to GPU execution units. Later experiments examine the coordination and memory-system issues that influence such implementations.

## 9. Reproducibility and academic integrity

Recorded timings are observations from the hardware and software environments described in the experiment records. They are not guaranteed performance targets. Re-running a program on a different processor, GPU, virtual machine, compiler version or thread configuration may produce different results.

For a fair comparison:
- Use the same input dimensions and initialization across compared implementations.
- State the number of threads or MPI processes used.
- Identify whether timing includes setup, communication and memory transfers.
- Run multiple trials when possible and report the measurement method.
- Preserve the actual program output and do not edit screenshots to imply a result that was not produced.
- Clearly distinguish recorded historical results from newly reproduced measurements.

## 10. Learning outcomes

On completion of these practicals, the learner should be able to explain the major parallel execution models, implement basic parallel workloads, select synchronization mechanisms for shared data, describe cache-coherence behaviour, identify false sharing, interpret a constrained NUMA environment and validate GPU computations against a CPU reference.

---

**Maintained by Sammed Patil**  
[View the complete GitHub repository](https://github.com/sammed027/PGC_lab)
