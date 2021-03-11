#!/usr/bin/python3

import numpy as np
from PIL import Image
import sys

def main():    
    Image.fromarray(np.genfromtxt(sys.argv[1],delimiter=',',dtype=np.str).reshape((sys.argv[2],sys.argv[3],3)).astype(np.uint8)).save("out.png",mode="RGB")

if __name__ == '__main__':
    main()