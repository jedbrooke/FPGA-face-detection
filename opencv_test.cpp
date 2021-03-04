#include <opencv2/opencv.hpp>
#include <iostream>

int main(){

  // Create a VideoCapture object and open the input file
  // If the input is the web camera, pass 0 instead of the video file name
  cv::VideoCapture cap(0); 
   
  // Check if camera opened successfully
  if(!cap.isOpened()){
    std::cout << "Error opening video stream or file" << std::endl;
    return -1;
  }
	
  while(1){

    cv::Mat frame;
    // Capture frame-by-frame
    cap >> frame;
 
    // If the frame is empty, break immediately
    if (frame.empty())
      break;

    // Display the resulting frame
    cv::imshow( "Frame", frame );

    for (auto p = frame.begin<cv::Vec3b>(); p != frame.end<cv::Vec3b>(); p++)
    {
      std::cout << p[0] << std::endl;
    }
    


    // Press  ESC on keyboard to exit
    char c=(char)cv::waitKey(0);
    if(c==27)
      break;
  }
 
  // When everything done, release the video capture object
  cap.release();

  // Closes all the frames
  cv::destroyAllWindows();
	
  return 0;
}