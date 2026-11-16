#include <stdio.h>
#include <stdlib.h>
#include <time.h>

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

    const clock_t start = clock();
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            for (int k = 0; k < N; ++k)
                C[(size_t)i * N + j] += A[(size_t)i * N + k] * B[(size_t)k * N + j];
    const clock_t stop = clock();

    printf("Sequential matrix multiplication completed\n");
    printf("Matrix size: %d x %d\n", N, N);
    printf("Execution time: %.6f seconds\n", (double)(stop - start) / CLOCKS_PER_SEC);
    printf("Verification C[0][0]: %.2f\n", C[0]);

    free(A); free(B); free(C);
    return EXIT_SUCCESS;
}
