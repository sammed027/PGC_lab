# Experiment 7 — Neural Network Layers in CUDA

## Aim
Implement the forward pass of a small two-layer neural network using CUDA kernels, then compare CPU and GPU outputs and execution times.

> This experiment demonstrates inference-style forward-pass operations. It does not train a neural network or use an external dataset.

## Network workflow

```text
Input: 256 × 128
       |
Matrix multiplication + bias
       |
      ReLU
       |
Hidden layer: 256 × 64
       |
Matrix multiplication + bias
       |
    Sigmoid
       |
Output: 256 × 10
```

The input and weight arrays are initialized with deterministic sine/cosine-based values in the program.

## Environment recorded for the run
- Operating system: Windows
- GPU: NVIDIA GeForce RTX 5060 Ti (16,311 MiB reported)
- NVIDIA driver: 621.24
- CUDA Toolkit: 13.5
- Compiler: NVCC

A compatible NVIDIA GPU, driver, CUDA Toolkit and Visual Studio C++ build environment are required for the recorded Windows build workflow.

## Source file
- [`neural_network.cu`](neural_network.cu) — CPU reference functions, CUDA matrix multiplication with bias, ReLU and sigmoid kernels, validation tests and timing.

## Compile and run
Open a Visual Studio Developer Command Prompt with CUDA and MSVC configured. From the repository root:

```bat
nvcc --version
nvidia-smi
nvcc -O2 Experiment_7/neural_network.cu -o Experiment_7/neural_network.exe
Experiment_7\neural_network.exe
```

The program performs individual kernel checks, runs the CPU and GPU forward passes, and compares their outputs. It averages timing across 20 repetitions.

## Recorded validation and performance

| Measurement | Recorded value |
|---|---:|
| Matrix multiplication + bias test | PASSED |
| ReLU test | PASSED |
| Sigmoid test | PASSED |
| CPU compute time | 0.896225 ms |
| GPU kernel-only time | 0.056718 ms |
| GPU end-to-end time | 0.246490 ms |
| Kernel-only speedup | 15.801310× |
| End-to-end speedup | 3.635949× |
| Maximum absolute output difference | 0.000000 |

Kernel-only timing measures the GPU kernels and excludes host/device copies. The end-to-end measurement includes the input copies, GPU execution, synchronization and output copy. The values above are results from the recorded machine, not expected timings for every GPU.

## Validation logic
- The matrix multiplication test checks the output of a small matrix and bias example.
- The ReLU test checks that negative values become zero and non-negative values remain unchanged.
- The sigmoid test checks representative values against known results.
- The full forward pass compares CPU and GPU output arrays; the program accepts a maximum absolute difference below `1e-4`.

## What to observe
- Each CUDA thread calculates an output matrix element or activation element.
- The matrix multiplication kernel adds the bias after accumulating the dot product.
- ReLU is applied to the hidden layer and sigmoid to the output layer.
- Kernel-only speedup can be larger than end-to-end speedup because data transfers and synchronization contribute to total time.

## Conclusion
The CUDA implementation executes a two-layer forward pass and validates its operations against known values and a CPU reference. The recorded output difference was zero, and the end-to-end result shows why transfer costs should be considered alongside kernel performance.
