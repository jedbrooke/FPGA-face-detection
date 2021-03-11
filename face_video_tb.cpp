
#include <verilated.h>
#include "Vface_reader.h"
#include <opencv2/opencv.hpp>

#include <fstream>
#include <iostream>


#include "testbench_common.h"

#ifndef DEBUG
    #define DEBUG false
#endif

void advance_time(int t, int* main_time, Vface_reader* uut) {
    *main_time += t;
    uut->eval();
}

void advance_clock_edge(int* main_time, Vface_reader* uut) {
    for (auto i = 0; i < (CLK_PER / 2); i++)
    {
        advance_time(1,main_time,uut);
    }
    uut->clk = !uut->clk;
}


void advance_clock_cycle(int* main_time, Vface_reader* uut) {
    // advance two clock edges
    advance_clock_edge(main_time,uut);
    advance_clock_edge(main_time,uut);
}

int main(int argc, char const *argv[])
{
    cv::VideoCapture cap;

    if(argc > 1) {
        cap.open(argv[1]);
    } else {
        // 0 will open the webcam
        cap.open(0);
    }

    if(!cap.isOpened()) {
        std::cerr << "Error opening video file/webcam" << std::endl;
        return 1;
    }

    bool end_of_video = false;
    int main_time = 0;
    Vface_reader* uut = new Vface_reader;
    uut->image_in_R = 0;
    uut->image_in_G = 0;
    uut->image_in_B = 0;
    uut->enable = false;
    uut->enable_process = false;
    uut->clk = 0;

    bool first_frame = true;

    while(!end_of_video) {
        // cv::Mat frame = cv::imread("images/face.png");
        cv::Mat frame;
        cap >> frame;
        uut->enable = true;
        // for pixel in frame
        auto p = frame.begin<cv::Vec3b>();
        while(p != frame.end<cv::Vec3b>()) {
            uut->image_in_B = p[0][0];
            uut->image_in_G = p[0][1];
            uut->image_in_R = p[0][2];
            advance_clock_cycle(&main_time,uut);
            p++;
        }
        if(DEBUG) std::cout << "finished sending pixel data" << std::endl;
        // begin processing
        uut->enable_process = true;
        advance_clock_cycle(&main_time,uut);

        if(DEBUG) std::cout << "waiting for processing" << std::endl;
        // wait for processing to end
        while(!uut->finish) {
            advance_clock_cycle(&main_time,uut);
        }

        if(DEBUG) std::cout << "processing done, recieving image" << std::endl;

        // image is done, recieve result
        cv::Mat frame_out(frame.rows, frame.cols, CV_8UC3, cv::Scalar(0,0,0));
        for(p = frame_out.begin<cv::Vec3b>(); p != frame_out.end<cv::Vec3b>(); p++) {
            p[0][0] = uut->image_output;
            p[0][1] = uut->image_output;
            p[0][2] = uut->image_output;
            advance_clock_cycle(&main_time,uut);
        }

        std::cout << "centroid: " << (int) uut->centroid_x << "," << (int) uut->centroid_y << std::endl;

        cv::imshow("input",frame);
        cv::imshow("Mask",frame_out);
        if(first_frame) {
            cv::waitKey(0);
            first_frame = false;
        } else {
            cv::waitKey(10);
        }
        frame.release();
        // end_of_video = true;
    }

    cap.release();

    return 0;
}




