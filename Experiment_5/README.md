# Experiment 5 – Neural Network Layers in CUDA

## Aim

To implement neural-network forward-pass operations using CUDA kernels and compare CPU and GPU correctness and execution performance.

## Environment

| Component | Observed configuration |
|---|---|
| Operating system | Windows |
| GPU | NVIDIA GeForce RTX 5060 Ti |
| GPU memory reported | 16,311 MiB |
| NVIDIA driver | 621.24 |
| CUDA Toolkit used | 13.5 |
| Compiler | NVIDIA NVCC |
| Build tools | Visual Studio C++ Build Tools |

## Network architecture

This experiment performs forward propagation (inference) through a two-layer feed-forward network.

```text
Input (256 × 128)
       |
       v
Matrix multiplication + bias
       |
       v
ReLU activation
       |
       v
Hidden layer (256 × 64)
       |
       v
Matrix multiplication + bias
       |
       v
Sigmoid activation
       |
       v
Output (256 × 10)
```

| Parameter | Value |
|---|---:|
| Batch size | 256 |
| Input size | 128 |
| Hidden size | 64 |
| Output size | 10 |
| Repeated executions | 20 |

## CUDA operations

- **Matrix multiplication with bias:** computes a weighted sum and adds the corresponding bias.
- **ReLU:** `max(0, x)`.
- **Sigmoid:** `1 / (1 + exp(-x))`.

## Build and run

Open a Visual Studio Developer Command Prompt with CUDA and MSVC available. Run from this folder:

```bat
nvcc --version
nvidia-smi
where nvcc
nvcc -O2 neural_network.cu -o neural_network.exe
dir neural_network.exe
neural_network.exe
```

## Kernel validation

| Kernel | Result |
|---|---|
| Matrix multiplication + bias | PASSED |
| ReLU | PASSED |
| Sigmoid | PASSED |

## Performance results

| Measurement | Observed result |
|---|---:|
| CPU compute time | 0.896225 ms |
| GPU kernel-only time | 0.056718 ms |
| GPU end-to-end time | 0.246490 ms |
| Kernel-only speedup | 15.801310× |
| End-to-end speedup | 3.635949× |
| Maximum absolute output difference | 0.000000 |
| CPU/GPU output validation | MATCH |

### Speedup calculation

```text
Kernel-only speedup = CPU time / GPU kernel-only time
                    = 0.896225 / 0.056718
                    = 15.801310×

End-to-end speedup = CPU time / GPU end-to-end time
                   = 0.896225 / 0.246490
                   = 3.635949×
```

The kernel-only measurement excludes host/device data transfers. End-to-end timing includes transfers and GPU execution.

## Output

The first ten GPU output values were:

```text
0.498196 0.503101 0.508006 0.512911 0.517814
0.497729 0.502638 0.507548 0.512457 0.517364
```

## Observations

1. All three CUDA kernel tests passed.
2. CPU and GPU outputs matched within the program's tolerance.
3. GPU kernel-only execution was faster than CPU computation in the recorded run.
4. Data-transfer and execution overhead reduced the end-to-end speedup.
5. The selected compiler was CUDA Toolkit 13.5; CUDA Toolkit 13.4 was also installed.

## Conclusion

The CUDA implementation successfully executed matrix multiplication with bias, ReLU and sigmoid operations on the NVIDIA GeForce RTX 5060 Ti. All kernel tests passed, CPU and GPU outputs matched, and the measured speedups were 15.80× for kernel-only execution and 3.64× for end-to-end execution.
