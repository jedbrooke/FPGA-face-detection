#include "testbench_common.h"

/* 
    reads in an image from a text file, formatted as 1 pixel per line as r,g,b
    stores r,g,b values
*/
bool readImage(char* path, uint8_t pixels[IMG_WIDTH * IMG_HEIGHT][3]);

/* 
    reads in an image from a text file, formatted as 1 pixel per line as r,g,b
    stores a boolean mask of where the pixels are greater than THRESH
*/
bool readImageBool(char* path, bool pixels[IMG_WIDTH * IMG_HEIGHT]);