#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

#define N 4000

int main(void) {
    double *A = malloc((size_t)N * N * sizeof(double));
    double *B = malloc((size_t)N * N * sizeof(double));
    double *C = malloc((size_t)N * N * sizeof(double));
    if (!A || !B || !C) {
        fprintf(stderr, "Memory allocation failed\n");
        free(A); free(B); free(C);
        return EXIT_FAILURE;
    }

    for (int i = 0; i < N * N; ++i) {
        A[i] = 1.0;
        B[i] = 1.0;
        C[i] = 0.0;
    }

    const double start = omp_get_wtime();
    #pragma omp parallel for schedule(static)
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            double sum = 0.0;
            for (int k = 0; k < N; ++k)
                sum += A[(size_t)i * N + k] * B[(size_t)k * N + j];
            C[(size_t)i * N + j] = sum;
        }
    }
    const double stop = omp_get_wtime();

    printf("OpenMP matrix multiplication completed\n");
    printf("Matrix size: %d x %d\n", N, N);
    printf("Threads: %d\n", omp_get_max_threads());
    printf("Execution time: %.6f seconds\n", stop - start);
    printf("Verification C[0][0]: %.2f\n", C[0]);

    free(A); free(B); free(C);
    return EXIT_SUCCESS;
}
