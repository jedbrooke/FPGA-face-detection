CXX=g++

%.txt: %.png
	python3 rgb2txt.py $<


.PHONY: centroids
centroids:
	for f in images/centroids/*.png ; do \
		make "$${f%.*}".txt ; \
	done

opencv_test: opencv_test.cpp
	$(CXX) -o opencv_test opencv_test.cpp `pkg-config --cflags --libs opencv4` --std=c++11