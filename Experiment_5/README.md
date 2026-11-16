# Experiment 5 – Neural Network Layers in CUDA

## Aim

Implement and evaluate basic neural-network layers using custom CUDA kernels: matrix multiplication with bias, ReLU activation, and sigmoid activation. Compare the CPU and GPU forward passes for correctness and performance.

## Experimental environment

| Component | Observed result |
|---|---|
| OS / shell | Windows Command Prompt |
| GPU | NVIDIA GeForce RTX 5060 Ti |
| GPU memory | 16,311 MiB reported by `nvidia-smi` |
| NVIDIA driver | 621.24 |
| CUDA Toolkit selected by `nvcc` | 13.5 |
| CUDA compiler | NVIDIA `nvcc` |
| Build command | `nvcc -O2 neural_network.cu -o neural_network.exe` |

The `where nvcc` screenshot shows two CUDA compiler installations:
- `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.5\bin\nvcc.exe`
- `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.4\bin\nvcc.exe`

The version command reports CUDA compilation tools release 13.5, and that is the compiler version recorded for this run.

## Network architecture

This experiment performs **forward propagation (inference)** through a two-layer feed-forward network. It does not train the network and does not perform backpropagation or optimizer updates.

```text
Input X (256 × 128)
       |
       v
Matrix multiplication + bias (W1, b1)
       |
       v
ReLU activation
       |
       v
Hidden layer (256 × 64)
       |
       v
Matrix multiplication + bias (W2, b2)
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
| Input tensor | 256 × 128 |
| Hidden activation | 256 × 64 |
| Output tensor | 256 × 10 |

### CUDA operations

1. **Matrix multiplication with bias:** each CUDA thread calculates one output element and adds the corresponding bias.
2. **ReLU:** \(\mathrm{ReLU}(x)=\max(0,x)\).
3. **Sigmoid:** \(\sigma(x)=\frac{1}{1+e^{-x}}\).

The GPU forward pass executes matrix multiplication + bias, ReLU, matrix multiplication + bias, and sigmoid in sequence.

## Build and run

Open a Developer Command Prompt or Command Prompt configured with the CUDA Toolkit and Visual Studio C++ build tools. From the experiment directory:

```bat
nvcc --version
nvidia-smi
where nvcc
nvcc -O2 neural_network.cu -o neural_network.exe
dir neural_network.exe
neural_network.exe
```

The screenshots show the executable was generated successfully. The original `neural_network.cu` source file was not attached with the screenshots, so it is not reproduced in this repository section. Add the exact source file used for the recorded run to this folder before treating the repository as a fully reproducible source submission.

## Actual results from the submitted run

### Kernel validation

| CUDA kernel | Result |
|---|---|
| Matrix multiplication + bias | PASSED |
| ReLU | PASSED |
| Sigmoid | PASSED |

### Performance

| Measurement | Observed result |
|---|---:|
| Average CPU compute time | 0.896225 ms |
| Average GPU kernel-only time | 0.056718 ms |
| Average GPU end-to-end time | 0.246490 ms |
| Kernel-only speedup | 15.801310× |
| End-to-end speedup | 3.635949× |
| Maximum absolute output difference | 0.000000 |
| CPU and GPU outputs | MATCH (within tolerance) |

### Speedup calculations

```text
Kernel-only speedup = CPU time / GPU kernel-only time
                    = 0.896225 / 0.056718
                    ≈ 15.801310×

End-to-end speedup = CPU time / GPU end-to-end time
                   = 0.896225 / 0.246490
                   ≈ 3.635949×
```

The kernel-only measurement excludes host/device transfer overhead. The end-to-end measurement includes the complete GPU execution path, so it is the more representative measure when data must be transferred for each run.

### Output validation

The program reports a maximum absolute output difference of **0.000000** and confirms that CPU and GPU outputs **MATCH (within tolerance)**. The first ten GPU output values shown are:

```text
0.498196 0.503101 0.508006 0.512911 0.517814
0.497729 0.502638 0.507548 0.512457 0.517364
```

## Observations

1. All three individual CUDA kernel tests passed.
2. The CPU and GPU forward-pass outputs matched within the program's tolerance.
3. The GPU kernel-only time was lower than the CPU compute time, producing a measured 15.80× speedup.
4. Including data transfer and end-to-end work reduced the measured speedup to 3.64×.
5. The exact timing values depend on the GPU, driver, compiler, workload, warm-up, and system load.
6. Two CUDA Toolkit installations (13.4 and 13.5) are present. The `nvcc --version` output confirms that version 13.5 was selected for this build.

## Conclusion

Custom CUDA kernels for matrix multiplication with bias, ReLU, and sigmoid were compiled and executed successfully on an NVIDIA GeForce RTX 5060 Ti. All individual kernel tests passed, and the CPU and GPU outputs matched within tolerance. The measured GPU speedups were 15.80× for kernel-only execution and 3.64× for end-to-end execution. This experiment demonstrates both GPU parallel computation and the impact of host-device data-transfer overhead.

## Screenshot evidence

Five original screenshots document the CUDA Toolkit version, GPU and driver information, successful executable compilation, installed compiler paths, and complete program output.

Place the supplied image files in `Experiment_5/screenshots/` using these names:

```text
screenshots/
├── 01-cuda-toolkit-version.jpg
├── 02-nvidia-smi-gpu-details.jpg
├── 03-compiled-executable.jpg
├── 04-nvcc-installation-paths.jpg
└── 05-neural-network-execution-results.jpg
```

The screenshots are also packaged in the accompanying `Experiment_5_screenshots.zip`. The GitHub text-file writer used for this commit cannot upload binary image files, so the images are **not yet embedded in the GitHub folder**. Extract the ZIP into the repository root and push the screenshot folder to publish them.

## Suggested repository structure

```text
Experiment_5/
├── README.md
├── neural_network.cu       # add the exact source used for this run
└── screenshots/
    ├── 01-cuda-toolkit-version.jpg
    ├── 02-nvidia-smi-gpu-details.jpg
    ├── 03-compiled-executable.jpg
    ├── 04-nvcc-installation-paths.jpg
    └── 05-neural-network-execution-results.jpg
```
