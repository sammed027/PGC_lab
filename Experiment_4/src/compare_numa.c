#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#define N 100000000L
#define MB 256UL

static double run_counters(int nt, int stride, long *total) {
    size_t bytes = ((size_t)nt * stride * sizeof(long) + 63) / 64 * 64;
    long *cnt = aligned_alloc(64, bytes);
    if (!cnt) { perror("aligned_alloc"); exit(1); }
    for (int i = 0; i < nt * stride; ++i) cnt[i] = 0;
    double t0 = omp_get_wtime();
    #pragma omp parallel num_threads(nt)
    {
        volatile long *p = &cnt[omp_get_thread_num() * stride];
        for (long i = 0; i < N / nt; ++i) (*p)++;
    }
    double elapsed = omp_get_wtime() - t0;
    *total = 0;
    for (int i = 0; i < nt; ++i) *total += cnt[i * stride];
    free(cnt);
    return elapsed;
}

static double run_sweep(char *buf, size_t n, int nt) {
    long long sum = 0;
    double t0 = omp_get_wtime();
    for (int pass = 0; pass < 4; ++pass) {
        #pragma omp parallel for num_threads(nt) reduction(+:sum)
        for (size_t i = 0; i < n; i += 64)
            sum += (unsigned char)buf[i];
    }
    if (sum == 0) puts("unexpected zero sum");
    return omp_get_wtime() - t0;
}

int main(void) {
    int thread_counts[] = {1, 2, 4};
    puts("Table 1: False sharing (100000000 increments)");
    puts("Layout   | Threads | Final Count | Correctness | Time (s)");
    for (int i = 0; i < 3; ++i) {
        for (int stride = 1; stride <= 8; stride *= 8) {
            long total;
            double t = run_counters(thread_counts[i], stride, &total);
            printf("%-8s | %7d | %11ld | %-11s | %8.4f\n",
                   stride == 1 ? "adjacent" : "padded", thread_counts[i],
                   total, total == N ? "Correct" : "INCORRECT", t);
        }
        puts("---------------------------------------------------------");
    }
    size_t n = MB << 20;
    char *buf = malloc(n);
    if (!buf) { perror("malloc"); return 1; }
    for (size_t i = 0; i < n; ++i) buf[i] = 1;
    printf("\nTable 2: Memory sweep of %lu MB (4 passes)\n", MB);
    puts("Threads | Time (s)");
    for (int i = 0; i < 3; ++i)
        printf("%7d | %8.4f\n", thread_counts[i], run_sweep(buf, n, thread_counts[i]));
    free(buf);
    return 0;
}
