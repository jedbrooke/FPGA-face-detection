
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

<<<<<<< Updated upstream
=======
tmds_tb: tmds_tb.v tmds_tb.cpp tmds_encode.v tmds_decode.v read_img.cpp
	$(VERILATOR) $(VFLAGS) --Mdir tmds_tb.$(BUILD_DIR_SIFFIX) --top-module tmds_tb -o tmds_tb tmds_tb.v tmds_tb.cpp tmds_encode.v tmds_decode.v read_img.cpp
	cp tmds_tb.$(BUILD_DIR_SIFFIX)/tmds_tb tmds_tb

>>>>>>> Stashed changes
.PHONY: clean
clean:
	rm -rf *.$(BUILD_DIR_SIFFIX)
