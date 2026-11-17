# Experiment 4 — CUDA Matrix Multiplication

## Aim
Study GPU acceleration for matrix multiplication with NVIDIA CUDA and examine the difference between kernel execution time and the full GPU computation phase.

## Recorded workload and environment

| Parameter | Recorded configuration |
|---|---|
| Matrix dimension | 4000 × 4000 |
| GPU | NVIDIA GeForce RTX 2050 |
| CUDA compute capability | 8.6 |
| Input initialization | All matrix elements recorded as 1.0 |
| Expected verification | C[0][0] = 4000.00 |

## Source availability
The CUDA matrix-multiplication `.cu` source file is **not currently present** in this experiment folder. This README preserves the recorded lab details, but the experiment cannot be rebuilt from this repository alone until the original source is added.

No replacement implementation has been invented or copied from another repository.

## Recorded observations

| Measurement | Recorded value |
|---|---:|
| CUDA kernel time | 0.316872 s |
| CUDA total phase (transfers and computation) | 0.343028 s |
| Sequential CPU reference time | 417.205920 s |
| Reported end-to-end speedup | 1216.24× |
| Verification: C[0][0] | 4000.00 |

The kernel-only measurement excludes host/device data transfers. The total-phase measurement includes the transfer and computation phases stated in the original record. The speedup uses the total-phase time:

```text
Speedup = 417.205920 / 0.343028 ≈ 1216.24
```

These are measurements from the recorded hardware and should not be treated as expected timings on another GPU.

## Requirements for reproducing the experiment
- An NVIDIA GPU supported by the installed driver
- NVIDIA driver and CUDA Toolkit
- NVCC compiler
- The original CUDA source file used for the recorded run

## Reproducibility checklist
When restoring the source, keep the following details with the experiment:
1. Kernel launch dimensions (grid and block sizes).
2. Allocation and host-to-device/device-to-host transfer steps.
3. Whether timing is kernel-only or end-to-end.
4. The matrix initialization and output verification.
5. GPU model, driver and CUDA Toolkit version.

## Conclusion
The recorded run illustrates the potential of GPU parallelism for a large matrix multiplication task. The documentation and historical measurements are retained, while the missing source is explicitly identified as a reproducibility gap.
