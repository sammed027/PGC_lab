#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

#define N 4000

int main(int argc, char **argv) {
    MPI_Init(&argc, &argv);
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (N % size != 0) {
        if (rank == 0) fprintf(stderr, "Matrix size must be divisible by process count.\n");
        MPI_Finalize();
        return EXIT_FAILURE;
    }

    const int rows = N / size;
    double *B = malloc((size_t)N * N * sizeof(double));
    double *localA = malloc((size_t)rows * N * sizeof(double));
    double *localC = malloc((size_t)rows * N * sizeof(double));
    double *A = rank == 0 ? malloc((size_t)N * N * sizeof(double)) : NULL;
    double *C = rank == 0 ? malloc((size_t)N * N * sizeof(double)) : NULL;

    int allocationFailed = !B || !localA || !localC || (rank == 0 && (!A || !C));
    int anyAllocationFailed = 0;
    MPI_Allreduce(&allocationFailed, &anyAllocationFailed, 1, MPI_INT, MPI_MAX, MPI_COMM_WORLD);
    if (anyAllocationFailed) {
        if (rank == 0) fprintf(stderr, "Memory allocation failed.\n");
        free(A); free(B); free(C); free(localA); free(localC);
        MPI_Finalize();
        return EXIT_FAILURE;
    }

    if (rank == 0) {
        for (int i = 0; i < N * N; ++i) {
            A[i] = 1.0;
            B[i] = 1.0;
        }
    }
    MPI_Bcast(B, N * N, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    MPI_Barrier(MPI_COMM_WORLD);
    const double start = MPI_Wtime();
    MPI_Scatter(A, rows * N, MPI_DOUBLE, localA, rows * N, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < N; ++j) {
            double sum = 0.0;
            for (int k = 0; k < N; ++k)
                sum += localA[(size_t)i * N + k] * B[(size_t)k * N + j];
            localC[(size_t)i * N + j] = sum;
        }
    }

    MPI_Gather(localC, rows * N, MPI_DOUBLE, C, rows * N, MPI_DOUBLE, 0, MPI_COMM_WORLD);
    MPI_Barrier(MPI_COMM_WORLD);
    const double elapsed = MPI_Wtime() - start;

    if (rank == 0) {
        printf("MPI matrix multiplication completed\n");
        printf("Matrix size: %d x %d\n", N, N);
        printf("MPI processes: %d\n", size);
        printf("Execution time: %.6f seconds\n", elapsed);
        printf("Verification C[0][0]: %.2f\n", C[0]);
    }

    free(A); free(B); free(C); free(localA); free(localC);
    MPI_Finalize();
    return EXIT_SUCCESS;
}
