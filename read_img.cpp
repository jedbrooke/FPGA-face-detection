#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

#include "read_img.h"


#define THRESH 100

bool readImage(char* path, uint8_t pixels[IMG_WIDTH * IMG_HEIGHT][3]) {
    std::string temp_str;
    std::ifstream img(path);
    //store the bitmask for the pixels read from the text file
    int count = 0;
    if(img.is_open()) {
        while(getline(img,temp_str)){
            std::stringstream parse_pixel(temp_str);
            for (int i = 0; i < 3; i++) {
                getline(parse_pixel,temp_str,',');
                pixels[count][i] = atoi(temp_str.c_str());
            }
            count++;
        }
        img.close();
    } else {
        return 1;
    }
    return 0;
}

bool readImageBool(char* path, bool pixels[IMG_WIDTH * IMG_HEIGHT]) {
    uint8_t pixels_rgb[IMG_WIDTH * IMG_WIDTH][3];
    if(readImage(path,pixels_rgb) != 0) {
        return 1;
    }

    for(int i = 0; i < (IMG_WIDTH * IMG_HEIGHT); i++) {
        pixels[i] = ((pixels_rgb[i][0] + pixels_rgb[i][1] + pixels_rgb[i][2]) / 3 ) / THRESH;
    }
    return 0;
}



