# Experiment 4 — Matrix Multiplication Using NVIDIA CUDA

## 1. Aim

To study GPU acceleration of matrix multiplication using NVIDIA CUDA, understand the role of GPU kernels and host/device memory transfers, and interpret the difference between kernel execution time and the total measured GPU computation phase.

## 2. Introduction

A CPU typically executes a relatively small number of powerful processing cores, whereas a GPU contains many execution units designed to perform large numbers of similar operations concurrently. This makes GPUs useful for data-parallel workloads in which many output values can be calculated independently.

Matrix multiplication is a representative GPU workload. Each output matrix element is obtained from a row of A and a column of B. Different output elements can be calculated concurrently, making it possible to assign work to many CUDA threads.

CUDA is NVIDIA's parallel computing platform and programming model. A CUDA program commonly contains host code that runs on the CPU and device code, called kernels, that runs on the GPU.

## 3. Mathematical formulation

For two N × N matrices A and B, the product C is:

```text
C[i][j] = Σ A[i][k] × B[k][j], for k = 0 to N-1
```

The recorded workload uses 4000 × 4000 matrices. All input elements are initialized to 1.0. Therefore, each output element is expected to equal 4000.00.

## 4. CUDA execution concepts

A typical CUDA matrix multiplication workflow contains the following stages:

1. The CPU prepares and initializes input matrices.
2. Device memory is allocated for the data required by the GPU.
3. Input data is copied from host memory to device memory.
4. The CPU launches a CUDA kernel with a configured grid and block layout.
5. GPU threads execute the assigned matrix calculations.
6. The program synchronizes as required to ensure kernel completion.
7. The output is copied from device memory to host memory.
8. The CPU checks the result and reports the measured time.

The kernel launch configuration determines how many thread blocks and threads are used. A common mapping assigns a thread to one output element, although the exact mapping depends on the implementation. The original source and its launch configuration are required to document those details precisely.

## 5. Recorded experimental configuration

| Parameter | Recorded value |
|---|---|
| Matrix dimension | 4000 × 4000 |
| GPU | NVIDIA GeForce RTX 2050 |
| CUDA compute capability | 8.6 |
| Input initialization | All elements recorded as 1.0 |
| Expected verification | C[0][0] = 4000.00 |
| Programming platform | NVIDIA CUDA |

## 6. Source availability and reproducibility status

The original CUDA matrix-multiplication `.cu` source file used for the recorded run is **not currently present in this experiment folder**. The documentation below preserves the recorded lab configuration and observations, but this repository alone does not currently contain enough source material to rebuild the exact experiment.

No replacement implementation has been presented as the original program. To make this practical fully reproducible, add the original source file and retain the exact kernel launch configuration, allocation strategy and timing boundaries.

## 7. Requirements for reproducing the experiment

- A supported NVIDIA GPU.
- A compatible NVIDIA graphics driver.
- NVIDIA CUDA Toolkit.
- The `nvcc` compiler.
- The original matrix multiplication CUDA source file.
- Sufficient GPU memory for the input and output matrices.

A CPU-only machine or a virtual machine without GPU passthrough cannot execute the CUDA kernel merely by installing the CUDA compiler.

## 8. Suggested environment verification

The following commands can be used on a configured NVIDIA CUDA system:

```bash
nvidia-smi
nvcc --version
```

The first command reports the visible NVIDIA GPU and driver information. The second reports the installed CUDA compiler version. These commands verify parts of the environment; they do not by themselves reproduce the matrix multiplication experiment.

## 9. Recorded observations

| Measurement | Recorded value |
|---|---:|
| CUDA kernel time | 0.316872 s |
| CUDA total phase (transfers and computation) | 0.343028 s |
| Sequential CPU reference time | 417.205920 s |
| Reported end-to-end speedup | 1216.24× |
| Verification: C[0][0] | 4000.00 |

The recorded speedup is based on the total GPU phase:

```text
Speedup = 417.205920 / 0.343028
        ≈ 1216.24
```

These figures are historical observations from the recorded NVIDIA GeForce RTX 2050 system. They are not expected timings for every GPU or software configuration.

## 10. Kernel time versus total execution time

Kernel time represents the time spent executing the GPU kernel. It generally does not include the time required to prepare host data, allocate device memory or copy input and output arrays.

The total phase recorded here includes the transfer and computation phases described in the original lab record. For an application, total time is often the more useful measurement because data must be moved to and from the GPU as part of the complete task.

The difference between the two measurements illustrates why GPU performance should not be described using kernel time alone. Data-transfer costs, launch overhead and synchronization can affect the time experienced by the complete application.

## 11. Reproduction checklist

When the original source is restored, document the following items alongside the result:

1. Exact CUDA source filename and compiler command.
2. Matrix dimensions, data type and initialization method.
3. GPU model, driver version and CUDA Toolkit version.
4. Device-memory allocation and host-to-device/device-to-host copy operations.
5. Kernel grid dimensions and block dimensions.
6. Whether timing uses CUDA events or another timing mechanism.
7. Whether the reported time is kernel-only or end-to-end.
8. Output verification method and the actual terminal result.

## 12. Discussion

The recorded run illustrates the potential of GPU parallelism for a large matrix multiplication workload. The input data provides a simple expected output, making it possible to check numerical correctness. The large difference between the CPU reference and recorded GPU phase highlights the value of parallel execution for suitable workloads.

However, performance figures must be interpreted in the context of the measured code and environment. Without the original source file, the exact kernel mapping, memory strategy and timing implementation cannot be independently inspected or reproduced from this repository.

## 13. Conclusion

This experiment records the use of an NVIDIA GPU for matrix multiplication and highlights two important performance measurements: kernel execution time and the total GPU computation phase. The recorded output value is consistent with the expected result for the initialized matrices. Restoring the original CUDA source is the remaining requirement for complete source-level reproducibility.
