#include <verilated.h>

#include <string>
#include <iostream>
#include <sstream>
#include <fstream>
#include <vector>

#include "Vcentroid.h"

#include "testbench_common.h"
#include "read_img.h"

int main(int argc, char** argv, char** env){
    if(argc < 2) {
        std::cerr << "Please provide a file path to the input image" << std::endl;
        exit(1);
    }

    bool pixels[IMG_WIDTH * IMG_HEIGHT];
    if(readImageBool(argv[1],pixels) != 0) {
        std::cerr << "error reading input image, make sure \'" << argv[1] << "\' is a valid path" << std::endl;
        exit(1);
    }

    Vcentroid* uut = new Vcentroid;
    int main_time = 0;
    bool running = true;

    uut->data_enable = 0;
    uut->clk = 0;
    uut->data_in_x = 0;
    uut->data_in_y = 0;
    uut->data_end = 0;

    int count = 0;

    while(running){
        main_time++;

        if(main_time % (CLK_PER / 2) == 0) {//always #5 clk <= ~clk
            uut->clk = !uut->clk;
        }
        if(main_time % CLK_PER == 0) {//always @posedge clk
            if(uut->done){
                running = false;
                std::cout << "centroid: " << (int)uut->centroid_x << "," << (int)uut->centroid_y << std::endl;
            } else if(!uut->data_end) {
                uut->data_enable = pixels[count];
                uut->data_in_x = count % IMG_WIDTH;
                uut->data_in_y = count / IMG_HEIGHT;
                uut->data_end = count >= (IMG_WIDTH * IMG_HEIGHT);
                count++;
            }
        }
        uut->eval();
    }
    uut->final();
    delete uut;
    return 0;

}