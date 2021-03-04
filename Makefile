
VERILATOR=verilator
VFLAGS=-cc --exe --build -j -Wno-fatal
BUILD_DIR_SIFFIX=verilator_build

%.txt: %.png
	python3 rgb2txt.py $<


.PHONY: centroids
centroids:
	for f in images/centroids/*.png ; do \
		make "$${f%.*}".txt ; \
	done

centroid_tb: centroid_tb.cpp centroid.v read_img.cpp
	$(VERILATOR) $(VFLAGS) --Mdir centroid_tb.$(BUILD_DIR_SIFFIX) -o centroid_tb centroid.v centroid_tb.cpp read_img.cpp
	cp centroid_tb.$(BUILD_DIR_SIFFIX)/centroid_tb centroid_tb

.PHONY: clean
clean:
	rm -rf *.$(BUILD_DIR_SIFFIX)
