// Experiment 5: Neural Network Layers in CUDA
// Two-layer forward pass: MatMul + Bias -> ReLU -> MatMul + Bias -> Sigmoid.
// CPU and GPU results are compared for correctness and performance.

#include <cuda_runtime.h>
#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <vector>

#define CUDA_CHECK(call) do {                                      \
    cudaError_t err__ = (call);                                    \
    if (err__ != cudaSuccess) {                                    \
        std::cerr << "CUDA error: " << cudaGetErrorString(err__)   \
                  << " at " << __FILE__ << ":" << __LINE__        \
                  << std::endl;                                    \
        std::exit(EXIT_FAILURE);                                   \
    }                                                              \
} while (0)

constexpr int BATCH = 256;
constexpr int INPUT_SIZE = 128;
constexpr int HIDDEN_SIZE = 64;
constexpr int OUTPUT_SIZE = 10;
constexpr int REPEATS = 20;

__global__ void matrixMulBiasKernel(
    const float* A, const float* B, const float* bias, float* C,
    int M, int N, int K) {
    const int row = blockIdx.y * blockDim.y + threadIdx.y;
    const int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < M && col < N) {
        float sum = 0.0f;
        for (int k = 0; k < K; ++k) {
            sum += A[row * K + k] * B[k * N + col];
        }
        C[row * N + col] = sum + bias[col];
    }
}

__global__ void reluKernel(float* values, int count) {
    const int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < count) values[idx] = fmaxf(0.0f, values[idx]);
}

__global__ void sigmoidKernel(float* values, int count) {
    const int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < count) values[idx] = 1.0f / (1.0f + expf(-values[idx]));
}

void cpuMatMulBias(const std::vector<float>& A,
                   const std::vector<float>& B,
                   const std::vector<float>& bias,
                   std::vector<float>& C,
                   int M, int N, int K) {
    for (int row = 0; row < M; ++row) {
        for (int col = 0; col < N; ++col) {
            float sum = 0.0f;
            for (int k = 0; k < K; ++k)
                sum += A[row * K + k] * B[k * N + col];
            C[row * N + col] = sum + bias[col];
        }
    }
}

void cpuReLU(std::vector<float>& values) {
    for (float& x : values) x = std::max(0.0f, x);
}

void cpuSigmoid(std::vector<float>& values) {
    for (float& x : values) x = 1.0f / (1.0f + std::exp(-x));
}

void cpuForwardPass(const std::vector<float>& X,
                    const std::vector<float>& W1,
                    const std::vector<float>& b1,
                    const std::vector<float>& W2,
                    const std::vector<float>& b2,
                    std::vector<float>& output) {
    std::vector<float> hidden(BATCH * HIDDEN_SIZE);
    cpuMatMulBias(X, W1, b1, hidden, BATCH, HIDDEN_SIZE, INPUT_SIZE);
    cpuReLU(hidden);

    std::vector<float> result(BATCH * OUTPUT_SIZE);
    cpuMatMulBias(hidden, W2, b2, result, BATCH, OUTPUT_SIZE, HIDDEN_SIZE);
    cpuSigmoid(result);
    output.swap(result);
}

void gpuForwardPass(const float* dX, const float* dW1, const float* db1,
                    float* dHidden, const float* dW2, const float* db2,
                    float* dOutput) {
    const dim3 block2D(16, 16);
    const dim3 grid1((HIDDEN_SIZE + block2D.x - 1) / block2D.x,
                     (BATCH + block2D.y - 1) / block2D.y);

    matrixMulBiasKernel<<<grid1, block2D>>>(
        dX, dW1, db1, dHidden, BATCH, HIDDEN_SIZE, INPUT_SIZE);

    const int threads = 256;
    const int hiddenCount = BATCH * HIDDEN_SIZE;
    reluKernel<<<(hiddenCount + threads - 1) / threads, threads>>>(
        dHidden, hiddenCount);

    const dim3 grid2((OUTPUT_SIZE + block2D.x - 1) / block2D.x,
                     (BATCH + block2D.y - 1) / block2D.y);
    matrixMulBiasKernel<<<grid2, block2D>>>(
        dHidden, dW2, db2, dOutput, BATCH, OUTPUT_SIZE, HIDDEN_SIZE);

    const int outputCount = BATCH * OUTPUT_SIZE;
    sigmoidKernel<<<(outputCount + threads - 1) / threads, threads>>>(
        dOutput, outputCount);
    CUDA_CHECK(cudaGetLastError());
}

