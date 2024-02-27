#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

typedef struct {
    char key[64];
    clock_t previous_time;
    clock_t start_time;
    unsigned long long cnt;
} TimeRecord;

TimeRecord records[10];  // Assuming a maximum of 10 different keys
FILE* file = NULL;
const char* filename = "avery_perf_db.txt";

void print_time_difference(clock_t diff) {
    double milliseconds = ((double)diff) * 1000 / CLOCKS_PER_SEC;
    printf("Time difference: %.2f ms\n", milliseconds);
}

/* mb: definition of the avy_wallclock_diff */
extern "C" void avy_wallclock_diff(const char* key, char init) {
    int i;
    clock_t current_time = clock();

    // Search for the key in the records
    for (i = 0; i < 10; i++) {
        if (strcmp(records[i].key, key) == 0) {
            // Key found, calculate the time difference
            clock_t diff = current_time - records[i].previous_time;
            clock_t total_diff = current_time - records[0].start_time;
            records[i].previous_time = current_time;
            if (init == 0) {
                double milliseconds = ((double)diff) * 1000 / CLOCKS_PER_SEC;
                double seconds = ((double)diff) / CLOCKS_PER_SEC;
                double tseconds = ((double)total_diff) / CLOCKS_PER_SEC;
                records[i].cnt++;
                if (file != NULL) {
                    fprintf(file, "key %s cnt: %lld delta time: %.2f s (%.2f ms) total time: %.2f s\n", key, records[i].cnt, seconds, milliseconds, tseconds);
                } else {
                    printf("%s failed to write to file %s\n", __func__, filename);
                }
            }
            return;
        }
    }

    // Key not found, create a new record
    for (i = 0; i < 10; i++) {
        file = fopen(filename, "a");  // Open the file in append mode

        if (records[i].key[0] == '\0') {
            strcpy(records[i].key, key);
            records[i].previous_time = current_time;
            records[i].start_time = current_time;
            records[i].cnt = 1;
            return;
        }
    }

    // No free slots for new keys
    printf("Error: Maximum number of keys exceeded.\n");
}
