import numpy as np
from PIL import Image
import sys
from centroid import centroid_from_numpy

IMG_SIZE = 256
WINDOW_SIZE = 9
SMOOTH_THRESH = 0.7

def isSkin(u,v):
    return u > 26 and u < 74

def smoothWindow(window):
    return np.sum(window) > ((WINDOW_SIZE ** 2) * 0.7)

def main(img_path):
    img = np.genfromtxt(img_path,delimiter=",",dtype=np.uint8).reshape((IMG_SIZE,IMG_SIZE,3))
    r = img[:,:,0].astype(np.int16)
    g = img[:,:,1].astype(np.int16)
    b = img[:,:,2].astype(np.int16)

    u = r - g
    v = b - g

    mask = np.array([[isSkin(u[y,x],v[y,x]) for x in range(IMG_SIZE)] for y in range(IMG_SIZE)])
    mask = np.array([[smoothWindow(mask[y-(WINDOW_SIZE // 2):y+(WINDOW_SIZE//2)+1,x-(WINDOW_SIZE // 2):x+(WINDOW_SIZE//2)+1]) for x in range(IMG_SIZE - (2*WINDOW_SIZE))] for y in range(IMG_SIZE - (2*WINDOW_SIZE))])

    h,w = mask.shape
    centroids = centroid_from_numpy(mask.reshape((h,w,1)))
    if type(centroids) == type(()):
        centroids = [centroids]
    for centroid_x,centroid_y in centroids:
        print(centroid_x,centroid_y)

    mask = mask.astype(np.uint8) * 255
    mask_rgb = np.dstack((mask,mask,mask))
    for centroid_x,centroid_y in centroids:
        mask_rgb[centroid_y-(WINDOW_SIZE//4):centroid_y+(WINDOW_SIZE//4)+1,centroid_x-(WINDOW_SIZE//4):centroid_x+(WINDOW_SIZE//4)+1] = [255,0,0]
    Image.fromarray(mask_rgb).save("test.png",mode="RGB")

if __name__ == '__main__':
    main(sys.argv[1])