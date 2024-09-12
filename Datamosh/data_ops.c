#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define INITIAL_BUFFER_SIZE 1024

typedef struct {
    char *data;
    size_t length;
} FILEDATA;

FILEDATA read_file(const char *filename) {
    FILEDATA result = {NULL, 0};
    FILE *file = fopen(filename, "rb");
    if (!file) {
        perror("Failed to open file");
        return result;
    }

    // Allocate initial buffer
    size_t buffer_size = INITIAL_BUFFER_SIZE;
    char *buffer = malloc(buffer_size);
    if (!buffer) {
        perror("Failed to allocate memory");
        fclose(file);
        return result;
    }

    size_t length = 0;
    size_t read_size;

    // Read the file in chunks and resize buffer as needed
    while ((read_size = fread(buffer + length, 1, buffer_size - length, file)) > 0) {
        length += read_size;
        
        // Check if more buffer size is needed
        if (length >= buffer_size) {
            buffer_size *= 2;
            char *new_buffer = realloc(buffer, buffer_size);
            if (!new_buffer) {
                perror("Failed to resize buffer");
                free(buffer);
                fclose(file);
                return result;
            }
            buffer = new_buffer;
        }
    }

    if (ferror(file)) {
        perror("Error reading file");
        free(buffer);
        fclose(file);
        return result;
    }

    buffer[length] = '\0';

    result.data = buffer;
    result.length = length;

    fclose(file);
    return result;
}

int gen_rand(int lower, int upper) {
    return lower + rand() % (upper - lower);
}

void char_replace(char *data, size_t data_size) {
    const char hexDigits[] = "0123456789abcdef";

    int replacement_len=2;
    char *replacement = (char *)malloc(replacement_len+1);
    char *substring = (char *)malloc(replacement_len+1);

    if (replacement == NULL || substring == NULL) {
        perror("Failed to allocate memory");
        exit(EXIT_FAILURE);
    }

    for (size_t i = 0; i < replacement_len; i++){
        replacement[i] = hexDigits[gen_rand(0,16)];
        substring[i] = hexDigits[gen_rand(0,16)];
    }
    
    char *substring_loc = strstr(data, substring);
    double probability = .25 * replacement_len * exp(-0.08 * (data_size / (5000.0 * replacement_len)));
    probability = fmax(0.005, fmin(probability, 1));

    for (size_t i = 0; i < data_size - replacement_len; i++) {
        if (memcmp(data + i, substring, replacement_len) == 0) {
            if ((rand() / (double)RAND_MAX) < probability) {
                memcpy(data + i, replacement, replacement_len);
            }
        }
    }


    free(replacement); 
    free(substring); 
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <value>\n", argv[0]);
        return 1;
    }

    srand(time(NULL));

    FILEDATA file_data = read_file(argv[1]);

    if (file_data.data) {

        char_replace(file_data.data, file_data.length);

        printf("%s", file_data.data);

        free(file_data.data);   
    }

    return 0;
}