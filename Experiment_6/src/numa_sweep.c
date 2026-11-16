#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <omp.h>

int main(int argc, char **argv) {
    size_t mb = argc > 1 ? (size_t)atol(argv[1]) : 256;
    size_t n = mb << 20;
    char *buf = malloc(n);
    if (!buf) { perror("malloc"); return 1; }
    memset(buf, 1, n); /* first touch follows the active NUMA policy */
    long long sum = 0;
    double t0 = omp_get_wtime();
    for (int pass = 0; pass < 4; ++pass) {
        #pragma omp parallel for reduction(+:sum)
        for (size_t i = 0; i < n; i += 64)
            sum += (unsigned char)buf[i];
    }
    printf("buffer=%zu MB | threads=%d | sum=%lld | time=%.4f s\n",
           mb, omp_get_max_threads(), sum, omp_get_wtime() - t0);
    free(buf);
    return 0;
}
