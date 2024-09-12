#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#pragma pack(push, 1)
typedef struct {
    uint8_t type[2];
    uint32_t size;
    uint16_t reserved1;
    uint16_t reserved2;
    uint32_t offset;
} BMPFILEHEADER;

typedef struct {
   uint32_t size;
   uint32_t width;
   uint32_t height;
   uint16_t color_planes;
   uint16_t bits_per_pixel;
   uint32_t compression;
   uint32_t img_size;
   uint32_t horizontalresolution;
   uint32_t verticalresolution;
   uint32_t num_colors;
   uint32_t num_important_colors;  
} BMPINFOHEADER;
#pragma pack(pop)

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
        return EXIT_FAILURE;
    }

    const char *filename = argv[1];
    FILE *file = fopen(filename, "rb");
    if (!file) {
        perror("Unable to open file");
        return EXIT_FAILURE;
    }

    BMPFILEHEADER fileHeader;
    BMPINFOHEADER infoHeader;

    fread(&fileHeader, sizeof(fileHeader), 1, file);
    fread(&infoHeader, sizeof(infoHeader), 1, file);
    fseek(file, fileHeader.offset, SEEK_SET);
    
    int color_channels=infoHeader.bits_per_pixel / 8;
    uint32_t base_row_size = infoHeader.width * color_channels;
    uint32_t padding = (4 - (base_row_size % 4)) % 4;
    uint32_t row_size = base_row_size + padding;

    uint8_t *image_data = (uint8_t *)malloc(row_size * infoHeader.height);
    if (!image_data) {
        perror("Unable to allocate memory for image data");
        fclose(file);
        return EXIT_FAILURE;
    }

    fread(image_data, 1, row_size * infoHeader.height, file);
    fclose(file);

    for (int y = infoHeader.height - 1; y >= 0; y--) {
        // Pixels are sorted bottom up
        uint8_t *row = image_data + y * row_size;
        
        for (int x = 0; x < infoHeader.width; x++) {
            uint8_t b = row[x * color_channels];
            uint8_t g = row[x * color_channels + 1];
            uint8_t r = row[x * color_channels + 2];
            char ansi_value[30];
            printf("\033[48;2;%u;%u;%um  \033[0m", r, g, b);
        }
        printf("\n");
    }

    free(image_data);

    return EXIT_SUCCESS;
}