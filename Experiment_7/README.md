# Experiment 7 — Implementation of Neural Network Layers Using CUDA

## 1. Aim

To implement the forward-pass operations of a small two-layer neural network using NVIDIA CUDA, understand how matrix multiplication and activation functions can be parallelized on a GPU, and validate GPU results against a CPU reference implementation.

## 2. Introduction

Neural networks perform computations by applying weighted sums and activation functions to input data. Matrix multiplication is a central operation in many neural-network layers because it combines a batch of input vectors with a matrix of learned or configured weights. Bias values are then added, and an activation function introduces non-linearity.

GPUs are well suited to these workloads because many output values can be calculated independently. CUDA allows the programmer to write kernels that distribute these operations among GPU threads.

This experiment demonstrates an inference-style forward pass. It does not train a neural network, optimize weights or use an external dataset. Instead, it focuses on implementing the computational layers and checking whether the GPU implementation agrees with the CPU reference.

## 3. Network architecture

The program uses a two-layer structure:

```text
Input matrix: 256 × 128
        |
        v
Matrix multiplication + bias
        |
        v
ReLU activation
        |
        v
Hidden representation: 256 × 64
        |
        v
Matrix multiplication + bias
        |
        v
Sigmoid activation
        |
        v
Output matrix: 256 × 10
```

The input and weight arrays are initialized using deterministic sine- and cosine-based values in the program. This provides repeatable input values for testing without relying on a downloaded dataset.

## 4. Mathematical operations

### 4.1 Fully connected layer

A fully connected layer calculates a weighted sum for each output unit. In matrix form:

```text
Z = X × W + b
```

Here, X represents the input batch, W is the weight matrix and b is the bias vector. The bias is added to the corresponding output feature.

### 4.2 ReLU activation

The hidden layer applies the Rectified Linear Unit function:

```text
ReLU(x) = max(0, x)
```

Negative values are replaced by zero, while zero and positive values remain unchanged.

### 4.3 Sigmoid activation

The output layer applies the sigmoid function:

```text
Sigmoid(x) = 1 / (1 + e^(-x))
```

The sigmoid maps real-valued inputs into the interval (0, 1). In this experiment it is used to demonstrate an activation kernel; the output is not presented as a trained model's probability prediction.

## 5. CUDA implementation approach

The source file contains CPU reference functions and GPU kernels for the neural-network operations. The GPU work includes matrix multiplication with bias, ReLU activation and sigmoid activation.

The overall execution flow is:

1. Initialize input and weight arrays with deterministic values.
2. Prepare the CPU reference calculation.
3. Allocate GPU memory for the arrays and intermediate results.
4. Copy the required input data from host memory to device memory.
5. Launch the CUDA matrix multiplication and bias operation.
6. Apply the ReLU activation to the hidden-layer output.
7. Execute the second matrix multiplication and bias operation.
8. Apply the sigmoid activation to the final output.
9. Copy the GPU output back to host memory.
10. Synchronize and compare CPU and GPU results.
11. Repeat the timing process to obtain averaged measurements.

The exact kernel implementation and validation logic are available in the source file linked below.

## 6. Recorded environment

| Parameter | Recorded value |
|---|---|
| Operating system | Windows |
| GPU | NVIDIA GeForce RTX 5060 Ti |
| Reported GPU memory | 16,311 MiB |
| NVIDIA driver | 621.24 |
| CUDA Toolkit | 13.5 |
| Compiler | NVCC |
| Timing repetitions | 20 |

A compatible NVIDIA GPU, driver, CUDA Toolkit and Visual Studio C++ build environment are required for the recorded Windows build workflow.

## 7. Source file

- [`neural_network.cu`](neural_network.cu) — contains CPU reference functions, CUDA matrix multiplication with bias, ReLU and sigmoid kernels, individual validation tests and performance timing.

## 8. Compilation and execution

Open a Visual Studio Developer Command Prompt in which MSVC and CUDA are configured. From the repository root, verify the environment:

```bat
nvcc --version
nvidia-smi
```

Compile the CUDA source:

```bat
nvcc -O2 Experiment_7/neural_network.cu -o Experiment_7/neural_network.exe
```

Run the generated executable:

```bat
Experiment_7\neural_network.exe
```

The program performs individual kernel checks, executes the CPU and GPU forward passes, compares their output arrays and averages timing over 20 repetitions.

## 9. Validation strategy

The program validates the individual operations before relying on the complete forward pass.

- **Matrix multiplication with bias:** checks the output of a small matrix and bias example against the expected result.
- **ReLU:** checks that negative inputs become zero and non-negative inputs remain unchanged.
- **Sigmoid:** checks representative input values against known sigmoid results.
- **Full forward pass:** compares the CPU and GPU output arrays element by element.

The program accepts a maximum absolute output difference below `1e-4`. The maximum absolute difference is a useful numerical validation measure because floating-point calculations can be affected by operation ordering and precision.

## 10. Recorded validation and performance results

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

The recorded values are from the stated Windows and NVIDIA GPU environment. They are observations, not guaranteed results on another computer.

## 11. Performance calculations and interpretation

The kernel-only speedup compares CPU compute time with GPU kernel time:

```text
Kernel-only speedup = 0.896225 / 0.056718
                    ≈ 15.80×
```

The end-to-end speedup compares CPU compute time with the GPU end-to-end time:

```text
End-to-end speedup = 0.896225 / 0.246490
                   ≈ 3.64×
```

The kernel-only speedup is larger because it excludes the data-transfer and other end-to-end phases. The complete application must move data between host and device memory and synchronize the work, so kernel speedup alone does not describe the entire application experience.

## 12. Important observations

- Matrix multiplication is a major computational component of fully connected neural-network layers.
- Bias addition is part of the affine transformation performed before activation.
- ReLU and sigmoid apply element-wise operations that can also be parallelized.
- CPU reference calculations provide a way to validate GPU output.
- A zero maximum absolute difference in the recorded run indicates that the compared output arrays matched at the precision reported by the program.
- Kernel-only and end-to-end measurements answer different performance questions.

## 13. Scope and limitations

This practical demonstrates a forward pass with deterministic input and weight values. It does not include a training phase, backpropagation, gradient calculation, weight updates, model evaluation on a dataset or a claim of predictive accuracy. The recorded performance depends on the GPU, driver, CUDA version, compiler settings and timing procedure.

## 14. Conclusion

The experiment successfully demonstrates how common neural-network forward-pass operations can be implemented using CUDA. Matrix multiplication with bias, ReLU and sigmoid are validated individually, and the complete GPU output is compared with a CPU reference. The recorded maximum absolute difference is zero. The performance measurements show that GPU kernels can execute the workload faster than the CPU reference, while the smaller end-to-end speedup demonstrates the importance of data transfers and synchronization when evaluating a complete GPU application.
