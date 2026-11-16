# Experiment 4 – CUDA Matrix Multiplication

## Aim
Study GPU acceleration for matrix multiplication using NVIDIA CUDA and compare the recorded GPU timing with CPU execution.

## Recorded workload and environment
- Matrix dimensions: 4000 × 4000
- GPU recorded: NVIDIA GeForce RTX 2050
- CUDA compute capability recorded: 8.6
- Expected output element: 4000.00

## Source availability
The CUDA matrix-multiplication source file was not present in the repository files available during this organization. This folder therefore documents the experiment and its recorded measurements; it does not currently contain a runnable `.cu` implementation.

## Recorded results

| Measurement | Result |
|---|---:|
| CUDA kernel time | 0.316872 s |
| CUDA total phase (including transfers and computation) | 0.343028 s |
| Sequential CPU baseline | 417.205920 s |
| End-to-end speedup over sequential | 1216.24× |
| Verified output C[0][0] | 4000.00 |

Kernel-only timing excludes host/device transfers. The total-phase timing includes them. These values describe the recorded setup and are not universal performance figures.

## Conclusion
The recorded CUDA run demonstrates the potential of GPU parallelism for a compute-intensive matrix multiplication task. Add the original CUDA source file to this folder to make the experiment independently reproducible.
