%.txt: %.png
	python3 rgb2txt.py $<


.PHONY: centroids
centroids:
	for f in images/centroids/*.png ; do \
		make "$${f%.*}".txt ; \
	done

