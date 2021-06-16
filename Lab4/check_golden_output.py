import numpy as np
import os
import cv2
import skimage

input_file_name = "img.dat"
output_file_name = "testC.dat"

img = np.zeros((130,130))

file = open(input_file_name,"r")
for i in range(1,129):
    for j in range(1,129):
        img[i][j] = int(file.read(2),16)
        file.read(1)
file.close()

img = img.astype(np.uint8)
img = cv2.medianBlur(img, 3)
cv2.imshow(output_file_name, img)

file = open(output_file_name, "w")
for i in range(1,129):
    for j in range(1,129):
        img[i][j] = int(img[i][j])
        tmp = hexCvt(img[i][j])
        tmp = tmp + "\n"
        file.write(tmp)
file.close()

cv2.waitKey(0)