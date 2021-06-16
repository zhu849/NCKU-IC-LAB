import numpy as np
import os
import cv2
import skimage

filepath = "./image.jpg"
original_file_name = "img.dat"
processed_file_name = "golden.dat"

def hexCvt(num):
    left = int(num/16)
    right = int(num%16)
    
    msg = ""
    if(left >= 0 and left <10):
        msg = str(left)
    elif(left == 10):
        msg = "a"
    elif(left == 11):
        msg = "b"
    elif(left == 12):
        msg = "c"
    elif(left == 13):
        msg = "d"
    elif(left == 14):
        msg = "e"
    elif(left == 15):
        msg = "f"
        
    if(right >= 0 and right <10):
        msg += str(right)
    elif(right == 10):
        msg += "a"
    elif(right == 11):
        msg += "b"
    elif(right == 12):
        msg += "c"
    elif(right == 13):
        msg += "d"
    elif(right == 14):
        msg += "e"
    elif(right == 15):
        msg += "f"
    
    return msg

if __name__ == '__main__':
    img = cv2.imread(filepath)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img = cv2.resize(img, (128,128))
    img = skimage.util.random_noise(image=img, mode='s&p', clip=True, amount=0.02,salt_vs_pepper=0.5)
    cv2.imshow(original_file_name, img)
    img *= 255

    # Output img.dat
    file = open(original_file_name, "w")
    for i in range(128):
        for j in range(128):
            img[i][j] = int(img[i][j])
            tmp = hexCvt(img[i][j])
            tmp = tmp + "\n"
            file.write(tmp)     
    file.close()       
    
    expand_img = np.zeros((130,130))
    # Set image to expand numpy array
    for i in range(128):
        for j in range(128):
            expand_img[i+1][j+1] = img[i][j]

    expand_img = expand_img.astype(np.uint8)
    expand_img = cv2.medianBlur(expand_img, 3)
    cv2.imshow(processed_file_name, expand_img)

    # Output golden.dat
    file = open(processed_file_name, "w")
    for i in range(1,129):
        for j in range(1,129):
            expand_img[i][j] = int(expand_img[i][j])
            tmp = hexCvt(expand_img[i][j])
            tmp = tmp + "\n"
            file.write(tmp)
    file.close()
    
    cv2.waitKey(0)