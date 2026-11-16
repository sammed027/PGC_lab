#include <stdio.h>
#include <omp.h>

int main(void) {
    #pragma omp parallel num_threads(2)
    {
        int id = omp_get_thread_num();

        printf("Thread %d before barrier\n", id);

        #pragma omp barrier

        printf("Thread %d after barrier\n", id);
    }

    return 0;
}
