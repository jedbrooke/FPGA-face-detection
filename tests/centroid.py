import numpy as np
import sys

IMG_SIZE = 256
THRESH = 0

def centroid_from_txt(img_path):
    img = np.genfromtxt(img_path,delimiter=",",dtype=np.uint8).reshape((IMG_SIZE,IMG_SIZE,3))
    return centroid_from_numpy(img)

def centroid_from_numpy(img):
    sum_x,sum_y = 0,0
    count = 0
    # again, probably not the most eficient way to do this, but I want it to match the verilog version
    h,w,color_channels = img.shape
    for y in range(h):
        for x in range(w):
            if sum(img[y,x,:]) / color_channels > THRESH:
                sum_x += x
                sum_y += y
                count += 1
    if count == 0: count += 1
    return sum_x//count,sum_y//count



if __name__ == '__main__':
    print("centroid:",centroid_from_txt(sys.argv[1]))