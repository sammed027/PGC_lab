#include <stdio.h>
#include <omp.h>

int main(void) {
    long long counter = 0;
    const long long iterations = 500000;

    #pragma omp parallel for
    for (long long i = 0; i < iterations; ++i) {
        counter++; /* Deliberately unprotected: demonstrates a race condition. */
    }

    printf("Counter = %lld\n", counter);
    printf("Expected counter = %lld\n", iterations);
    return 0;
}
