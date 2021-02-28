from PIL import Image
import sys
import numpy as np

def main():
    img_path = sys.argv[1]
    if len(sys.argv) > 2:
        out_path = sys.argv[2]
    else:
        out_path = ".".join(img_path.split('.')[:-1] + ["txt"])
    
    img = Image.open(img_path)
    img_array = np.array(img)
    height,width,_ = img_array.shape
    with open(out_path,"w") as out_file:
        for y in range(height):
            for x in range(width):
                out_file.write(f"{','.join([str(v) for v in img_array[y,x]])}\n")




if __name__ == '__main__':
    main()