bool testMatrixKernel() {
    const std::vector<float> A{1, 2, 3, 4, 5, 6};
    const std::vector<float> B{1, 2, 3, 4, 5, 6};
    const std::vector<float> bias{1, -1};
    std::vector<float> output(4, 0.0f);
    float *dA = nullptr, *dB = nullptr, *dBias = nullptr, *dC = nullptr;

    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&dA), A.size() * sizeof(float)));
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&dB), B.size() * sizeof(float)));
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&dBias), bias.size() * sizeof(float)));
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&dC), output.size() * sizeof(float)));
    CUDA_CHECK(cudaMemcpy(dA, A.data(), A.size() * sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(dB, B.data(), B.size() * sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(dBias, bias.data(), bias.size() * sizeof(float), cudaMemcpyHostToDevice));

    matrixMulBiasKernel<<<dim3(1, 1), dim3(16, 16)>>>(dA, dB, dBias, dC, 2, 2, 3);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    CUDA_CHECK(cudaMemcpy(output.data(), dC, output.size() * sizeof(float), cudaMemcpyDeviceToHost));

    const bool ok = std::fabs(output[0] - 23.0f) < 1e-5f &&
                    std::fabs(output[1] - 27.0f) < 1e-5f &&
                    std::fabs(output[2] - 50.0f) < 1e-5f &&
                    std::fabs(output[3] - 63.0f) < 1e-5f;

    cudaFree(dA); cudaFree(dB); cudaFree(dBias); cudaFree(dC);
    return ok;
}

bool testActivationKernels() {
    std::vector<float> reluValues{-2.0f, 0.0f, 3.0f, -4.0f, 5.0f};
    float* dRelu = nullptr;
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&dRelu), reluValues.size() * sizeof(float)));
    CUDA_CHECK(cudaMemcpy(dRelu, reluValues.data(), reluValues.size() * sizeof(float), cudaMemcpyHostToDevice));
    reluKernel<<<1, 256>>>(dRelu, static_cast<int>(reluValues.size()));
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    CUDA_CHECK(cudaMemcpy(reluValues.data(), dRelu, reluValues.size() * sizeof(float), cudaMemcpyDeviceToHost));
    const bool reluOK = reluValues == std::vector<float>{0.0f, 0.0f, 3.0f, 0.0f, 5.0f};
    cudaFree(dRelu);

    std::vector<float> sigmoidValues{-2.0f, 0.0f, 2.0f};
    float* dSigmoid = nullptr;
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&dSigmoid), sigmoidValues.size() * sizeof(float)));
    CUDA_CHECK(cudaMemcpy(dSigmoid, sigmoidValues.data(), sigmoidValues.size() * sizeof(float), cudaMemcpyHostToDevice));
    sigmoidKernel<<<1, 256>>>(dSigmoid, static_cast<int>(sigmoidValues.size()));
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    CUDA_CHECK(cudaMemcpy(sigmoidValues.data(), dSigmoid, sigmoidValues.size() * sizeof(float), cudaMemcpyDeviceToHost));
    const bool sigmoidOK =
        std::fabs(sigmoidValues[0] - 0.1192029f) < 1e-5f &&
        std::fabs(sigmoidValues[1] - 0.5f) < 1e-5f &&
        std::fabs(sigmoidValues[2] - 0.8807971f) < 1e-5f;
    cudaFree(dSigmoid);

    std::cout << "ReLU: " << (reluOK ? "PASSED" : "FAILED") << "\n";
    std::cout << "Sigmoid: " << (sigmoidOK ? "PASSED" : "FAILED") << "\n";
    return reluOK && sigmoidOK;
}

