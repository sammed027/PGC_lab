#include <stdio.h>
#include <omp.h>

#define TOTAL_INCREMENTS 10000000LL

static long long run_none(int threads, double *elapsed) {
    long long counter = 0;
    double start = omp_get_wtime();

    #pragma omp parallel for num_threads(threads)
    for (long long i = 0; i < TOTAL_INCREMENTS; ++i) {
        counter++; /* Deliberately racy baseline. */
    }

    *elapsed = omp_get_wtime() - start;
    return counter;
}

static long long run_critical(int threads, double *elapsed) {
    long long counter = 0;
    double start = omp_get_wtime();

    #pragma omp parallel for num_threads(threads)
    for (long long i = 0; i < TOTAL_INCREMENTS; ++i) {
        #pragma omp critical
        {
            counter++;
        }
    }

    *elapsed = omp_get_wtime() - start;
    return counter;
}

static long long run_atomic(int threads, double *elapsed) {
    long long counter = 0;
    double start = omp_get_wtime();

    #pragma omp parallel for num_threads(threads)
    for (long long i = 0; i < TOTAL_INCREMENTS; ++i) {
        #pragma omp atomic
        counter++;
    }

    *elapsed = omp_get_wtime() - start;
    return counter;
}

static long long run_lock(int threads, double *elapsed) {
    long long counter = 0;
    omp_lock_t lock;
    omp_init_lock(&lock);
    double start = omp_get_wtime();

    #pragma omp parallel for num_threads(threads)
    for (long long i = 0; i < TOTAL_INCREMENTS; ++i) {
        omp_set_lock(&lock);
        counter++;
        omp_unset_lock(&lock);
    }

    *elapsed = omp_get_wtime() - start;
    omp_destroy_lock(&lock);
    return counter;
}

static void report(const char *name, int threads,
                   long long count, double elapsed) {
    printf("%-10s | %7d | %10lld | %-9s | %.4f\n",
           name, threads, count,
           count == TOTAL_INCREMENTS ? "Correct" : "INCORRECT",
           elapsed);
}

int main(void) {
    const int thread_counts[] = {1, 2, 4, 8};
    const int count = (int)(sizeof(thread_counts) / sizeof(thread_counts[0]));

    printf("Comparing synchronization mechanisms\n\n");
    printf("Mechanism | Threads | Final Count | Correctness | Time (s)\n");
    printf("---------------------------------------------------------------\n");

    for (int i = 0; i < count; ++i) {
        int threads = thread_counts[i];
        double elapsed;
        long long value;

        value = run_none(threads, &elapsed);
        report("None", threads, value, elapsed);

        value = run_critical(threads, &elapsed);
        report("Critical", threads, value, elapsed);

        value = run_atomic(threads, &elapsed);
        report("Atomic", threads, value, elapsed);

        value = run_lock(threads, &elapsed);
        report("Lock", threads, value, elapsed);

        printf("---------------------------------------------------------------\n");
    }

    printf("\nExpected correct final count = %lld\n", TOTAL_INCREMENTS);
    return 0;
}
