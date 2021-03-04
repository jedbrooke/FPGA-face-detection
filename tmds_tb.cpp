#include <verilated.h>

#include "Vtmds_tb.h"


#include <string>
#include <iostream>
#include <fstream>

#include "testbench_common.h"
#include "read_img.h"

int main(int argc, char** argv, char** env){
    
    if(argc < 2) {
        std::cerr << "Please provide a file path to the input image" << std::endl;
        exit(1);
    }

    uint8_t pixels[IMG_WIDTH * IMG_HEIGHT][3];
    uint8_t pixels_out[IMG_WIDTH * IMG_HEIGHT][3];

    if (readImage(argv[1],pixels) != 0)
    {
        std::cerr << "error reading input image, make sure \'" << argv[1] << "\' is a valid path" << std::endl;
        exit(1);
    }
    
    Vtmds_tb* uut = new Vtmds_tb;

    long main_time = 0;
    bool end_of_image = false;

    uut->data_enable = 0;
    uut->clk = 0;

    uut->r_in = 0;
    uut->g_in = 0;
    uut->b_in = 0;
    
    uut->control_in_r = 0;
    uut->control_in_g = 0;
    uut->control_in_b = 0;

    int x,y = 0;
    int counter = 0;
    while(!end_of_image) {
        main_time++;

        if(main_time % (CLK_PER / 2) == 0) {//always #5 clk <= ~clk
            uut->clk = !uut->clk;
        }

        if(main_time  % CLK_PER == 0){
            std::cout << "clock cycle " << counter << std::endl;
            uut->data_enable = 1;
            uut->r_in = pixels[counter][0];
            uut->g_in = pixels[counter][1];
            uut->b_in = pixels[counter][2];
        } else if(main_time % CLK_PER == (CLK_PER - 1)) {
            pixels_out[counter][0] = uut->r_out;
            pixels_out[counter][1] = uut->g_out;
            pixels_out[counter][2] = uut->b_out;
            counter++;
        }

        uut->eval();
    }

    uut->final();
    delete uut;

    // print out captured image
    std::ofstream out("output.txt");
    if(out.is_open()) {    
        for(int i = 0; i < (IMG_WIDTH * IMG_HEIGHT); i++) {
            out << (int) (pixels_out[i][0]) << "," << (int) (pixels_out[i][1]) << "," << (int) (pixels_out[i][2]) << std::endl;
        }
    }
    out.flush();
    out.close();
    return 0;
}