int main() {
    int deviceCount = 0;
    CUDA_CHECK(cudaGetDeviceCount(&deviceCount));
    if (deviceCount == 0) {
        std::cerr << "No CUDA-capable NVIDIA GPU was detected.\n";
        return EXIT_FAILURE;
    }

    CUDA_CHECK(cudaSetDevice(0));
    cudaDeviceProp prop{};
    CUDA_CHECK(cudaGetDeviceProperties(&prop, 0));

    std::cout << "EXPERIMENT 5: NEURAL NETWORK LAYERS IN CUDA\n";
    std::cout << "GPU detected: " << prop.name << "\n\n";
    std::cout << "Testing individual CUDA kernels...\n";

    const bool matrixOK = testMatrixKernel();
    std::cout << "Matrix multiplication + bias: "
              << (matrixOK ? "PASSED" : "FAILED") << "\n";
    const bool activationsOK = testActivationKernels();
    if (!matrixOK || !activationsOK) return EXIT_FAILURE;

    std::vector<float> X(BATCH * INPUT_SIZE);
    std::vector<float> W1(INPUT_SIZE * HIDDEN_SIZE);
    std::vector<float> b1(HIDDEN_SIZE);
    std::vector<float> W2(HIDDEN_SIZE * OUTPUT_SIZE);
    std::vector<float> b2(OUTPUT_SIZE);

    for (size_t i = 0; i < X.size(); ++i)
        X[i] = 0.5f * std::sin(static_cast<float>(i) * 0.013f);
    for (size_t i = 0; i < W1.size(); ++i)
        W1[i] = 0.08f * std::cos(static_cast<float>(i) * 0.017f);
    for (size_t i = 0; i < b1.size(); ++i)
        b1[i] = 0.01f * static_cast<float>(i % 7);
    for (size_t i = 0; i < W2.size(); ++i)
        W2[i] = 0.10f * std::sin(static_cast<float>(i) * 0.019f);
    for (size_t i = 0; i < b2.size(); ++i)
        b2[i] = 0.02f * static_cast<float>(i % 5);

    std::vector<float> cpuOutput(BATCH * OUTPUT_SIZE);
    const auto cpuStart = std::chrono::steady_clock::now();
    for (int r = 0; r < REPEATS; ++r)
        cpuForwardPass(X, W1, b1, W2, b2, cpuOutput);
    const auto cpuStop = std::chrono::steady_clock::now();
    const double cpuMs =
        std::chrono::duration<double, std::milli>(cpuStop - cpuStart).count() / REPEATS;

    float *dX = nullptr, *dW1 = nullptr, *db1 = nullptr, *dHidden = nullptr;
    float *dW2 = nullptr, *db2 = nullptr, *dOutput = nullptr;
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&dX), X.size() * sizeof(float)));
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&dW1), W1.size() * sizeof(float)));
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&db1), b1.size() * sizeof(float)));
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&dHidden), BATCH * HIDDEN_SIZE * sizeof(float)));
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&dW2), W2.size() * sizeof(float)));
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&db2), b2.size() * sizeof(float)));
    CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&dOutput), BATCH * OUTPUT_SIZE * sizeof(float)));

    CUDA_CHECK(cudaMemcpy(dX, X.data(), X.size() * sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(dW1, W1.data(), W1.size() * sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(db1, b1.data(), b1.size() * sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(dW2, W2.data(), W2.size() * sizeof(float), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(db2, b2.data(), b2.size() * sizeof(float), cudaMemcpyHostToDevice));

    gpuForwardPass(dX, dW1, db1, dHidden, dW2, db2, dOutput);
    CUDA_CHECK(cudaDeviceSynchronize());

    cudaEvent_t eventStart, eventStop;
    CUDA_CHECK(cudaEventCreate(&eventStart));
    CUDA_CHECK(cudaEventCreate(&eventStop));
    CUDA_CHECK(cudaEventRecord(eventStart));
    for (int r = 0; r < REPEATS; ++r)
        gpuForwardPass(dX, dW1, db1, dHidden, dW2, db2, dOutput);
    CUDA_CHECK(cudaEventRecord(eventStop));
    CUDA_CHECK(cudaEventSynchronize(eventStop));
    float gpuKernelMs = 0.0f;
    CUDA_CHECK(cudaEventElapsedTime(&gpuKernelMs, eventStart, eventStop));
    gpuKernelMs /= REPEATS;

    std::vector<float> gpuOutput(BATCH * OUTPUT_SIZE);
    const auto totalStart = std::chrono::steady_clock::now();
    for (int r = 0; r < REPEATS; ++r) {
        CUDA_CHECK(cudaMemcpy(dX, X.data(), X.size() * sizeof(float), cudaMemcpyHostToDevice));
        CUDA_CHECK(cudaMemcpy(dW1, W1.data(), W1.size() * sizeof(float), cudaMemcpyHostToDevice));
        CUDA_CHECK(cudaMemcpy(db1, b1.data(), b1.size() * sizeof(float), cudaMemcpyHostToDevice));
        CUDA_CHECK(cudaMemcpy(dW2, W2.data(), W2.size() * sizeof(float), cudaMemcpyHostToDevice));
        CUDA_CHECK(cudaMemcpy(db2, b2.data(), b2.size() * sizeof(float), cudaMemcpyHostToDevice));
        gpuForwardPass(dX, dW1, db1, dHidden, dW2, db2, dOutput);
        CUDA_CHECK(cudaDeviceSynchronize());
        CUDA_CHECK(cudaMemcpy(gpuOutput.data(), dOutput, gpuOutput.size() * sizeof(float), cudaMemcpyDeviceToHost));
    }
    const auto totalStop = std::chrono::steady_clock::now();
    const double gpuEndToEndMs =
        std::chrono::duration<double, std::milli>(totalStop - totalStart).count() / REPEATS;

    float maxDifference = 0.0f;
    for (size_t i = 0; i < cpuOutput.size(); ++i)
        maxDifference = std::max(maxDifference, std::fabs(cpuOutput[i] - gpuOutput[i]));

    std::cout << std::fixed << std::setprecision(6);
    std::cout << "\nForward-pass dimensions:\n";
    std::cout << "Input: " << BATCH << " x " << INPUT_SIZE << "\n";
    std::cout << "Hidden layer: " << BATCH << " x " << HIDDEN_SIZE << "\n";
    std::cout << "Output: " << BATCH << " x " << OUTPUT_SIZE << "\n";
    std::cout << "\nAverage CPU compute time: " << cpuMs << " ms\n";
    std::cout << "Average GPU kernel-only time: " << gpuKernelMs << " ms\n";
    std::cout << "Average GPU end-to-end time: " << gpuEndToEndMs << " ms\n";
    if (gpuKernelMs > 0.0f)
        std::cout << "Kernel-only speedup: " << cpuMs / gpuKernelMs << "x\n";
    if (gpuEndToEndMs > 0.0)
        std::cout << "End-to-end speedup: " << cpuMs / gpuEndToEndMs << "x\n";
    std::cout << "\nMaximum absolute output difference: " << maxDifference << "\n";
    std::cout << "CPU and GPU outputs: "
              << (maxDifference < 1e-4f ? "MATCH (within tolerance)" : "DO NOT MATCH")
              << "\n";
    std::cout << "\nFirst 10 output values (GPU):\n";
    for (int i = 0; i < 10; ++i)
        std::cout << gpuOutput[i] << (i == 9 ? '\n' : ' ');

    CUDA_CHECK(cudaEventDestroy(eventStart));
    CUDA_CHECK(cudaEventDestroy(eventStop));
    cudaFree(dX); cudaFree(dW1); cudaFree(db1); cudaFree(dHidden);
    cudaFree(dW2); cudaFree(db2); cudaFree(dOutput);

    return maxDifference < 1e-4f ? EXIT_SUCCESS : EXIT_FAILURE;
}
