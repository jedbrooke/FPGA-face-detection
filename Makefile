CXX=g++

VERILATOR=verilator
VFLAGS=-cc --exe --build -j -Wno-fatal
BUILD_DIR_SIFFIX=verilator_build
CVFLAGS=`pkg-config --cflags --libs opencv4` --std=c++11
# CVFLAGS=-I/usr/include/opencv4/opencv -I/usr/include/opencv4 -lopencv_stitching -lopencv_aruco -lopencv_bgsegm -lopencv_bioinspired -lopencv_ccalib -lopencv_dnn_objdetect -lopencv_dnn_superres -lopencv_dpm -lopencv_highgui -lopencv_face -lopencv_freetype -lopencv_fuzzy -lopencv_hdf -lopencv_hfs -lopencv_img_hash -lopencv_line_descriptor -lopencv_quality -lopencv_reg -lopencv_rgbd -lopencv_saliency -lopencv_shape -lopencv_stereo -lopencv_structured_light -lopencv_phase_unwrapping -lopencv_superres -lopencv_optflow -lopencv_surface_matching -lopencv_tracking -lopencv_datasets -lopencv_text -lopencv_dnn -lopencv_plot -lopencv_ml -lopencv_videostab -lopencv_videoio -lopencv_viz -lopencv_ximgproc -lopencv_video -lopencv_xobjdetect -lopencv_objdetect -lopencv_calib3d -lopencv_imgcodecs -lopencv_features2d -lopencv_flann -lopencv_xphoto -lopencv_photo -lopencv_imgproc -lopencv_core --std=c++11

%.txt: %.png
	python3 rgb2txt.py $<


.PHONY: centroids
centroids:
	for f in images/centroids/*.png ; do \
		make "$${f%.*}".txt ; \
	done

opencv_test: opencv_test.cpp
	$(CXX) -o opencv_test opencv_test.cpp $(CVFLAGS)

face_video_tb: face_video_tb.cpp face_reader.v centroid.v
	$(VERILATOR) $(VFLAGS) --Mdir face_video_tb.$(BUILD_DIR_SIFFIX) -o face_video_tb face_video_tb.cpp face_reader.v centroid.v -CFLAGS "$(CVFLAGS)"
	cp face_video_tb.$(BUILD_DIR_SIFFIX)/face_video_tb face_video_tb

centroid_tb: centroid_tb.cpp centroid.v read_img.cpp
	$(VERILATOR) $(VFLAGS) --Mdir centroid_tb.$(BUILD_DIR_SIFFIX) -o centroid_tb centroid.v centroid_tb.cpp read_img.cpp
	cp centroid_tb.$(BUILD_DIR_SIFFIX)/centroid_tb centroid_tb

.PHONY: clean
clean:
	rm -rf *.$(BUILD_DIR_SIFFIX)
