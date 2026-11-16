# Experiment 7 – Neural Network Layers in CUDA

## Aim
Implement neural-network forward-pass operations using CUDA kernels and compare CPU/GPU correctness and performance.

## Network
```text
Input (256 × 128)
  -> Matrix multiplication + bias
  -> ReLU
  -> Hidden layer (256 × 64)
  -> Matrix multiplication + bias
  -> Sigmoid
  -> Output (256 × 10)
```

## Environment
- OS: Windows
- GPU: NVIDIA GeForce RTX 5060 Ti (16,311 MiB reported)
- NVIDIA driver: 621.24
- CUDA Toolkit: 13.5
- Compiler: NVCC

## Source
- `neural_network.cu`

## Build and run
Use a Visual Studio Developer Command Prompt with CUDA and MSVC configured:

```bat
nvcc --version
nvidia-smi
nvcc -O2 neural_network.cu -o neural_network.exe
neural_network.exe
```

## Recorded validation and performance

| Measurement | Result |
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

Kernel-only timing excludes host/device transfers; end-to-end timing includes transfers and GPU execution. These are recorded measurements from the experiment setup.

## Conclusion
The CUDA program implements matrix multiplication with bias, ReLU and sigmoid operations. The captured tests passed and CPU/GPU outputs matched within the program's validation tolerance.
