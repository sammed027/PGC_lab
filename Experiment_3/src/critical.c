#include <stdio.h>
#include <omp.h>

int main(void) {
    long long counter = 0;
    const long long iterations = 1000000;

    #pragma omp parallel for
    for (long long i = 0; i < iterations; ++i) {
        #pragma omp critical
        {
            counter++;
        }
    }

    printf("Counter = %lld\n", counter);
    return 0;
}
