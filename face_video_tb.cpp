
#include <verilated.h>
#include "Vface_reader.h"
#include <opencv2/opencv.hpp>


#include "testbench_common.h"

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
    // cv::VideoCapture cap;

    // if(argc > 2) {
    //     cap.open(argv[1]);
    // } else {
    //     // 0 will open the webcam
    //     cap.open(0);
    // }

    // if(!cap.isOpened()) {
    //     std::cerr << "Error opening video file/webcam" << std::endl;
    //     return 1;
    // }

    bool end_of_video = false;
    int main_time = 0;
    Vface_reader* uut = new Vface_reader;
    uut->image_in_R = 0;
    uut->image_in_G = 0;
    uut->image_in_B = 0;
    uut->enable = false;
    uut->enable_process = false;
    uut->clk = 0;

    while(!end_of_video) {
        cv::Mat frame = cv::imread("images/face.png");
        // cap >> frame;
        uut->enable = true;
        // for pixel in frame
        auto p = frame.begin<cv::Vec3b>();
        while(p != frame.end<cv::Vec3b>()) {
            uut->image_in_R = p[0][0];
            uut->image_in_G = p[0][1];
            uut->image_in_B = p[0][2];
            advance_clock_cycle(&main_time,uut);
            p++;
        }
        // begin processing
        uut->enable_process = true;
        advance_clock_cycle(&main_time,uut);

        // wait for processing to end
        while(!uut->finish) {
            advance_clock_cycle(&main_time,uut);
        }

        // image is done, recieve result
        cv::Mat frame_out(frame.rows, frame.cols, CV_8UC3, cv::Scalar(0,0,0));
        p = frame_out.begin<cv::Vec3b>();
        while(p != frame_out.end<cv::Vec3b>()) {
            *p += cv::Vec3b(uut->image_output,uut->image_output,uut->image_output);
            advance_clock_cycle(&main_time,uut);
        }
        std::cout << "centroid: " << uut->centroid_x << "," << uut->centroid_y << std::endl;

        frame.release();
        end_of_video = true;
    }

    // cap.release();

    return 0;
}




