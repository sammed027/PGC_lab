#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>

#define THREAD_COUNT 2
#define INCREMENTS_PER_THREAD 100000

static long long counter = 0;
static sem_t semaphore;

static void *worker(void *arg) {
    (void)arg;

    for (int i = 0; i < INCREMENTS_PER_THREAD; ++i) {
        sem_wait(&semaphore);
        counter++;
        sem_post(&semaphore);
    }

    return NULL;
}

int main(void) {
    pthread_t threads[THREAD_COUNT];

    if (sem_init(&semaphore, 0, 1) != 0) {
        perror("sem_init");
        return 1;
    }

    for (int i = 0; i < THREAD_COUNT; ++i) {
        if (pthread_create(&threads[i], NULL, worker, NULL) != 0) {
            perror("pthread_create");
            sem_destroy(&semaphore);
            return 1;
        }
    }

    for (int i = 0; i < THREAD_COUNT; ++i) {
        pthread_join(threads[i], NULL);
    }

    printf("Counter = %lld\n", counter);
    sem_destroy(&semaphore);
    return 0;
}
