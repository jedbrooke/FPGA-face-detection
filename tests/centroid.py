import numpy as np
import sys

IMG_SIZE = 256
THRESH = 128

def centroid(img_path):
    img = np.genfromtxt(img_path,delimiter=",",dtype=np.uint8).reshape((IMG_SIZE,IMG_SIZE,3))
    sum_x,sum_y = 0,0
    count = 0

    # again, probably not the most eficient way to do this, but I want it to match the verilog version
    for y in range(IMG_SIZE):
        for x in range(IMG_SIZE):
            if sum(img[y,x,:]) / 3 > THRESH:
                sum_x += x
                sum_y += y
                count += 1

    print("centroid:",sum_x//count,",",sum_y//count)


if __name__ == '__main__':
    centroid(sys.argv[1])